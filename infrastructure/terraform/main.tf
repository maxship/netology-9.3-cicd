terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.68.0"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1g3me49qkcgicgvrgv2"
  folder_id = "b1g4fb7qmqpe9rvo57q2"
  zone      = "ru-central1-a"
}

# Инстанс Sonar
resource "yandex_compute_instance" "sonar01" {
  name = "sonar-01"
  platform_id = "standard-v1"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd88d018b9a937uli9bn" # Centos-7
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.elk-subnet.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }  
}

# Инстанс Nexus
resource "yandex_compute_instance" "nexus01" {
  name = "nexus-01"
  platform_id = "standard-v1"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd88d018b9a937uli9bn" # Centos-7
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet01.id}"
    nat       = true
  }

  metadata = {
    #user-data = "${file("./meta.txt")}"
    ssh-keys: "~/.ssh/id_ed25519.pub"
  }  
}

resource "yandex_vpc_network" "network01" {
  name = "network-01"
}

resource "yandex_vpc_subnet" "subnet01" {
  name       = "subnet-01"
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.network01.id}"
}