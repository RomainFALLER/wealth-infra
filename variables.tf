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

variable "backend_python_version" {
  description = "Python version for the FastAPI App Service."
  type        = string
  default     = "3.12"
}

variable "backend_always_on" {
  description = "Keep App Service always on (recommended for prod, disable for dev to save cost)."
  type        = bool
  default     = false
}

# ── Database ──────────────────────────────────────────────────────────────────

variable "db_sku_name" {
  description = "PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_storage_mb" {
  description = "PostgreSQL storage in MB."
  type        = number
  default     = 32768 # 32 GB
}

variable "db_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
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

# ── Frontend (SWA) ────────────────────────────────────────────────────────────

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
