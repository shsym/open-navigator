## [ Constraints ]
* (중요) <u>SSH 통신(22 tcp)이 가능해야 한다.</u>
* Docker Registry 서버는 `Master` 노드에 구축한다.

<br>

## [ Troubleshooting ]
* 설치 오류 시, 주요 점검 사항은 다음과 같다.
    * SSH 서비스 기동 여부
    * SELinux `enforcing` or `permissive` 모드 설정 여부
        * `disable` 시 Docker, Kubernetes 설치 불가능
    * RPM Package Dependency

<br>

## [ Usage ]
쉘 스크립트 구동 시, Inventory(설치 호스트 환경설정 정보) 파일 경로를 첫 번째 파라미터로 지정한다.
```bash
./ansible.sh {inventory_file_path}
```

<br>

### Play Architecture
```
# 현재
                                                                                           
      ╔═ MASTER ════════════════════════════════════════════════════════════════════╗      
      ║                             ┏━━━━━━━━━━━━━━━━━━┓                            ║      
      ║                             ┃                  ┃                            ║      
      ║                             ┃  MASTER-PRIMARY  ┃                            ║      
      ║                             ┃                  ┃                            ║      
      ║                             ┗━━━━━━━━━━━━━━━━━━┛                            ║      
      ╚══════════════════════════════════════╦══════════════════════════════════════╝      
                                             ┃                                             
                              Serial Install ┃                                             
                                             ┃                                             
╔══  NODE  ══════════════════════════════════▼════════════════════════════════════════════╗
║                         Parallel Install   Λ                                            ║
║                                           ╱ ╲                                           ║
║           ╱──────────────────╳───────────╱   ╲╳───────────────────────────╲             ║
║  ┏━━━━━━━▼━━━━━━━┓  ┏━━━━━━━▼━━━━━━━┓  ┏━━━━━━━▼━━━━━━━┓           ┏━━━━━━━▼━━━━━━━┓    ║
║  ┃               ┃  ┃               ┃  ┃               ┃           ┃               ┃    ║
║  ┃    NODE-1     ┃  ┃    NODE-2     ┃  ┃    NODE-3     ┃    ...    ┃    NODE-N     ┃    ║
║  ┃               ┃  ┃               ┃  ┃               ┃           ┃               ┃    ║
║  ┗━━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━┛    ║
╚═════════════════════════════════════════════════════════════════════════════════════════╝

# 추후 변경될 구조
                                                                                           
      ╔═ MASTER ════════════════════════════════════════════════════════════════════╗      
      ║                             ┏━━━━━━━━━━━━━━━━━━┓                            ║      
      ║                             ┃                  ┃                            ║      
      ║                             ┃  MASTER-PRIMARY  ┃                            ║      
      ║                             ┃                  ┃                            ║      
      ║                             ┗━━━━━━━━━━━━━━━━━━┛                            ║      
      ║                                       │                                     ║      
      ║                           Replication │                                     ║      
      ║              ┌─────────────────────┬──┴───────────────────────┐             ║      
      ║              │                     │                          │             ║      
      ║              │                     │                          │             ║      
      ║    ┏━━━━━━━━━▼━━━━━━━━┓  ┏━━━━━━━━━▼━━━━━━━━┓       ┏━━━━━━━━━▼━━━━━━━━┓    ║      
      ║    ┃                  ┃  ┃                  ┃       ┃                  ┃    ║      
      ║    ┃    SECONDARY     ┃  ┃     TERTIARY     ┃  ...  ┃        N         ┃    ║      
      ║    ┃                  ┃  ┃                  ┃       ┃                  ┃    ║      
      ║    ┗━━━━━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━━━━━━━━┛       ┗━━━━━━━━━━━━━━━━━━┛    ║      
      ╚══════════════════════════════════════╦══════════════════════════════════════╝      
                                             ┃                                             
                              Serial Install ┃                                             
                                             ┃                                             
╔══  NODE  ══════════════════════════════════▼════════════════════════════════════════════╗
║                         Parallel Install   Λ                                            ║
║                                           ╱ ╲                                           ║
║           ╱──────────────────╳───────────╱   ╲╳───────────────────────────╲             ║
║  ┏━━━━━━━▼━━━━━━━┓  ┏━━━━━━━▼━━━━━━━┓  ┏━━━━━━━▼━━━━━━━┓           ┏━━━━━━━▼━━━━━━━┓    ║
║  ┃               ┃  ┃               ┃  ┃               ┃           ┃               ┃    ║
║  ┃    NODE-1     ┃  ┃    NODE-2     ┃  ┃    NODE-3     ┃    ...    ┃    NODE-N     ┃    ║
║  ┃               ┃  ┃               ┃  ┃               ┃           ┃               ┃    ║
║  ┗━━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━┛    ║
╚═════════════════════════════════════════════════════════════════════════════════════════╝
```


<br>

### Inventory 파일
`ansible.sh`을 구동하기 전에는 Inventory 파일을 수정한 후 파라미터로 지정해야하는데, 설치자는 전체 내용 중 호스트 파라미터 내용만 추가 및 수정한다.

