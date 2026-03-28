# ── Locals ────────────────────────────────────────────────────────────────────

locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    {
      project     = var.project
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags,
  )
}

# Random suffix for globally-unique resource names (Key Vault, PostgreSQL, etc.)
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# ── Resource Group ────────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# ── Log Analytics + Application Insights ─────────────────────────────────────

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prod" ? 90 : 30
  tags                = local.common_tags
}

resource "azurerm_application_insights" "backend" {
  name                = "appi-${local.name_prefix}-backend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = local.common_tags
}

# ── Key Vault ─────────────────────────────────────────────────────────────────

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "kv-${var.project}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = var.environment == "prod"

  tags = local.common_tags
}

# Terraform operator access — needed to write secrets below
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

# App Service managed identity access (read-only)
resource "azurerm_key_vault_access_policy" "backend" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.backend.identity[0].principal_id

  secret_permissions = ["Get", "List"]

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# ── Key Vault Secrets ─────────────────────────────────────────────────────────

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret-key"
  value        = var.jwt_secret_key
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.terraform]
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-admin-password"
  value        = var.db_admin_password
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.terraform]
}

resource "azurerm_key_vault_secret" "enable_banking_private_key" {
  name         = "enable-banking-private-key"
  value        = var.enable_banking_private_key_pem
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.terraform]
}

resource "azurerm_key_vault_secret" "db_url" {
  name  = "database-url"
  value = "mysql+aiomysql://${var.db_admin_login}:${var.db_admin_password}@${azurerm_mysql_flexible_server.main.fqdn}:3306/${var.db_name}"
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.terraform]
}

# ── MySQL Flexible Server ─────────────────────────────────────────────────────

resource "azurerm_mysql_flexible_server" "main" {
  name                   = "mysql-${local.name_prefix}-${random_string.suffix.result}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = var.db_version
  administrator_login    = var.db_admin_login
  administrator_password = var.db_admin_password
  sku_name               = var.db_sku_name
  backup_retention_days  = var.environment == "prod" ? 35 : 7

  storage {
    size_gb = var.db_storage_gb
  }

  tags = local.common_tags
}

resource "azurerm_mysql_flexible_database" "app" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Allow App Service outbound IPs to reach MySQL
resource "azurerm_mysql_flexible_server_firewall_rule" "app_service" {
  name                = "allow-app-service"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0" # Azure services — replace with App Service outbound IPs for prod
}

# ── App Service Plan ──────────────────────────────────────────────────────────

resource "azurerm_service_plan" "backend" {
  name                = "asp-${local.name_prefix}-backend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.backend_sku_name
  tags                = local.common_tags
}

# ── App Service (FastAPI backend) ─────────────────────────────────────────────

resource "azurerm_linux_web_app" "backend" {
  name                = "app-${local.name_prefix}-backend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.backend.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on        = var.backend_always_on
    ftps_state       = "Disabled"
    http2_enabled    = true
    minimum_tls_version = "1.2"

    application_stack {
      docker_image_name        = "backend:latest"
      docker_registry_url      = "https://${var.acr_login_server}"
      docker_registry_username = var.acr_username
      docker_registry_password = var.acr_password
    }

    app_command_line = "" # Docker CMD used instead
  }

  app_settings = {
    # Runtime
    APP_ENV   = var.environment
    APP_DEBUG = var.environment == "prod" ? "false" : "true"

    # Database — pulled from Key Vault at runtime via managed identity
    DATABASE_URL = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=database-url)"

    # JWT
    JWT_SECRET_KEY               = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=jwt-secret-key)"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES = "15"
    JWT_REFRESH_TOKEN_EXPIRE_DAYS   = "7"

    # Google OAuth
    GOOGLE_CLIENT_ID = var.google_client_id

    # CORS — FastAPI handles CORS; list all allowed frontend origins
    ALLOWED_ORIGINS = var.environment == "prod" ? "https://wealthy-app.com,https://www.wealthy-app.com" : "http://localhost:4200,https://dev.wealthy-app.com"

    # Enable Banking (PSD2 / Open Banking)
    ENABLE_BANKING_APP_ID          = var.enable_banking_app_id
    ENABLE_BANKING_PRIVATE_KEY_PEM = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=enable-banking-private-key)"
    ENABLE_BANKING_REDIRECT_URL    = var.environment == "prod" ? "https://api.wealthy-app.com/api/v1/open-banking/callback" : "https://api-dev.wealthy-app.com/api/v1/open-banking/callback"

    # Application Insights
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.backend.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"

    # Docker — disable Oryx build
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "false"
    ENABLE_ORYX_BUILD                   = "false"
  }

  logs {
    application_logs {
      file_system_level = "Warning"
    }
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
    detailed_error_messages = var.environment != "prod"
    failed_request_tracing  = var.environment != "prod"
  }

  tags = local.common_tags

  depends_on = [azurerm_mysql_flexible_server.main]
}

# ── Static Web App (Angular frontend) ────────────────────────────────────────

resource "azurerm_static_web_app" "frontend" {
  name                = "swa-${local.name_prefix}-frontend"
  location            = var.swa_location # SWA not available in francecentral
  resource_group_name = azurerm_resource_group.main.name
  sku_tier            = var.swa_sku_tier
  sku_size            = var.swa_sku_tier

  tags = local.common_tags
}
