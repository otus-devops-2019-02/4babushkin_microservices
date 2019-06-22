#
# Variables
#
variable "project" {
  default = "docker-239201"
}

variable "region" {
  default = "eu-west1-d"
}

variable "cluster_name" {
  default = "reddit-cluster-terraform"
}

variable "cluster_zone" {
  default = "europe-west1-d"
}

variable "cluster_k8s_version" {
  default = "1.12.8-gke.6"
}

variable "initial_node_count" {
  default = 2
}

variable "autoscaling_min_node_count" {
  default = 1
}

variable "autoscaling_max_node_count" {
  default = 2
}

variable "disk_size_gb" {
  default = 20
}

variable "disk_type" {
  default = "pd-standard"
}

variable "machine_type" {
  default = "g1-small"
}
