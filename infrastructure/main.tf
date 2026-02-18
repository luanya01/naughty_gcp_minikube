# infrastructure/main.tf

# 引用變數
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "k8s_firewall" {
  name    = "allow-k8s-dev"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3000-9000", "30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["minikube-node"]
}

resource "google_compute_instance" "k8s_vm" {
  name         = "minikube-lab"
  machine_type = var.machine_type
  tags         = ["minikube-node"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  # 這裡改用 file 讀取，讓 main.tf 不會被 shell script 塞爆
  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  service_account {
    scopes = ["cloud-platform"]
  }
}