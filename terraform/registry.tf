resource "yandex_container_registry" "image-registry" {
  name      = "image-registry"
  folder_id = "b1gns3a84pvt7rd1h1vn"
  labels = {
    my-label = "registry"
  }
}

# Для скачивания образов сделаем отдельный сервисный аккаунт для k8s
resource "yandex_iam_service_account" "k8s-sa" {
  name = "k8s-service-account"
}

# Созадим ключ для доступа к аккаунту k8s
resource "yandex_iam_service_account_key" "k8s-sa-key" {
  service_account_id = yandex_iam_service_account.k8s-sa.id
  description        = "k8s-service-account-key"
  depends_on = [
    yandex_iam_service_account.k8s-sa
  ]
}

# Привяжем сервисный аккаунт для k8s к роли для pull образов
resource "yandex_container_registry_iam_binding" "k8s-role-puller" {
  registry_id = yandex_container_registry.image-registry.id
  role        = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
  depends_on = [
    yandex_container_registry.image-registry,
    yandex_iam_service_account.k8s-sa,
  ]
}

# CI\CD

# Для загрузки образа после сборки в CI\CD создаем отдельный сервисный аккаунт
resource "yandex_iam_service_account" "ci-cd" {
  name = "ci-cd-service-account"
}

# Созадим ключ для доступа к аккаунту ci-cd
resource "yandex_iam_service_account_key" "ci-cd-key" {
  service_account_id = yandex_iam_service_account.ci-cd.id
  description        = "ci-cd-service-account-key"
  depends_on = [
    yandex_iam_service_account.ci-cd
  ]
}

# Привяжем сервисный аккаунт для ci-cd к роли для push образов
resource "yandex_container_registry_iam_binding" "ci-cd-role-pusher" {
  registry_id = yandex_container_registry.image-registry.id
  role        = "container-registry.images.pusher"
  members     = ["serviceAccount:${yandex_iam_service_account.ci-cd.id}"]
  depends_on = [
    yandex_container_registry.image-registry,
    yandex_iam_service_account.ci-cd,
  ]
}
