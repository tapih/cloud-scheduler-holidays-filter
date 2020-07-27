variable "PROJECT" {}
variable "ZONE" {}
variable "REGION" {}

provider "google" {
  project = var.PROJECT
  region = var.REGION
  zone = var.ZONE
}

resource "google_storage_bucket" "terraform-state-store" {
  name     = "tfstate-bucket"
  location = var.REGION
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 3
    }
  }
}

terraform {
  backend "gcs" {
    bucket  = "tfstate-bucket"
  }
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}
