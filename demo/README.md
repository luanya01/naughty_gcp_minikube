# Naughty GCP Minikube Demo

這是一個設計來在 GCP (Google Cloud Platform) 上透過 Minikube 學習 Kubernetes (K8s) 的 Lab 環境。
此 Lab 部署了一個包含從基本前端網頁伺服器、後端 API 服務、身分認證系統 (Casdoor) 以及訊息佇列 (RabbitMQ) 等組成的微服務架構。

## 📂 架構與 YAML 總覽

本 Lab 包含了以下組件，均定義在不同的 YAML 檔案中：

1. **Nginx Web 伺服器 (`demo-backend.yaml` & `demo-service.yaml`)**
   - 部署了基礎的 Nginx 容器，並啟動 2 個 Replicas，用以測試基本的 K8s Deployment 和負載平衡概念。
   - 服務 (`Service`) 透過 `NodePort` 將內部 80 Port 映射並對外開放 Port `30080`。

2. **Casdoor 身分認證系統 (`demo-casdoor.yaml`)**
   - 部署開源 IAM (Identity and Access Management) 系統 Casdoor，用於單一登入 (SSO) 或是會員驗證功能。
   - 利用名為 `casdoor-config` 的 ConfigMap 掛載 `app.conf`，連線至外部的 MySQL 資料庫 (`123.123.123.123:3306`)。
   - 透過 `ClusterIP` 服務在叢集內部對外提供 Port `7778` (轉發至容器內部 `8000`)。

3. **FastAPI 後端應用 (`fastapi.yaml`)**
   - 部署自訂的 FastAPI 後端應用 (映像檔：`luanya01/naughty-fastapi:latest`)。
   - 為了適應 Minikube 環境無法使用 `hostPath`，在此範例中改用 ConfigMap 將 `settings.toml` 和 `database.toml` 成功掛載給容器使用。
   - Log 的檔案儲存空間目前使用 `emptyDir` (Pod 重啟或刪除即會清空)。
   - 透過 `ClusterIP` 服務在叢集內部對接 Port `7779` (轉發至容器內部 `8000`)。

4. **RabbitMQ 訊息佇列 (`rabbitmq-full.yaml`)**
   - 部署附帶 Management UI 的 RabbitMQ (`rabbitmq:3-management`)。
   - 提供 AMQP 通訊埠 (`5672`) 與網頁管理介面埠 (`15672`)。

---

## 🚀 部署教學 (Deployment Guide)

以下操作請在已安裝好 Minikube 與 kubectl 的 GCP VM 終端機進行。

### 1. 建立 FastAPI 所需的 ConfigMap
由於 FastAPI 需要外部注入的設定檔，請先在同層目錄中準備好你的 `settings.toml` 與 `database.toml`。
接著執行以下指令建立 ConfigMap：
```bash
kubectl create configmap fastapi-config --from-file=settings.toml --from-file=database.toml
```
*(建立成功後，方可順利啟動 FastAPI Pod)*

### 2. 套用 Kubernetes 資源配置
使用 `kubectl apply` 將此目錄下的 yaml 部署到 Minikube 叢集內。可以一次性套用全部目錄：

```bash
kubectl apply -f .
```

或是根據需求各別單獨部署：
```bash
# Nginx
kubectl apply -f demo-backend.yaml
kubectl apply -f demo-service.yaml

# Casdoor
kubectl apply -f demo-casdoor.yaml

# FastAPI
kubectl apply -f fastapi.yaml

# RabbitMQ
kubectl apply -f rabbitmq-full.yaml
```

### 3. 確認部署狀態
使用以下指令來查詢 Pod 以及 Service 是否全部顯示 `Running`：
```bash
# 查看容器是否有錯誤
kubectl get pods

# 查看服務綁定狀態
kubectl get svc
```

### 4. 存取與測試服務

#### 🌐 Nginx 服務 (NodePort)
因為它宣告為 `NodePort` (30080)，如果有開放 GCP VM 防火牆 (tcp:30080) 給外部時，理論上可以透過 `http://<GCP-VM-External-IP>:30080` 來存取。
**(註: 如果你在 Minikube 內遇到無法連入 NodePort 機制，可執行 `minikube service my-first-service` 或是 `kubectl port-forward svc/my-first-service 30080:80 --address 0.0.0.0` 來將 VM Port 橋接出去測試。)**

#### 🔒 內部微服務 (ClusterIP: FastAPI, Casdoor, RabbitMQ)
預設皆為 `ClusterIP`，一般只能給其它在同個 K8s 內的 Pod 調用。
若開發時想從外部介面操作（例如進入 RabbitMQ Management UI 或是呼叫 FastAPI 的 Swagger Docs），建議使用 port-forward 對外開放。

**範例 - 對外開放 RabbitMQ UI：**
```bash
kubectl port-forward svc/rabbitmq-service 15672:15672 --address 0.0.0.0
```
完成後，便可透過 GCP VM IP 進入 `http://<GCP-VM-External-IP>:15672` (帳密為 yaml 設定之 `admin / admin123`，請確保 GCP 防火牆有開通 `15672` port)。

**範例 - 對外開放 Casdoor 與 FastAPI 服務：**
同時轉發 Casdoor (`7778`) 與 FastAPI (`7779`) port 進行測試：
```bash
kubectl port-forward --address 0.0.0.0 svc/casdoor-service 7778:7778 & kubectl port-forward --address 0.0.0.0 svc/fastapi-service 7779:7779
```

**進階 - 使用 Cloudflared 模擬 HTTPS (例如測試 OIDC callback)：**
如果某些登入流程 (如 Google OAuth) 強制需要 HTTPS，且 GCP 外部 IP 無法直接滿足時，可利用 Cloudflared 建立安全的 HTTPS 隧道，將公開的 HTTPS 網址轉發至本機服務 (請另開一個 Terminal 執行)：
```bash
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
cloudflared tunnel --url http://localhost:7778
```

> [!IMPORTANT]
> 成功啟動 Cloudflared 並取得其給予的 HTTPS 隨機網址後，請務必前往 **GCP API 憑證 (Credentials)** 頁面，將您的 OAuth Client ID 中「**已授權的重新導向 URI (Authorized redirect URIs)**」修改指向該 `https://<cloudflared-url>/...` callback 位置。

---

## 💡 注意事項與採坑紀錄 (Minikube 限制)

1. **Volume 掛載的陷阱 (`hostPath`)**: 
   在 Docker based 的 Minikube 中，`hostPath` 所指向的是 **Minikube 虛擬機/容器內** 的路徑，而不是你 GCP VM 上的本機路徑。這導致嘗試直接掛載 GCP VM 中的實體檔案給 Pod 會失敗。
2. **解決方案 (ConfigMap)**: 
  如本 Lab 中 `fastapi.yaml` 所示，建議將設定檔等小體積文本透過 `ConfigMap` 包裝後再掛載進 Pod，這是既標準又不會遇到 Minikube/GCP 雙重檔案系統障礙的解法。
3. **臨時空間 (`emptyDir`)**: 
   儲存如 Log 的暫時產物，若不需要保留，可以單純宣告 `emptyDir: {}`。若需要在 GCP 永久保留，請研究 `PersistentVolume (PV)` 與 `PersistentVolumeClaim (PVC)` 的用法。
