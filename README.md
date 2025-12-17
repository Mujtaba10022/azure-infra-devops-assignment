# Azure Infrastructure DevOps Assessment

## Live Application:  http://172.171.132.109

## Project Overview

Enterprise-grade Azure cloud infrastructure with: 
- Private Endpoints for SQL, KeyVault, Storage
- Private DNS Zones for secure name resolution
- Modular Terraform IaC (8 modules)
- CI/CD with GitHub Actions (56+ runs)
- AKS with LoadBalancer

## Azure Resources

| Resource | Name | Location |
|----------|------|----------|
| AKS Cluster | aks-gm-staging | East US |
| Container Registry | acrgmstaging | East US |
| SQL Server | sqlgmstaging2025 | West US 2 |
| Key Vault | kv-gm-staging | East US |
| Storage Account | stgmstaging | East US |
| OpenAI Service | oai-gm-staging | West US |
| Virtual Network | vnet-gm-staging | East US |

## Private Endpoints

| Endpoint | Target | Status |
|----------|--------|--------|
| pe-sql-staging | Azure SQL | Active |
| pe-keyvault-staging | Key Vault | Active |
| pe-storage-staging | Storage | Active |

## Private DNS Zones

- privatelink.database.windows.net
- privatelink.vaultcore.azure.net
- privatelink.blob.core.windows.net
- privatelink.azurecr.io
- privatelink. openai.azure.com

## API Endpoints

- GET /api/health - Health check
- GET /api/customers - List customers
- GET /api/products - List products
- GET /api/orders - List orders

## Author

Ghulam Mujtaba - Azure DevOps Engineer
