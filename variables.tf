# ── Azure ─────────────────────────────────────────────────────────────────────

variable "azure_subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "francecentral"
}

# ── Project ───────────────────────────────────────────────────────────────────

variable "project" {
  description = "Short project identifier used in resource names."
  type        = string
  default     = "wealthos"
}

variable "environment" {
  description = "Deployment environment: dev | staging | prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}

# ── Backend ───────────────────────────────────────────────────────────────────

variable "backend_sku_name" {
  description = "App Service Plan SKU. B1 for dev, P1v3 for prod."
  type        = string
  default     = "B1"
}

variable "backend_always_on" {
  description = "Keep App Service always on (recommended for prod, disable for dev to save cost)."
  type        = bool
  default     = false
}

# ── Database ──────────────────────────────────────────────────────────────────

variable "db_sku_name" {
  description = "MySQL Flexible Server SKU. B_Standard_B1ms is the cheapest burstable tier."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_storage_gb" {
  description = "MySQL storage in GB (minimum 20)."
  type        = number
  default     = 20
}

variable "db_version" {
  description = "MySQL major version."
  type        = string
  default     = "8.0.21"
}

variable "db_admin_login" {
  description = "PostgreSQL administrator username."
  type        = string
  default     = "wealthadmin"
}

variable "db_admin_password" {
  description = "PostgreSQL administrator password. Store in Key Vault / CI secret."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the application database."
  type        = string
  default     = "wealthos"
}

# ── Secrets (injected at runtime via Key Vault) ───────────────────────────────

variable "jwt_secret_key" {
  description = "JWT signing secret. Must be at least 32 chars."
  type        = string
  sensitive   = true
}

variable "google_client_id" {
  description = "Google OAuth Client ID for social login."
  type        = string
  default     = ""
}

# ── Enable Banking (PSD2 / Open Banking) ──────────────────────────────────────

variable "enable_banking_app_id" {
  description = "Enable Banking application ID."
  type        = string
  default     = ""
}

variable "enable_banking_private_key_pem" {
  description = "RSA private key (PEM) for Enable Banking JWT auth."
  type        = string
  sensitive   = true
  default     = ""
}

# ── AI / Chat ────────────────────────────────────────────────────────────────

variable "anthropic_api_key" {
  description = "Anthropic API key for the AI chat assistant."
  type        = string
  sensitive   = true
  default     = ""
}

variable "openai_api_key" {
  description = "OpenAI API key (alternative provider for AI chat)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "chat_provider" {
  description = "LLM provider for chat: anthropic or openai."
  type        = string
  default     = "anthropic"
}

variable "chat_model" {
  description = "LLM model name, e.g. claude-sonnet-4-20250514 or gpt-4o-mini."
  type        = string
  default     = "claude-sonnet-4-20250514"
}

# ── Frontend (SWA) ────────────────────────────────────────────────────────────

variable "swa_location" {
  description = "Region for the Static Web App. Must be one of: westus2, centralus, eastus2, westeurope, eastasia."
  type        = string
  default     = "westeurope"
}

variable "swa_sku_tier" {
  description = "Static Web App SKU tier: Free | Standard"
  type        = string
  default     = "Free"
}

variable "github_repo_token" {
  description = "GitHub personal access token for SWA repository integration."
  type        = string
  sensitive   = true
  default     = ""
}

# ── Container Registry (ACR) ──────────────────────────────────────────────────

variable "acr_login_server" {
  description = "ACR login server hostname, e.g. crwealthosdev.azurecr.io"
  type        = string
}

variable "acr_username" {
  description = "ACR admin username (enable admin user on the registry)."
  type        = string
}

variable "acr_password" {
  description = "ACR admin password."
  type        = string
  sensitive   = true
}
