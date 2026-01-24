output "master_public_ip" {
  value = azurerm_public_ip.pip["master"].ip_address
  description = "IP publique du master Kubernetes"
}

output "worker_public_ips" {
  value = [
    for name, ip in azurerm_public_ip.pip : ip.ip_address
    if name != "master"
  ]
  description = "Liste des IPs publiques des workers Kubernetes"
}
