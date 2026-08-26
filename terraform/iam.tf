# Rollen werden Gruppen statt Einzelpersonen zugewiesen.
# Dadurch bleiben Ein- und Austritte nachvollziehbar und die Anzahl direkter Zuweisungen gering.[1]

locals {
  roles = {
    contributor             = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    reader                  = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
    key_vault_secrets_user  = "4633458b-17de-408a-b874-0445c86b69e6"
    key_vault_administrator = "00482a5a-887f-4fb3-b363-3b7fe8e74483"
  }
}

# Entwickler können Ressourcen im Lab pflegen, aber keine Rollenzuweisungen erstellen.
resource "azurerm_role_assignment" "developer_contributor" {
  scope                            = azurerm_resource_group.lab.id
  role_definition_id               = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.contributor}"
  principal_id                     = var.developer_group_object_id
  principal_type                   = "Group"
  skip_service_principal_aad_check = true
}

# Leser dürfen die Konfiguration einsehen, jedoch nichts verändern.
resource "azurerm_role_assignment" "reader" {
  scope                            = azurerm_resource_group.lab.id
  role_definition_id               = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.reader}"
  principal_id                     = var.reader_group_object_id
  principal_type                   = "Group"
  skip_service_principal_aad_check = true
}

# Security Operators erhalten nur Leserechte auf der Resource Group.
resource "azurerm_role_assignment" "security_operator_reader" {
  scope                            = azurerm_resource_group.lab.id
  role_definition_id               = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.reader}"
  principal_id                     = var.security_operator_group_object_id
  principal_type                   = "Group"
  skip_service_principal_aad_check = true
}

# Ein separater, enger Scope erlaubt die Administration von Key-Vault-Objekten im Lab.
resource "azurerm_role_assignment" "security_operator_key_vault_admin" {
  scope                            = azurerm_key_vault.lab.id
  role_definition_id               = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.key_vault_administrator}"
  principal_id                     = var.security_operator_group_object_id
  principal_type                   = "Group"
  skip_service_principal_aad_check = true
}

# Eine App-Identity würde nur diese Rolle am Vault erhalten; sie wird hier nicht erstellt.
# resource "azurerm_role_assignment" "workload_secrets_reader" {
#   scope              = azurerm_key_vault.lab.id
#   role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.key_vault_secrets_user}"
#   principal_id       = azurerm_user_assigned_identity.workload.principal_id
# }

# [1] https://learn.microsoft.com/en-us/azure/role-based-access-control/best-practices
