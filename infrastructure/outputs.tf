# Infrastructure Outputs
output "vm_ssh_command" {
  value = "gcloud compute ssh minikube-lab --zone=${var.zone}"
  description = "Run this command to SSH into your VM"
}

output "vm_external_ip" {
  value = google_compute_instance.k8s_vm.network_interface.0.access_config.0.nat_ip
}