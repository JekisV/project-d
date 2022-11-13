variable "WORKSPACE_NAME" {
  type    = string
  default = "stage"
}

locals {
  workspace = var.WORKSPACE_NAME != "" ? trimprefix("${var.WORKSPACE_NAME}", "space-") : "${var.WORKSPACE_NAME}"

  name = {
    stage = "stage"
    prod  = "prod"
  }

  networks = [
    {
      name      = "a"
      zone_name = "ru-central1-a"
      subnet    = ["10.128.0.0/24"]
    },
    {
      name      = "b"
      zone_name = "ru-central1-b"
      subnet    = ["10.129.0.0/24"]
    },
    {
      name      = "c"
      zone_name = "ru-central1-c"
      subnet    = ["10.130.0.0/24"]
    }
  ]
}

# Создаем VPC
resource "yandex_vpc_network" "vpc" {
  name = "${local.name[local.workspace]}-vpc"
}

#Создаем подсети на основе переменных locals
resource "yandex_vpc_subnet" "public" {
  count          = length(local.networks)
  v4_cidr_blocks = local.networks[count.index].subnet
  zone           = local.networks[count.index].zone_name
  network_id     = yandex_vpc_network.vpc.id
  name           = "${local.networks[count.index].name}-subnet"
}
