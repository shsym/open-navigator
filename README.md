# open-navigator
* Open-navigator is `the container orchestration platform` with `docker container` and `kubernetes` across on-premise infrastructure.
* Features
  * Build, deploy and manage your applications based on container.
  * `Auto-infra provisioning platform` that automates software provisioning, configuration management, and application deployment.

<br> 

* Languages & Platforms
  * Docker
  * Kubernetes
  * Ansible
  * Go
  * Java

<br>

### Language & Platform
* Infra
    - `GCP + AWS` Hybrid 방식 with Ansible
* Container
    - Docker
    - Kubernetes
* Kube-Navigator
    - Server
        + Go
        + Node.js
        + Java
    - Lib
        + AWS, GCP SDK 연동 라이브러리 (kube-navigator-cloud)
        + kubectl 연동 라이브러리 (kube-navigator-on-premise)
* Test
    - Vagrant
    - OAS 3.0 (Swagger 2.0)

<br>

## [ Constraints ]
* One or more machines running one of:
    + <u> (중요) CentOS 7 </u>
* 2 GB or more of RAM per machine (any less will leave little room for your apps)
* 2 CPUs or more
* Full network connectivity between all machines in the cluster (public or private network)
* Unique hostname, MAC address, and product_uuid for every node.
* (중요) <u>SSH 통신(22 tcp)이 가능해야 한다.</u>
* (중요) <u>`SELinux` 설정은 `enforing` or `permissive`로 설정되어있어야 한다.</u>
    - `disable` 모드 시, 도커 및 쿠버네티스 설치 불가능

<br>

## [ Tree ]
```bash
├── README.html
├── README.md
├── config
│   ├── README.html
│   └── README.md
├── kube-cluster
│   ├── README.html
│   ├── README.md
│   ├── k8s_object.md
│   └── objects
├── kube-init
│   ├── README.html
│   ├── README.md
│   ├── ansible.sh
│   ├── config
│   ├── inventories
│   ├── playbook.yml
│   ├── roles
│   ├── test
│   └── vars
├── kube-navigator
│   ├── apiserver-cloud-sdk
│   └── apiserver-kubectl-cli
├── test
├── tools
│   ├── dcs
│   └── sample-compose-yml
└── vagrant
    └── Vagrantfile
```

| File (Dir) | Description |
| ---- | ------------ |
| config | * 글로벌 환경설정 |
| kube-cluster | * 쿠버네티스 클러스터 객체 |
| kube-init | * 쿠버네티스 인프라 프로비저닝 with Ansible |
| kube-navigator | * 쿠버네티스 API 서버 |
| kube-navigator > apiserver-cloud-sdk | * 클라우드 SDK 용도 RESTful API 서버 |
| kube-navigator > apiserver-kubectl-cli | * kubectl 클라이언트 용도 RESTful API 서버 |
| test | * Unit Test, Black-box Test |
| tools | * 기타 툴 |
| vagrant | * Vagrant 테스트 파일 |
| README.md | * GitHub 대표 문서 |



