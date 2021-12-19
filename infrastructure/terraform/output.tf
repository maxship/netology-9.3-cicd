output "external_ip_sonar01" {
  value = yandex_compute_instance.sonar01.network_interface.0.nat_ip_address
}

output "external_ip_nexus01" {
  value = yandex_compute_instance.nexus01.network_interface.0.nat_ip_address
}