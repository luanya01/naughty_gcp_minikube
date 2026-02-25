# Naughty GCP Minikube Demo

本專案是一個在 GCP (Google Cloud Platform) 上，透過自動化佈署建立虛擬機，並在其中運行 Minikube (單機 Kubernetes) 的完整 Lab 環境教學。

為了保持文件整潔與職責分離，請根據您的需求查看以下子目錄中的專屬文件：

## 1. 🏗️ 基礎設施建置 (Infrastructure)

負責利用 **Terraform** 自動佈署 GCP VM，並透過腳本自動安裝 Docker、Kubectl 與 Minikube。
包含詳細的 Terraform 架構介紹、部署步驟及連線與清除方式。

👉 **[請參閱 Infrastructure README](infrastructure/README.md)**

## 2. 🚀 Kubernetes 應用部署 (Demo)

進入 VM 並啟動 Minikube 後，用來部署示範微服務架構 (前端 Nginx、後端 FastAPI、認證 Casdoor、訊息隊列 RabbitMQ)。
包含詳細的 K8s YAML 說明、部署指令、Port-forward 存取測試，以及如何使用 Cloudflared 模擬 HTTPS。

👉 **[請參閱 Demo README](demo/README.md)**
