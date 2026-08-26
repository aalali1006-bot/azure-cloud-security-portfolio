resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  resource_prefix      = "${var.project_name}-${var.environment}"
  storage_account_name = substr(replace("st${var.project_name}${var.environment}${random_string.suffix.result}", "-", ""), 0, 24)

  common_tags = {
    Project     = "secure-azure-workload-lab"
    Environment = var.environment
    ManagedBy   = "Terraform"
    DataClass   = "No production data"
  }
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-${local.resource_prefix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_log_analytics_workspace" "lab" {
  name                = "law-${local.resource_prefix}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_storage_account" "web" {
  name                              = local.storage_account_name
  resource_group_name               = azurerm_resource_group.lab.name
  location                          = azurerm_resource_group.lab.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = false
  shared_access_key_enabled         = false
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = local.common_tags
}

resource "azurerm_key_vault" "lab" {
  name                          = "kv-${local.resource_prefix}-${random_string.suffix.result}"
  location                      = azurerm_resource_group.lab.location
  resource_group_name           = azurerm_resource_group.lab.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = false

  tags = local.common_tags
}

output "resource_group_name" {
  value       = azurerm_resource_group.lab.name
  description = "Name der bereitgestellten Resource Group."
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.lab.id
  description = "Resource ID des Log-Analytics-Workspace."
}

output "key_vault_name" {
  value       = azurerm_key_vault.lab.name
  description = "Name des Key Vault; enthält keine Secrets nach dem Deployment."
}
