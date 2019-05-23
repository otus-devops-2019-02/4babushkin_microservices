terraform {
  # Версия terraform
  required_version = "0.11.11"
}

provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_address" "static-ip-address" {
  name = "my-static-ip-address"
}


module "vpc" {
  source        = "modules/vpc"
  source_ranges = ["46.182.0.0/16"]
  target_tags = ["gitlab", "docker-machine"]
}

resource "google_compute_instance" "gitlab" {
  name         = "gitlab-cl"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"
  tags         = ["gitlab"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
      size  = 50
    }
  }




  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {
      nat_ip = "${google_compute_address.static-ip-address.address}"
    }
  }

  metadata {
    # путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

    # путь до приватного ключа
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "files/docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
  }

  provisioner "remote-exec" {
    script = "files/docker_install.sh"
    
  }

  provisioner "remote-exec" {
    script = "files/start-compose.sh"
  }

}


resource "google_compute_firewall" "firewall_gitlab" {
  name = "allow-gitlab-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["gitlab"]
}

