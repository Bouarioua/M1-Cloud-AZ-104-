variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westeurope"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "dns_label" {
  type        = string
  description = "Label DNS (minuscule, chiffres, tirets), unique dans la région"

}

variable "storage_account_name" {
  description = "Nom globalement unique (3-24, minuscules/chiffres) du Storage Account"
  type        = string
}

variable "storage_container_name" {
  description = "Nom du conteneur (minuscules/chiffres/-, <=63)"
  type        = string
}

variable "alert_email_address" {
  description = "Adresse email pour recevoir les alertes"
  type        = string
}

data "azurerm_client_config" "current" {}

variable "key_vault_name" {
  type        = string
  description = "Nom unique pour la Key Vault (3-24 caractères, minuscules et chiffres seulement)"
}