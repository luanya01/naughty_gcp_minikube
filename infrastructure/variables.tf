# Infrastructure Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  default = "asia-east1"
}

variable "zone" {
  default = "asia-east1-b"
}

variable "machine_type" {
  default = "e2-medium"
}