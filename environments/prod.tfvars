# ── prod environment ──────────────────────────────────────────────────────────
# Usage: terraform apply -var-file=environments/prod.tfvars

azure_subscription_id = "YOUR_SUBSCRIPTION_ID"
environment           = "prod"
location              = "francecentral"

# App Service — Premium v3 for auto-scaling and VNet integration
backend_sku_name  = "P1v3"
backend_always_on = true

# PostgreSQL — General Purpose, 2 vCores, zone-redundant HA
db_sku_name   = "GP_Standard_D2s_v3"
db_storage_mb = 131072 # 128 GB
db_name       = "wealthos"

# SWA — Standard for custom domains + staging slots
swa_sku_tier = "Standard"

tags = {
  team        = "wealthos"
  cost_center = "engineering"
  criticality  = "high"
}
