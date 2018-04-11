terraform {
 backend "gcs" {
   project = "comp698-tdd1007"
   bucket  = "comp698-tdd1007-terraform-state"
   prefix  = "terraform-state"
 }
}
provider "google" {
  region = "us-central1"
}

resource "google_compute_instance_template" "tdd1007-template-server" {
  name  = "tdd1007-template-server"
  machine_type = "f1-micro"
  region       = "us-central1"

  // boot disk
  disk {
    source_image = "cos-stable"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "tdd1007-watcher-server" {
  name               = "tdd1007-watcher-server"
  instance_template  = "${google_compute_instance_template.instance_template.self_link}"
  base_instance_name = "tf-server"
  zone               = "us-central1-a"
  target_size        = "1"
}