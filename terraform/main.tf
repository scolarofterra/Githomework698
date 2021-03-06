terraform {
 backend "gcs" {
   project = "comp698-tdd1007"
   bucket  = "comp698-tdd1007-terraform-state"
   prefix  = "terraform-state"
 }
}
provider "google" {
  region = "us-central1"
  project = "comp698-tdd1007"
}

resource "google_compute_instance_template" "prod-run" {
  name_prefix  = "prodrun-"
  machine_type = "f1-micro"
  region       = "us-central1"
  tags = ["http-server"]
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_write",
    ]
  }


  // boot disk
  disk {
    source_image = "cos-cloud/cos-stable"
  }
 
  network_interface {
     network = "default"

     access_config {
          // Ephemeral IP
    }
    }

  lifecycle {
    create_before_destroy = true
  }
  metadata {
    gce-container-declaration = <<EOF
spec:
  containers:
  - image: 'gcr.io/comp698-tdd1007 github-scolarofterra-githomework698:48ae42ec9a9deb3d01417111e4c3b56bb2acb546'
    name: service-container
    stdin: false
    tty: false
  restartPolicy: Always
EOF
  }

}

resource "google_compute_instance_group_manager" "prod" {
  name               = "prod"
  instance_template  = "${google_compute_instance_template.prod-run.self_link}"
  base_instance_name = "prod"
  zone               = "us-central1-a"


  target_size        = "2"

}

resource "google_compute_instance_template" "staging-run" {
  name_prefix  = "stagingrun-"
  machine_type = "f1-micro"
  region       = "us-central1"
  tags = ["http-server"]
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_write",
    ]
  }


  // boot disk
  disk {
    source_image = "cos-cloud/cos-stable"
  }
 
  network_interface {
     network = "default"

     access_config {
          // Ephemeral IP
    }
    }

  lifecycle {
    create_before_destroy = true
  }
  metadata {
    gce-container-declaration = <<EOF
spec:
  containers:
  - image: 'gcr.io/comp698-tdd1007/github-scolarofterra-githomework698:9eee7e0eec5aeda2193e5b0dcc14524ae2011889'
    name: service-container
    stdin: false
    tty: false
  restartPolicy: Always
EOF
  }

}

resource "google_compute_instance_group_manager" "staging" {
  name               = "staging"
  instance_template  = "${google_compute_instance_template.staging-run.self_link}"
  base_instance_name = "staging"
  zone               = "us-central1-a"


  target_size        = "1"

}


resource "google_storage_bucket" "image-store" {
  project  = "comp698-tdd1007"
  name     = "makethisbucketgreatagain"
  location = "us-central1"

}

