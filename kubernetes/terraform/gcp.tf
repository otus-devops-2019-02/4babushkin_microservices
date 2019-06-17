#
# Google Cloud Platform
#
provider "google" {
  # version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}
