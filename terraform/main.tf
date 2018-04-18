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

resource "google_compute_instance_template" "tdd1007-template-server" {
  name_prefix  = "tdd1007templateserver-"
  machine_type = "f1-micro"
  region       = "us-central1"

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
    	image: 'gcr.io/comp698-tdd1007/github-scolarofterra-githomework698:48ae42ec9a9deb3d01417111e4c3b56bb2acb546'
    	name: service-container
    	stdin: false
    	tty: false
  	restartPolicy: Always
EOF
  }

}

resource "google_compute_instance_group_manager" "tdd1007-watcher-server" {
  name               = "tdd1007-watcher-server"
  instance_template  = "${google_compute_instance_template.tdd1007-template-server.self_link}"
  base_instance_name = "tdd1007-watcher-server"
  zone               = "us-central1-a"
  target_size        = "1"
}


resource "google_storage_bucket" "image-store" {
  project  = "comp698-tdd1007"
  name     = "makethisbucketgreatagain"
  location = "us-central1"
}