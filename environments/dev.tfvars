# ── dev environment ───────────────────────────────────────────────────────────
# Usage: terraform apply -var-file=environments/dev.tfvars

azure_subscription_id = "YOUR_SUBSCRIPTION_ID"
environment           = "dev"
location              = "francecentral"

# App Service — cheapest Linux tier for dev
backend_sku_name  = "B1"
backend_always_on = false

# PostgreSQL — burstable, minimum storage
db_sku_name   = "B_Standard_B1ms"
db_storage_mb = 32768
db_name       = "wealthos"

# SWA — free tier sufficient for dev
swa_sku_tier = "Free"

# Secrets — override via env vars or CI:
#   TF_VAR_db_admin_password=...
#   TF_VAR_jwt_secret_key=...
#   TF_VAR_google_client_id=...

tags = {
  team       = "wealthos"
  cost_center = "engineering"
}
