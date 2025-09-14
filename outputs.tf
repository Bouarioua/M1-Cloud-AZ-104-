output "resource_group_name" {
  value = try(azurerm_resource_group.main.name, null)
}

output "location" {
  value = try(azurerm_resource_group.main.location, null)
}

output "vnet_name" {
  value = try(azurerm_virtual_network.main.name, null)
}

output "subnet_id" {
  value = try(azurerm_subnet.main.id, null)
}

output "nsg_id" {
  value = try(azurerm_network_security_group.vm_nsg.id, null)
}

output "nic_id" {
  value = try(azurerm_network_interface.main.id, null)
}

output "public_ip" {
  value = try(azurerm_public_ip.main.ip_address, null)
}

output "fqdn" {
  value = try(azurerm_public_ip.main.fqdn, null)
}

output "dns_label" {
  value = try(var.dns_label, null)
}

output "vm_name" {
  value = try(azurerm_linux_virtual_machine.main.name, null)
}

output "vm_id" {
  value = try(azurerm_linux_virtual_machine.main.id, null)
}

output "admin_username" {
  value = try(var.admin_username, null)
}

output "private_ip" {
  value = try(azurerm_network_interface.main.ip_configuration[0].private_ip_address, null)
}

output "ssh_command_ip" {
  value = try(
    format("ssh -i ~/.ssh/cloud_tp1 %s@%s", var.admin_username, azurerm_public_ip.main.ip_address),
    null
  )
}

output "ssh_command_fqdn" {
  value = try(
    format("ssh -i ~/.ssh/cloud_tp1 %s@%s", var.admin_username, azurerm_public_ip.main.fqdn),
    null
  )
}

output "storage_account_name" {
  value = try(azurerm_storage_account.main.name, null)
}

output "storage_container_name" {
  value = try(azurerm_storage_container.main.name, null)
}

output "storage_container_url" {
  value = try(
    format("https://%s.blob.core.windows.net/%s",
      azurerm_storage_account.main.name,
      azurerm_storage_container.main.name
    ),
    null
  )
}

output "monitor_action_group_id" {
  value = try(azurerm_monitor_action_group.main.id, null)
}

output "cpu_alert_id" {
  value = try(azurerm_monitor_metric_alert.cpu_alert.id, null)
}

output "ram_alert_id" {
  value = try(azurerm_monitor_metric_alert.ram_alert.id, null)
}

output "key_vault_name" {
  value = try(azurerm_key_vault.main.name, null)
}

output "key_vault_id" {
  value = try(azurerm_key_vault.main.id, null)
}

output "key_vault_secret_name" {
  value = try(azurerm_key_vault_secret.app_secret.name, null)
}

output "key_vault_secret_id" {
  value = try(azurerm_key_vault_secret.app_secret.id, null)
}

output "key_vault_secret_value" {
  value     = try(azurerm_key_vault_secret.app_secret.value, null)
  sensitive = true
}