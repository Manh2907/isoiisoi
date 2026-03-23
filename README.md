# 🛡️ Hệ Thống Giám Sát Tập Trung & Tự Động Hóa Vận Hành (DevOps Monitoring Stack)

> 🚀 Một hệ thống giám sát hiện đại theo hướng **Monitoring as Code**, giúp quản lý tập trung nhiều máy chủ Linux, tự động triển khai và cảnh báo realtime qua Telegram.

---

## 🏗️ 1. Kiến Trúc Tổng Quan

Hệ thống được thiết kế theo mô hình **Master – Agent** nhằm đảm bảo khả năng mở rộng và quản lý tập trung.

### 🔹 Management Node (VM1 - Ubuntu)

Đóng vai trò **trung tâm điều khiển**:

* ⚙️ **Ansible Control Node**: Tự động cấu hình và triển khai xuống các máy con qua SSH
* 🐳 **Docker Engine**: Chạy các dịch vụ giám sát (Prometheus, Grafana, Alertmanager)

### 🔹 Target Nodes (VM2, VM3 - Ubuntu)

Đóng vai trò **máy được giám sát**:

* 📊 **Node Exporter**: Thu thập metrics (CPU, RAM, Disk, Network)
* 🧹 **Cronjobs + Bash Script**: Tự động dọn dẹp hệ thống

---

## 🛠️ 2. Công Nghệ Sử Dụng

| Công nghệ      | Vai trò                | Lý do                              |
| -------------- | ---------------------- | ---------------------------------- |
| Ansible        | Infrastructure as Code | Triển khai nhanh, không cần agent  |
| Docker Compose | Orchestration          | Dễ setup, đồng nhất môi trường     |
| Prometheus     | Monitoring             | Thu thập & lưu trữ metrics mạnh mẽ |
| Grafana        | Visualization          | Dashboard trực quan                |
| Alertmanager   | Alerting               | Gửi cảnh báo Telegram              |
| Bash Script    | Automation             | Tối ưu hệ thống                    |

---

## 🚀 3. Quy Trình Triển Khai

### 🔧 Bước 1: Chuẩn bị hệ thống bằng Ansible

```bash
cd ansible
ansible-playbook -i inventory.ini setup_system.yaml -K
```

👉 Thực hiện:

* Cài Node Exporter
* Setup cronjob dọn rác

---

### 🐳 Bước 2: Khởi chạy hệ thống Monitoring

```bash
cd ..
docker-compose up -d
```

👉 Hệ thống sẽ gồm:

* Prometheus → `:9090`
* Grafana → `:3000`
* Alertmanager → `:9093`

---

### 🚨 Bước 3: Cấu hình Alerting

* File: `alert.rules.yml`
* Trigger khi:

  * CPU > 80%
  * Server DOWN

👉 Gửi cảnh báo qua **Telegram Bot**

---

## 📊 4. Metrics Giám Sát Chính

Dashboard Grafana (ID: **1860 / 11074**) hiển thị:

* ⚡ CPU Usage (per core)
* 🧠 RAM Usage (bao gồm cache/buffer)
* 💾 Disk I/O & Storage
* 🌐 Network Traffic
* ⏱️ Uptime hệ thống

---

## 🛠️ 5. Troubleshooting

### ❌ Lỗi Permission Denied

```bash
sudo chown -R $USER:$USER .
```

---

### ❌ Grafana báo "No Data"

* Check Data Source
* Kiểm tra query Prometheus
* Đảm bảo job name đúng

---

### ❌ Prometheus không scrape được

* Không dùng hostname (`vm2`)
* Dùng IP:

```yaml
targets: ['192.168.x.x:9100']
```

---

### ❌ Lỗi plugin Grafana

* Kiểm tra lại datasource:

```
http://prometheus:9090
```

---

## 📂 6. Cấu Trúc Thư Mục

```
do-an-monitoring/
├── docker-compose.yml
├── .env
├── .gitignore
├── prometheus/
│   ├── prometheus.yml
│   └── alert.rules.yml
├── grafana/
│   └── provisioning/
├── alertmanager/
│   └── alertmanager.yml
├── ansible/
│   ├── inventory.ini
│   ├── setup_system.yml
│   └── scripts/
│       └── auto_cleanup.sh
└── docs/
```

---

## 🎯 7. Kịch Bản Demo

### 🔥 Demo 1: Monitor hoạt động

* Truy cập Grafana
* Xem CPU, RAM realtime

---

### 🔥 Demo 2: Giả lập server down

```bash
sudo systemctl stop node_exporter
```

👉 Nhận alert Telegram

---

### 🔥 Demo 3: Stress CPU

```bash
stress --cpu 2 --timeout 60
```

👉 Trigger alert CPU > 80%

---


Hệ thống giúp bạn:

* 📡 Giám sát tập trung nhiều server
* ⚡ Triển khai tự động bằng Ansible
* 🚨 Cảnh báo realtime
* 📊 Trực quan hóa chuyên nghiệp

