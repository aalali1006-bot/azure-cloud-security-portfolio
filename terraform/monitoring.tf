# Resource Logs sind nicht standardmäßig aktiviert. Diese Diagnostic Settings
# leiten Security-relevante Daten in Log Analytics weiter.[1]
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "diag-keyvault-audit"
  target_resource_id         = azurerm_key_vault.lab.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id

  enabled_log {
    category_group = "audit"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage" {
  name                       = "diag-storage-blob"
  target_resource_id         = "${azurerm_storage_account.web.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id

  enabled_log {
    category_group = "audit"
  }

  enabled_metric {
    category = "Transaction"
  }
}

# Beispielalarm: mindestens drei verweigerte Key-Vault-Aufrufe in einer Stunde.
# Die Query ist bewusst eng auf das Lab beschränkt und kann je Umgebung angepasst werden.
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "key_vault_denied" {
  name                = "alert-keyvault-denied-operations"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  scopes              = [azurerm_log_analytics_workspace.lab.id]
  severity            = 2
  enabled             = true

  evaluation_frequency = "PT15M"
  window_duration      = "PT1H"

  criteria {
    query                   = <<-QUERY
      AzureDiagnostics
      | where ResourceProvider == "MICROSOFT.KEYVAULT"
      | where OperationName has "SecretGet" or OperationName has "SecretList"
      | where ResultType !in ("Success", "Succeeded")
      | summarize FailedOperations = count() by bin(TimeGenerated, 15m), CallerIPAddress
    QUERY
    time_aggregation_method = "Count"
    threshold               = 3
    operator                = "GreaterThanOrEqual"
  }

  tags = local.common_tags
}

# [1] https://learn.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings
