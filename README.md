# Observability as Code (OaC)
<a href="https://www.canva.com/design/DAGUFzpNXao/rhyXMTxWghUnbegUXY9qZA/edit?utm_content=DAGUFzpNXao&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton"> PPT 자료</a>

## 개요

클라우드와 DevOps, SRE 직군에 관심을 가지면서, 채용 공고에서 **Observability**가 중요한 키워드로 자주 등장하는 것을 알게 되었습니다. 이를 계기로 Observability의 중요성을 고민하게 되었고, 실무적으로 어떻게 다뤄볼 수 있을지 탐구하던 중, **Observability as Code**라는 개념을 접하게 되었습니다. 이 개념을 구현해보면 Observability에 대한 이해도가 생기고, 관련 도구들의 사용법을 자연스럽게 익힐 수 있을 것 같아 주제로 선정하게 되었습니다.

## Observability란?

**Observability**는 복잡한 시스템의 출력을 실시간으로 분석하여 시스템 내부의 상태를 파악할 수 있는 능력을 의미합니다. 이는 시스템 장애의 근본적인 원인을 분석하기 위한 방법론으로, 한국어로는 <i>"관찰 가능성"</i> 이라고 번역됩니다.

Observability가 다루는 데이터 유형은 크게 4가지로, 각 앞자리를 따서 **MELT**라고 부릅니다:

- **Metrics (메트릭)**: 성능과 시스템 상태를 정량적으로 측정하는 데이터. 숫자 형태로 표현되며, 시간에 따른 변화를 추적할 수 있습니다. 예시: CPU 사용률, 메모리 소비량.
  
- **Events (이벤트)**: 특정 시점에 발생한 중요한 사건이나 상태 변화를 기록하는 데이터. 특정 이벤트 간의 상관관계를 파악할 수 있습니다. 예시: 사용자 로그인, 파일 업로드.
  
- **Logs (로그)**: 시스템의 다양한 활동과 상태를 기록한 데이터. 일반적으로 텍스트 형식으로 저장되며, 디버깅 및 문제 해결에 활용됩니다. 예시: 서버 로그, 에러 메시지.
  
- **Traces (트레이스)**: 일련의 작업 흐름을 추적하는 데이터. 각 작업의 처리 시간과 호출 관계, 의존성 등을 기록하여, 시스템에서 병목 현상이나 오류가 발생하는 지점을 식별하는 데 도움을 줍니다. 예시: 마이크로서비스 간의 분산 트레이싱.

## Observability as Code란?

**Observability as Code**는 관찰 도구의 설정을 코드로 정의하고, 이를 자동화하여 일관된 방식으로 배포하고 관리하는 개념입니다. 설정을 코드화함으로써 버전 관리가 가능하며, 변경 사항을 쉽게 추적하고 협업을 효율적으로 진행할 수 있습니다.

### 장점:
- 설정 파일을 통한 일관성 및 추적의 용이성 보장
- 배포 자동화 가능
- 협업 효율성 증대

## 구현 환경 및 사용한 기술
<p align="center">
    <img src="https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white"/>
    <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white"/>
    <img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white"/>
    <img src="https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white"/>
    <img src="https://img.shields.io/badge/OpenTelemetry-7B5FAE?style=for-the-badge&logo=opentelemetry&logoColor=white"/>
    <img src="https://img.shields.io/badge/Loki-FF9E0F?style=for-the-badge&logo=Loki&logoColor=white"/>
    <img src="https://img.shields.io/badge/Tempo-FF9E0F?style=for-the-badge&logo=tempo&logoColor=white"/>
</p>

```bash
# prometheus 설치
sudo apt-get update
sudo apt-get install prometheus

# Node-Exporter 다운로드
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.5.0.linux-amd64.tar.gz
cd node_exporter-1.5.0.linux-amd64
./node_exporter

# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
```
```bash
# grafana 설치
set -e

# Add Grafana GPG key
echo "Adding Grafana GPG key..."
curl https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana-archive-keyring.gpg

# Add Grafana repository
echo "Adding Grafana repository..."
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Update package list
echo "Updating package list..."
sudo apt update

# Install Grafana
echo "Installing Grafana..."
sudo apt install -y grafana

# Enable and start Grafana service
echo "Enabling and starting Grafana service..."
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Display Grafana status
echo "Grafana service status:"
sudo systemctl status grafana-server

echo "Grafana installation completed successfully."

```
```bash
# terraform 설치
sudo su -
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get install terraform -y
terraform -version
```
``` bash
# loki
https://cloudest.oopy.io/posting/106 

# promtail
curl -O -L "https://github.com/grafana/loki/releases/download/v2.4.1/promtail-linux-a
rm64.zip"
unzip "promtail-linux-arm64.zip"
chmod a+x "promtail-linux-arm64"
sudo cp promtail-linux-arm64 /usr/local/bin/promtail
promtail --version
sudo mkdir -p /etc/promtail /etc/promtail/logs
sudo curl -o /etc/promtail/promtail-config.yaml -L "https://gist.githubusercontent.co
m/theLazyCat775/6fe9125e529221166e9f02b00244638a/raw/84f510e6f62d0e60ab95dbe7f9732a629a27eb6
d/promtail-config.yaml"
sudo vi /etc/systemd/system/promtail.service
sudo systemctl daemon-reload
sudo systemctl start promtail
sudo systemctl status promtail
/usr/local/bin/promtail -config.file /etc/promtail/promtail-config.yaml
sudo vim /etc/promtail/promtail-config.yaml
sudo systemctl daemon-reload
sudo systemctl start promtail
sudo systemctl status promtail

# promtail-config.yaml
positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push  # Loki instance URL

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*.log  # Path to your log file
```
``` bash
# tempo 
curl -Lo tempo_2.2.0_linux_arm64.deb https://github.com/grafana/tempo/releases/downlo
ad/v2.2.0/tempo_2.2.0_linux_arm64.deb
echo e81cb4ae47e1d8069efaad400df15547e809b849cbb18932e23ac3082995535b   tempo_2.2.0_l
inux_arm64.deb | sha256sum -c
sudo cp tempo-config.yaml /etc/tempo/tempo.yaml

# /etc/tempo/tempo.yaml
server:
  http_listen_port: 3200
  grpc_listen_port: 9096

distributor:
  receivers:
    otlp:  
      protocols:
        http: 
          endpoint: 0.0.0.0:4318
        grpc: 
          endpoint: 0.0.0.0:4317

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory  
      replication_factor: 1  

compactor:
  compaction:
    compacted_block_retention: 48h  

storage:
  trace:
    backend: local  
    local:
      path: /tmp/tempo/traces  

memberlist:
  join_members: []
```
