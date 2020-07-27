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

resource "google_pubsub_topic" "topic-from" {
  name = "topic-from"
}

resource "google_pubsub_topic" "topic-to" {
  name = "topic-to"
}

resource "google_cloud_scheduler_job" "job" {
  name        = "minutely"
  description = "minutely"
  schedule    = "*/1 * * * *"

  pubsub_target {
    topic_name = google_pubsub_topic.topic-from.id
    data       = base64encode("test")
  }
}

resource "google_cloudfunctions_function" "function" {
  name        = "filter-holidays"
  description = "filter holidays"
  runtime     = "go113"

  available_memory_mb   = 128
  entry_point           = "Filter"

	event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = "${google_pubsub_topic.topic-from.name}"
  }

  enviroment_variables = {
    GCP_PROJECT = var.PROJECT
    TARGET_TOPIC = "${google_pubsub_topic.topic-to.name}"
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
