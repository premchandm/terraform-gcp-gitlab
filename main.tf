provider "google" {
  project = var.project
  region  = var.region
  credentials = file(var.credentials_file)
}
resource "google_compute_firewall" "firewall" {
  name    = "firewall-externalssh"
  project = var.project
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["ssh"]
}
resource "google_compute_firewall" "webserverrule" {
  name    = "webserver"
  project = var.project
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["webserver"]
}
# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name = "vm-public-address"
  project = var.project
  region = var.region
  depends_on = [ google_compute_firewall.firewall ]
}
resource "google_compute_instance" "webserver" {
  name         = "webserver"
  machine_type = "e2-medium"
  zone         = "${var.region}-c"
  tags         = ["externalssh","webserver"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static.address
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = file(var.privatekeypath)
    }
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install git",
      "sudo apt-get -y install nginx",
      "sudo nginx -v",
      "sudo git clone https://github.com/schoolofdevops/html-sample-app.git",
      "sudo mv html-sample-app/* /var/www/html/",
    ]
  }
  # Ensure firewall rule is provisioned before server, so that SSH doesn't fail.
  depends_on = [ google_compute_firewall.firewall, google_compute_firewall.webserverrule ]
  service_account {
    email  = var.email
    scopes = ["compute-ro"]
  }
  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }
}
