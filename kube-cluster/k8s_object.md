## [ CLUSTER ]
```yaml
```

<br>

## [ NAMESPACE ]
```yaml
```

<br>



## [ LABEL ]
```json
"metadata": { 
  "labels": { 
    "key1" : "value1", 
    "key2" : "value2" 
  }
}
```

<br>

## [ INGRESS ]
```yaml
```

<br>

## [ SERVICE ]
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port:80
    targetPort: 9376
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-node-svc
spec:
  selector:
    app: hello-node
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

<br>



## [ CONTROLLER ]
### Replication Controller
```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    app: nginx
  template:
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

<br>

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: hello-node-rc
spec:
  replicas: 3
  selector:
    app: hello-node
  template:
    metadata:
      name: hello-node-pod
      labels:
        app: hello-node
    spec:
      containers:
      - name: hello-node
        image: gcr.io/terrycho-sandbox/hello-node:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
```

<br>

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: hello-node-rc
spec:
  replicas: 3
  selector:
    app: hello-node
  template:
    metadata:
      name: hello-node-pod
      labels:
        app: hello-node
      spec:
        containers:
        - name: hello-node
          image: gcr.io/terrycho-sandbox/hello-node:v1
          imagePullPolicy: Always
          ports:
          - containerPort: 8080
```

<br>

### Job
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

<br>
### CronJob
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: “*/1 * * * *”
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: hello
              image: busybox
              args:
              - /bin/sh
              - -c
              - date; echo Heelo from the kubernetes cluster
            restartPolicy: OnFailure
```

<br>


## [ POD ]
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 8090
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: terrypath
      mountPath: /data/shared
    volumes:
    - name: terrypath
      persistentVolumeClaim:
        claimName: mydisk
```



<br>

## [ VOLUME ]
### 1. Local
```yaml
# temp
apiVersion: v1
kind: Pod
metadata:
  name: shared-volumes
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: shared-storage
      mountPath: /data/shared
  - name: nginx
    image: nginx
    volumeMounts:
    - name: shared-storage
      mountPath: /data/shared
  volumes:
  - name: shared-storage
    emptyDir: {}
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: terrypath
      mountPath: /data/shared
  volumes:
  - name: terrypath
    hostPath:
      path: /tmp
      type: Directory
```

<br>

### 2. NETWORK
#### 2.1. gitRepo
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gitrepo-volume-pod
spec:
  containers:
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    ports:
    - protocol: TCP
      containerPort: 80
```

#### 2.2. EBS
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: slow
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  zones: us-east-1d, us-east-1c
  iopsPerGB: "10"
```

```yaml
Persistent Disk
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: slow
provisioner: kubernetes.ki/gce-pd
parameters:
  type: pd-standard
  zones: us-central1-a, us-central1-b
```



### 3. PersistentVolume (PV)
```yaml
apiVersion: v1
kind: PersistantVolume
metadata:
  name: pv0003
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  storageClassName: slow
  capacity:
    storage: 5Gi

  persistentVolumeReclaimPolicy: Recycle
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /tmp
    server: 172.17.0.2
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-demo
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName:
  capacity:
    storage: 20G
  gcePersistentDisk:
    pdName: pv-demo-disk
    fsType: ext4
```

### 4. PersistentVolumeClaim (PVC)
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  storageClassName: slow
  resources:
    requests:
      storage: 8Gi

  selector:
    matchLabels:
      release: "stable"
    matchExpressions:
      - {key: environment, operator: In, values: [dev]}
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim-demo
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  volumeName: pv-demo
  resources:
    requests:
      storage: 20G
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mydisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi
```


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: terrypath
      mountPath: /data
  volumes:
  - name: terrypath
    persistentVolumeClaim:
     claimName: pv-claim-demo
```



<br>

