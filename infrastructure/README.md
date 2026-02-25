# Naughty GCP Minikube Demo

這是一個針對如何在 GCP (Google Cloud Platform) 上，透過基礎設施即代碼 (Infrastructure as Code, IaC) 自動建置虛擬機，並在其中運行 Minikube 單機版 Kubernetes 的完整 Lab 環境教學。本專案包含了從 **雲端基礎設施建置** 到 **K8s 微服務應用部署** 的完整流程。

## 📁 專案目錄結構

- `/infrastructure`: 包含建立 GCP 虛擬環境與安裝基礎套件的 Terraform 腳本。
- `/demo`: 包含要部署至 Minikube 叢集中的各項 Kubernetes 資源清單檔 (YAML)。

---

## 🏗️ 第一部分：基礎設施建置 (Infrastructure)

本專案使用 **Terraform** 自動佈署 GCP VM，並透過啟動腳本 (Startup Script) 自動安裝 Docker、Kubectl 與 Minikube。

### 1. 架構特色
- **GCP Compute Engine (VM)**: 預設建立一台 `e2-medium` 的 Ubuntu 22.04 VM (`minikube-lab`) 於 `asia-east1-b`。
- **防火牆規則 (`allow-k8s-dev`)**: 自動開啟 SSH (`22`)、HTTP/HTTPS (`80, 443`)、常用測試埠 (`3000-9000`) 以及 NodePort 範圍 (`30000-32767`)。
- **Startup Script (`scripts/startup.sh`)**: VM 啟動時會自動取得並安裝:
  - 基礎工具 (curl, conntrack, git)
  - Docker 引擎
  - Kubectl 命令列工具
  - Minikube 執行檔

### 2. Terraform 部署步驟
請確保您的本機已安裝 Terraform 並已透過 `gcloud auth application-default login` 完成 GCP 認證。

```bash
cd infrastructure

# 1. 初始化 Terraform
terraform init

# 2. 檢視即將建立的資源 (請將 <YOUR_GCP_PROJECT_ID> 換成您的專案 ID)
terraform plan -var="project_id=<YOUR_GCP_PROJECT_ID>"

# 3. 執行部署
terraform apply -var="project_id=<YOUR_GCP_PROJECT_ID>"
```

### 3. 連線至 VM
部署成功後，Terraform 會輸出供連線的 SSH 指令與外部 IP 位址，您可以使用輸出的指令連入剛建置好的 VM 來進行接下來的 Kubernetes Lab:
```bash
gcloud compute ssh minikube-lab --zone=asia-east1-b
```

*(登入 VM 後，建議可以先執行 `minikube start --force` 來啟動 Kubernetes 叢集)*

---

## 🚀 第二部分：Kubernetes 應用部署 (Demo)

進入 VM 並啟動 Minikube 後，就可以開始部署我們的示範微服務架構了。此示範環境包含了前端網頁 (Nginx)、後端 API (FastAPI)、身分認證 (Casdoor) 及訊息佇列 (RabbitMQ)。

**詳細的 K8s 架構說明、部署指令與對外開放測試方法，請參閱：**
👉 **[`demo/README.md`](demo/README.md)** 

*(在 `demo/README.md` 中，您將會學到如何建立 ConfigMap、套用 Deployment & Service、使用 Port-forward，以及透過 Cloudflared 穿透 NAT 測試 HTTPS)*

---

## 🧹 清除資源 (Clean up)

當 Lab 結束不再需要時，記得清除 GCP 上的資源以避免持續計費：

```bash
cd infrastructure
terraform destroy -var="project_id=<YOUR_GCP_PROJECT_ID>"
```
