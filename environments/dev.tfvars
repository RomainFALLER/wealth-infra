# ── dev environment ───────────────────────────────────────────────────────────
# Usage: terraform apply -var-file=environments/dev.tfvars

azure_subscription_id = "92fdaf24-80b1-4166-b6c4-dec00e80cad0"
environment           = "dev"
location              = "francecentral"

# App Service — cheapest Linux tier for dev
backend_sku_name  = "B1"
backend_always_on = false

# MySQL — burstable, minimum storage (20 GB)
db_sku_name   = "B_Standard_B1ms"
db_storage_gb = 20
db_name       = "wealthos"

# SWA — free tier, westeurope (francecentral not supported for staticSites)
swa_location = "westeurope"
swa_sku_tier = "Free"

# ACR
acr_login_server = "crwealthosdev.azurecr.io"
# acr_username and acr_password: override via TF_VAR_acr_username / TF_VAR_acr_password

# Enable Banking — prod API used in dev for real bank testing
enable_banking_app_id = "226b8ea4-b037-405c-a9d9-3c1f8ee3470c"
# Private key: TF_VAR_enable_banking_private_key_pem=...

# AI / Chat
chat_provider = "anthropic"
chat_model    = "claude-sonnet-4-20250514"
# API keys: TF_VAR_anthropic_api_key=... / TF_VAR_openai_api_key=...

# Secrets — override via env vars or CI:
#   TF_VAR_db_admin_password=...
#   TF_VAR_jwt_secret_key=...
#   TF_VAR_google_client_id=...
#   TF_VAR_acr_username=...
#   TF_VAR_acr_password=...
#   TF_VAR_enable_banking_private_key_pem=...

tags = {
  team        = "wealthos"
  cost_center = "engineering"
}
