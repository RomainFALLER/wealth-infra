# ── Resource Group ────────────────────────────────────────────────────────────

output "resource_group_name" {
  description = "Name of the main resource group."
  value       = azurerm_resource_group.main.name
}

# ── Backend ───────────────────────────────────────────────────────────────────

output "backend_url" {
  description = "Public URL of the FastAPI App Service."
  value       = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "backend_name" {
  description = "App Service name (used for az webapp deploy)."
  value       = azurerm_linux_web_app.backend.name
}

output "backend_principal_id" {
  description = "Managed identity principal ID of the App Service."
  value       = azurerm_linux_web_app.backend.identity[0].principal_id
}

# ── Frontend ──────────────────────────────────────────────────────────────────

output "frontend_url" {
  description = "Public URL of the Static Web App."
  value       = "https://${azurerm_static_web_app.frontend.default_host_name}"
}

output "frontend_api_key" {
  description = "SWA deployment API key — add to GitHub Actions secret AZURE_STATIC_WEB_APPS_API_TOKEN."
  value       = azurerm_static_web_app.frontend.api_key
  sensitive   = true
}

# ── Database ──────────────────────────────────────────────────────────────────

output "db_fqdn" {
  description = "MySQL Flexible Server FQDN."
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "db_name" {
  description = "Application database name."
  value       = azurerm_mysql_flexible_database.app.name
}

# ── Key Vault ─────────────────────────────────────────────────────────────────

output "key_vault_name" {
  description = "Key Vault name."
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = azurerm_key_vault.main.vault_uri
}

# ── Monitoring ────────────────────────────────────────────────────────────────

output "app_insights_connection_string" {
  description = "Application Insights connection string."
  value       = azurerm_application_insights.backend.connection_string
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key (legacy)."
  value       = azurerm_application_insights.backend.instrumentation_key
  sensitive   = true
}
