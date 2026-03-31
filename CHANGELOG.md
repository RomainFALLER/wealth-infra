# Changelog

## [0.2.1](https://github.com/RomainFALLER/wealth-infra/compare/wealth-infra-v0.2.0...wealth-infra-v0.2.1) (2026-03-31)


### Features

* add AI chat secrets to Key Vault and App Service config ([b50c085](https://github.com/RomainFALLER/wealth-infra/commit/b50c085b17eb7e8fef1a1000b58ac6fad4212821))
* add Enable Banking secrets to Key Vault and app settings ([4fb9e58](https://github.com/RomainFALLER/wealth-infra/commit/4fb9e583decc8c90069c96f7ee5e298620f0d600))
* add FRONTEND_URL app setting for Open Banking callback redirect ([f9ed2c3](https://github.com/RomainFALLER/wealth-infra/commit/f9ed2c344d55fbe15e9f4046ad2fee602c26b318))
* initial Terraform infrastructure for WealthOS ([9a7cee3](https://github.com/RomainFALLER/wealth-infra/commit/9a7cee3e1cccc7cbcf6bf9a3e325ce40097e73e0))
* migrate to Docker/ACR deployment, MySQL, and custom domain CORS ([7b06767](https://github.com/RomainFALLER/wealth-infra/commit/7b0676751217a7dff4d8e45d5ca096e0cd2d86bc))

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
