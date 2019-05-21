# vpc.tf
resource "google_compute_firewall" "firewall_ssh" {
  name        = "my-allow-ssh"
  network     = "default"
  description = "Allow SSH from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["22", "2376"]
  }

  source_ranges = "${var.source_ranges}"
  target_tags = "${var.target_tags}"
}
