#K8S Cluster

locals {
  # Задаем локальные переменные для ресурсов кластера k8s
  k8s = {
    image_id    = "fd8ic7gsa68ka13650ld" #ubuntu 22.04 - собран свой образ через Packer
    preemptible = false
    disk_type   = "network-hdd"
    platform_id = "standard-v3"
    stage = {
      controls = {
        count         = 1
        cpu           = 2
        memory        = 4
        core_fraction = 20
        disk_size     = 20
      }
      workers = {
        count         = 3
        cpu           = 2
        memory        = 4
        core_fraction = 20
        disk_size     = 20
      }
      prod = {
        controls = {
          count         = 3
          cpu           = 4
          memory        = 4
          core_fraction = 20
          disk_size     = 20
        }
        workers = {
          count         = 3
          cpu           = 2
          memory        = 2
          core_fraction = 20
          disk_size     = 15
        }
      }
    }
  }
}

# Создание инстансов k8s control node с параметрами из locals
resource "yandex_compute_instance" "kube_control_plane" {
  count       = local.k8s[local.workspace].controls.count
  name        = "kube-control-plane-${count.index}"
  platform_id = local.k8s.platform_id
  hostname    = "kube-control-plane-${count.index}"
  zone        = local.networks[count.index - floor(count.index / length(local.networks)) * length(local.networks)].zone_name

  resources {
    cores         = local.k8s[local.workspace].controls.cpu
    memory        = local.k8s[local.workspace].controls.memory
    core_fraction = local.k8s[local.workspace].controls.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = local.k8s.image_id
      type     = local.k8s.disk_type
      size     = local.k8s[local.workspace].controls.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public[count.index - floor(count.index / length(local.networks)) * length(local.networks)].id
    nat       = true
  }

  scheduling_policy {
    preemptible = local.k8s.preemptible
  }

  metadata = {
    user-data = "${file("./user.txt")}"
  }
}

# Создание инстанса k8s для worker node с параметрами из locals
resource "yandex_compute_instance" "kube_node" {
  count       = local.k8s[local.workspace].workers.count
  name        = "kube-node-${count.index}"
  platform_id = local.k8s.platform_id
  hostname    = "kube-node-${count.index}"
  zone        = local.networks[count.index - floor(count.index / length(local.networks)) * length(local.networks)].zone_name

  resources {
    cores         = local.k8s[local.workspace].workers.cpu
    memory        = local.k8s[local.workspace].workers.memory
    core_fraction = local.k8s[local.workspace].workers.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = local.k8s.image_id
      type     = local.k8s.disk_type
      size     = local.k8s[local.workspace].workers.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public[count.index - floor(count.index / length(local.networks)) * length(local.networks)].id
    nat       = true
  }

  scheduling_policy {
    preemptible = local.k8s.preemptible
  }

  metadata = {
    user-data = "${file("./user.txt")}"
  }
}
