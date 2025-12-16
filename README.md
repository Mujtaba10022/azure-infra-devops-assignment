# Azure Infrastructure & DevOps Assignment

## SQL Agent Customer Service Portal on AKS

Production-grade infrastructure for a SQL agent-powered customer service portal on Azure Kubernetes Service with Azure OpenAI integration.

## Architecture

\\\
+------------------------------- EAST US -------------------------------+
|                                                                        |
|  +--------------------------- VNet 10. 0.0.0/16 ---------------------+ |
|  |                                                                   | |
|  |  +-------------+  +----------------+  +----------------+         | |
|  |  | AKS Subnet  |  | PE Subnet      |  | AppGW Subnet   |         | |
|  |  | 10.0.1.0/24 |  | 10.0.2.0/24    |  | 10.0.3.0/24    |         | |
|  |  +-------------+  +----------------+  +----------------+         | |
|  |                                                                   | |
|  +-------------------------------------------------------------------+ |
|                          |                                             |
|          +---------------+---------------+---------------+             |
|          v               v               v               v             |
|     [SQL DB]        [Storage]       [Key Vault]       [ACR]           |
|     Private         Private         Private           Private          |
+------------------------------------------------------------------------+
                                |
                    Cross-Region Private Link
                                |
                                v
+------------------------------- WEST US -------------------------------+
|                    +---------------------------+                       |
|                    |    Azure OpenAI Service   |                       |
|                    |    (Private Endpoint)     |                       |
|                    +---------------------------+                       |
+------------------------------------------------------------------------+
\\\

## Quick Start

### 1. Setup Terraform Backend
\\\powershell
.\scripts\setup-backend.ps1
\\\

### 2. Create Service Principal
\\\ash
az ad sp create-for-rbac --name "github-actions-sp" --role contributor --scopes /subscriptions/{sub-id} --sdk-auth
\\\

### 3. Configure GitHub Secrets
- AZURE_CREDENTIALS
- AZURE_SUBSCRIPTION_ID
- AZURE_TENANT_ID
- TF_STATE_RG
- TF_STATE_STORAGE
- SQL_ADMIN_LOGIN
- SQL_ADMIN_PASSWORD

### 4. Push to GitHub
\\\ash
git add .
git commit -m "Initial commit"
git push origin main
\\\

## Security Features
- Private AKS cluster
- Private endpoints for all PaaS services
- Cross-region Azure OpenAI (compliance)
- Network policies
- Managed identities
- Key Vault integration

## Author
Ghullam Mujtaba
# Updated 12/16/2025 19:00:43
