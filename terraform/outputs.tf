output "public_ips" {
  value = {
    for name, ip in azurerm_public_ip.pip :
    name => ip.ip_address
  }
}

output "private_ips" {
  value = {
    for name, nic in azurerm_network_interface.nic :
    name => nic.private_ip_address
  }
}

output "ssh_commands" {
  value = {
    for name, ip in azurerm_public_ip.pip :
    name => "ssh ${var.admin_username}@${ip.ip_address}"
  }
}