#### 샘플
```
[epp-master]
192.200.10.10 ip=192.200.10.10 type=master hostname=master user=vagrant user_pw=vagrant su_pw=vagrant registry_set=true registry_ip=192.200.10.10

[epp:vars]
ansible_connection=ssh


[epp-node]
192.200.10.11 ip=192.200.10.11 type=node hostname=node1 user=vagrant user_pw=vagrant su_pw=vagrant registry_set=false registry_ip=192.200.10.10
192.200.10.12 ip=192.200.10.12 type=node hostname=node2 user=vagrant user_pw=vagrant su_pw=vagrant registry_set=false registry_ip=192.200.10.10
192.200.10.13 ip=192.200.10.13 type=node hostname=node3 user=vagrant user_pw=vagrant su_pw=vagrant registry_set=false registry_ip=192.200.10.10

[epp-node:vars]
ansible_connection=ssh
```

<br>

#### 파라미터 양식
```
{host_ip} ip={host_ip} type={master|node} hostname={hostname} user={login_user} user_pw={login_user_pw} su_pw={root_pw} registry_set={true|false} registry_ip={registry_ip}

192.200.10.10 ip=192.200.10.10 type=master hostname=master user=vagrant user_pw=vagrant su_pw=vagrant registry_set=true registry_ip=192.200.10.10
```

|var|value|description|
|---|-----|-----------|
|host_ip|설치 대상 ip 주소||
|ip|설치 대상 ip 주소||
|hostname|설치 대상 호스트 이름|(중요) 각 노드 별 Unique 해야한다.|
|type|설치 대상 타입 지정|`master` : Kubernetes Master <br> `node` : Kubernetes Node|
|user|초기 로그인 User ID||
|user_pw|초기 로그인 User Password||
|su_pw|Root User Password||
|registry_set|Private Registry 설치 및 셋팅 여부|`true` or `false`|
|registry_ip|Private Registry IP|(중요) 해당 IP가 있어야지 EPP 이미지 로드 가능|

<br>

## [ Tree ]
```bash
ansible
├── README.html
├── ansible.sh
├── config
│   └── ansible.cfg
├── inventories
│   └── common
├── playbook.yml
├── roles
│   ├── common
│   │   ├── defaults
│   │   ├── files
│   │   │   ├── config.tar.gz
│   │   │   ├── images.tar.gz
│   │   │   └── packages.tar.gz
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   ├── tasks
│   │   │   ├── install-docker.yml
│   │   │   ├── install-kubernetes.yml
│   │   │   ├── install-utils.yml
│   │   │   ├── main.yml
│   │   │   ├── setting-common.yml
│   │   │   ├── setting-env.yml
│   │   │   ├── setting-files.yml
│   │   │   ├── setting-firewall.yml
│   │   │   ├── setting-hostname.yml
│   │   │   └── setting-kernel.yml
│   │   ├── templates
│   │   └── vars
│   ├── master
│   │   ├── defaults
│   │   ├── files
│   │   │   └── certs
│   │   │       ├── server.crt
│   │   │       ├── server.csr
│   │   │       └── server.key
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   ├── tasks
│   │   │   ├── main.yml
│   │   │   ├── setting-docker-registry.yml
│   │   │   ├── setting-finale.yml
│   │   │   ├── setting-init-epp-domain.yml
│   │   │   └── setting-kubernetes.yml
│   │   ├── templates
│   │   └── vars
│   └── node
│       ├── defaults
│       ├── files
│       ├── handlers
│       ├── meta
│       ├── tasks
│       │   ├── main.yml
│       │   ├── setting-finale.yml
│       │   ├── setting-init-epp-domain.yml
│       │   └── setting-kubernetes.yml
│       ├── templates
│       └── vars
├── test
│   └── array.yml
└── vars
    └── common.yml
```

| File (Dir) | Description |
| ---- | ------------ |
| README.html | 참고 문서 |
| ansible.sh | 설치 구동 스크립트 |
| config | 글로벌 환경 설정 |
| inventories | 인벤토리 모음 (호스트 모음) |
| playbook.yml | 수행 작업 목록 |
| roles | Ansible 수행 작업 RuleSet (Common, Master, Node) |
| tasks | 단일 작업 테스트 |
| vars | 글로벌 변수 |

<br>

## [ Firewall ]
### 1. Service
| Service | Description |
| ------- | ------------ |
| http | REST API, LOAD BALANCE |
| https | REST API, LOAD BALANCE |

<br>

### 2. Port
#### 2.1. Master
| Protocol | Port  | Description |
| -------- | ----- | ----------- |
| TCP | 6443 | kube-apiserver |
| TCP | 2379-2380 | etcd server |
| TCP | 10250 | kubelet |
| TCP | 10251 | kube-scheduler |
| TCP | 10252 | kube-controller-manager |


#### 2.2. Node
| Protocol | Port  | Description |
| -------- | ----- | ----------- |
| TCP | 10250 | kubelet |
| TCP | 30000-32767 | NodePort Services |


#### 2.3. Etc.
| Protocol | Port  | Description |
| -------- | ----- | ----------- |
| TCP | 8080 | kube-proxy |
| TCP | 5000 | docker registry |
