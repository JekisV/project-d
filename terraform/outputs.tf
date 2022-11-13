output "kube_control_plane" {
  value = yandex_compute_instance.kube_control_plane.*.network_interface.0.nat_ip_address
}

output "kube_control_plane_IP" {
  value = yandex_compute_instance.kube_control_plane.*.network_interface.0.ip_address
}

output "kube_node" {
  value = yandex_compute_instance.kube_node.*.network_interface.0.nat_ip_address
}

output "kube_node_IP" {
  value = yandex_compute_instance.kube_node.*.network_interface.0.ip_address
}

output "container_registry" {
  value = "cr.yandex/${yandex_container_registry.image-registry.id}"
}

output "k8s-sa-key" {
  value = {
    id                 = yandex_iam_service_account_key.k8s-sa-key.id
    service_account_id = yandex_iam_service_account_key.k8s-sa-key.service_account_id
    created_at         = yandex_iam_service_account_key.k8s-sa-key.created_at
    key_algorithm      = yandex_iam_service_account_key.k8s-sa-key.key_algorithm
    public_key         = yandex_iam_service_account_key.k8s-sa-key.public_key
    private_key        = yandex_iam_service_account_key.k8s-sa-key.private_key
  }
  sensitive = true
}

output "ci-cd-key" {
  value = {
    id                 = yandex_iam_service_account_key.ci-cd-key.id
    service_account_id = yandex_iam_service_account_key.ci-cd-key.service_account_id
    created_at         = yandex_iam_service_account_key.ci-cd-key.created_at
    key_algorithm      = yandex_iam_service_account_key.ci-cd-key.key_algorithm
    public_key         = yandex_iam_service_account_key.ci-cd-key.public_key
    private_key        = yandex_iam_service_account_key.ci-cd-key.private_key
  }
  sensitive = true
}
