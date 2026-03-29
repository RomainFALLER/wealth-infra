# Changelog

## [0.2.0] - 2026-03-29

### Features
- Add `FRONTEND_URL` app setting for Open Banking OAuth callback redirect
- Add Enable Banking secrets to Key Vault (`enable-banking-private-key`)
- Add Enable Banking app settings: `ENABLE_BANKING_APP_ID`, `ENABLE_BANKING_PRIVATE_KEY_PEM`, `ENABLE_BANKING_REDIRECT_URL`

### Bug Fixes
- Fix `terraform fmt` alignment across `main.tf`, `environments/dev.tfvars`, `environments/prod.tfvars`

## [0.1.0] - 2026-03-26

### Features
- Initial Terraform infrastructure for WealthOS (Azure)
- Resource group, Log Analytics workspace, Application Insights
- Key Vault with managed identity access policies and secrets (`jwt-secret-key`, `db-admin-password`, `database-url`)
- MySQL Flexible Server with database and App Service firewall rule
- App Service Plan + Linux Web App (Docker/ACR deployment, system-assigned identity, Key Vault references)
- Static Web App for Angular frontend
- Dev and prod environment variable files (`environments/dev.tfvars`, `environments/prod.tfvars`)
- Migrate to Docker/ACR deployment with custom domain CORS (`dev.wealthy-app.com`, `wealthy-app.com`)
