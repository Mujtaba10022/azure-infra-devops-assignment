# 🚀 AI SQL Agent - Azure Infrastructure & DevOps Assignment

[![Deploy SQL Agent](https://github.com/Mujtaba10022/azure-infra-devops-assignment/actions/workflows/deploy-sql-agent.yml/badge.svg)](https://github.com/Mujtaba10022/azure-infra-devops-assignment/actions/workflows/deploy-sql-agent.yml)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)](https://www.terraform.io)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5?logo=kubernetes)](https://azure.microsoft.com/en-us/products/kubernetes-service)

## Author:  Ghulam Mujtaba
**Email**: mujtabacif@gmail. com | **GitHub**: [@Mujtaba10022](https://github.com/Mujtaba10022)

> **Production-grade SQL Agent Customer Service Portal** leveraging Azure OpenAI for intelligent SQL-based query responses, deployed on Azure Kubernetes Service with comprehensive network security and compliance-driven regional separation.

---

## 🌐 Access Live Application

```bash
# Get the live application URL after deployment
kubectl get svc sql-agent-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

---

## ⚠️ IMPORTANT:  What to Update on Each New Deployment

### When You Destroy and Redeploy Infrastructure

When deploying, you **MUST** update the following:

### 1️⃣ GitHub Secrets to Update

Go to:  **Repository → Settings → Secrets and variables → Actions**

| Secret Name | How to Get New Value | Example (Current) |
|-------------|---------------------|-------------------|
| `AZURE_CREDENTIALS` | `az ad sp create-for-rbac --name "sp-gm-staging" --role contributor --scopes /subscriptions/<SUB_ID> --sdk-auth` | Service Principal JSON |
| `SQL_ADMIN_PASSWORD` | Your chosen password | `stored in github secret` |
| `AZURE_OPENAI_KEY` | `az cognitiveservices account keys list -n oai-gm-staging -g RG-GM_Assessment --query key1 -o tsv` | OpenAI API Key |
| `ACR_LOGIN_SERVER` | `az acr show -n acrgmstaging --query loginServer -o tsv` | `acrgmstaging.azurecr.io` |
| `ACR_NAME` | Your ACR name | `acrgmstaging` |
| `AKS_NAME` | Your AKS cluster name | `aks-gm-staging` |
| `AKS_RG` | Your resource group name | `RG-GM_Assessment` |

### 2️⃣ Configuration Files to Update

| File | What to Update | Example Value |
|------|---------------|---------------|
| `k8s/sql-agent.yaml` | `SQL_SERVER` | `sql-gm-staging.database.windows.net` |
| `k8s/sql-agent.yaml` | `AZURE_OPENAI_ENDPOINT` | `https://westus. api.cognitive.microsoft.com/` |
| `.github/workflows/deploy-sql-agent.yml` | Resource group, AKS name | `RG-GM_Assessment`, `aks-gm-staging` |

### 3️⃣ Quick Commands to Get New Values

```bash
# Get OpenAI Endpoint (Example: oai-gm-staging in RG-GM_Assessment)
az cognitiveservices account show -n oai-gm-staging -g RG-GM_Assessment --query "properties.endpoint" -o tsv

# Get OpenAI Key
az cognitiveservices account keys list -n oai-gm-staging -g RG-GM_Assessment --query key1 -o tsv

# Get SQL Server FQDN (Example: sql-gm-staging in RG-GM_Assessment)
az sql server show -n sql-gm-staging -g RG-GM_Assessment --query fullyQualifiedDomainName -o tsv

# Get ACR Login Server (Example: acrgmstaging)
az acr show -n acrgmstaging --query loginServer -o tsv

# Get AKS Credentials (Example: aks-gm-staging in RG-GM_Assessment)
az aks get-credentials -g RG-GM_Assessment -n aks-gm-staging --overwrite-existing
```

---

## 📋 Table of Contents

1. [Architecture Overview](#-architecture-overview)
2. [Infrastructure Components](#-infrastructure-components)
3. [Network Security & Compliance](#-network-security--compliance)
4. [Private Endpoint Architecture & DNS Strategy](#-private-endpoint-architecture--dns-strategy)
5. [Prerequisites](#-prerequisites)
6. [Deployment Instructions](#-deployment-instructions)
7. [CI/CD Pipelines](#-cicd-pipelines)
8. [Kubernetes Resource Decisions](#-kubernetes-resource-decisions)
9. [GitOps Strategy](#-gitops-strategy)
10. [Security Considerations](#-security-considerations)
11. [Validation Commands](#-validation-commands)
12. [Assumptions & Design Decisions](#-assumptions--design-decisions)
13. [Challenges & Solutions](#-challenges--solutions)
14. [Repository Structure](#-repository-structure)
15. [Demo](#-demo)

---

## 🏗️ Architecture Overview

### High-Level Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    AZURE CLOUD INFRASTRUCTURE                                             │
│                              Production-Grade Multi-Region Architecture                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                           │
│   ┌───────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│   │                              CI/CD PIPELINES (Azure DevOps / GitHub Actions)                       │  │
│   │  ┌─────────────────────────────────┐         ┌─────────────────────────────────┐                  │  │
│   │  │ azure-pipelines-infra.yml       │         │ azure-pipelines-app.yml         │                  │  │
│   │  │ • Terraform Init/Plan/Apply     │         │ • Docker Build & Push to ACR    │                  │  │
│   │  │ • State in Azure Storage        │         │ • Deploy to AKS (kubectl)       │                  │  │
│   │  │ • Secrets from Key Vault        │         │ • Secrets from GitHub Secrets   │                  │  │
│   │  └────────────────┬────────────────┘         └────────────────┬────────────────┘                  │  │
│   └───────────────────┼────────────────────────────────────────────┼───────────────────────────────────┘  │
│                       │                                            │                                      │
│                       ▼                                            ▼                                      │
│   ┌───────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│   │     RESOURCE GROUP:  RG-GM_Assessment (Example: RG-<YourName>_<Purpose>)                            │  │
│   │                                                                                                    │  │
│   │   ┌────────────────────────────────────────────────────────────────────────────────────────────┐  │  │
│   │   │                         EAST US - Application Region                                        │  │  │
│   │   │   ┌────────────────────────────────────────────────────────────────────────────────────┐   │  │  │
│   │   │   │       VIRTUAL NETWORK:  vnet-gm-staging (Example: vnet-<env>-<region>)               │   │  │  │
│   │   │   │                        Address Space:  10.0.0.0/16                                   │   │  │  │
│   │   │   │                                                                                     │   │  │  │
│   │   │   │   ┌─────────────────────────────────────────────────────────────────────────────┐  │   │  │  │
│   │   │   │   │ SUBNET: snet-aks (10.0.1.0/24)              NSG: nsg-aks-eastus             │  │   │  │  │
│   │   │   │   │  ┌───────────────────────────────────────────────────────────────────────┐  │  │   │  │  │
│   │   │   │   │  │     AKS CLUSTER:  aks-gm-staging (Example:  aks-<env>-<region>)         │  │  │   │  │  │
│   │   │   │   │  │                  Kubernetes v1.30.9 | Azure CNI Networking            │  │  │   │  │  │
│   │   │   │   │  │  ┌─────────────────────────┐    ┌─────────────────────────┐           │  │  │   │  │  │
│   │   │   │   │  │  │ SYSTEM NODE POOL        │    │ USER NODE POOL          │           │  │  │   │  │  │
│   │   │   │   │  │  │ • VM:  Standard_DS2_v2   │    │ • VM: Standard_DS2_v2   │           │  │  │   │  │  │
│   │   │   │   │  │  │ • Nodes: 1-3 (Auto)     │    │ • Nodes: 1-3 (Auto)     │           │  │  │   │  │  │
│   │   │   │   │  │  └─────────────────────────┘    └─────────────────────────┘           │  │  │   │  │  │
│   │   │   │   │  │                                                                       │  │  │   │  │  │
│   │   │   │   │  │  ┌─────────────────────────────────────────────────────────────────┐ │  │  │   │  │  │
│   │   │   │   │  │  │                    KUBERNETES WORKLOADS                          │ │  │  │   │  │  │
│   │   │   │   │  │  │  Namespace: default                                              │ │  │  │   │  │  │
│   │   │   │   │  │  │  ┌───────────────────┐  ┌───────────────────┐                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  │ Deployment:        │  │ Service:           │                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  │ sql-agent         │  │ sql-agent-service │                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  │ Replicas: 2       │  │ Type: LoadBalancer│                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  └───────────────────┘  └───────────────────┘                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  ┌───────────────────┐  ┌───────────────────┐                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  │ ConfigMap:        │  │ Secret:           │                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  │ sql-agent-config  │  │ sql-agent-secrets │                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  │ (Non-sensitive)   │  │ (From CI/CD)      │                    │ │  │  │   │  │  │
│   │   │   │   │  │  │  └───────────────────┘  └───────────────────┘                    │ │  │  │   │  │  │
│   │   │   │   │  │  └─────────────────────────────────────────────────────────────────┘ │  │  │   │  │  │
│   │   │   │   │  └───────────────────────────────────────────────────────────────────────┘  │  │   │  │  │
│   │   │   │   └─────────────────────────────────────────────────────────────────────────────┘  │   │  │  │
│   │   │   │                                                                                     │   │  │  │
│   │   │   │   ┌─────────────────────────────────────────────────────────────────────────────┐  │   │  │  │
│   │   │   │   │ SUBNET: snet-private-endpoints (10.0.2.0/24)                                 │  │   │  │  │
│   │   │   │   │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                  │  │   │  │  │
│   │   │   │   │  │ pe-sql-staging │  │ pe-kv-staging  │  │ pe-st-staging  │                  │  │   │  │  │
│   │   │   │   │  │ (SQL Server)   │  │ (Key Vault)    │  │ (Storage)      │                  │  │   │  │  │
│   │   │   │   │  └────────────────┘  └────────────────┘  └────────────────┘                  │  │   │  │  │
│   │   │   │   └─────────────────────────────────────────────────────────────────────────────┘  │   │  │  │
│   │   │   └────────────────────────────────────────────────────────────────────────────────────┘   │  │  │
│   │   │                                                                                            │  │  │
│   │   │   ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐     │  │  │
│   │   │   │ KEY VAULT        │ │ STORAGE ACCOUNT  │ │ CONTAINER REG    │ │ LOG ANALYTICS    │     │  │  │
│   │   │   │ kv-gm-staging    │ │ stgmstaging      │ │ acrgmstaging     │ │ log-gm-staging   │     │  │  │
│   │   │   │ (kv-<env>)       │ │ (st<env>)        │ │ (acr<env>)       │ │ (log-<env>)      │     │  │  │
│   │   │   │ Private EP ✓     │ │ Private EP ✓     │ │ AKS Integrated ✓ │ │                  │     │  │  │
│   │   │   └──────────────────┘ └──────────────────┘ └──────────────────┘ └──────────────────┘     │  │  │
│   │   └────────────────────────────────────────────────────────────────────────────────────────────┘  │  │
│   │                                                                                                   │  │
│   │                          ╔════════════════════════════════════════════╗                          │  │
│   │                          ║  CROSS-REGION PRIVATE CONNECTIVITY         ║                          │  │
│   │                          ║  (Azure Backbone - No Public Internet)     ║                          │  │
│   │                          ╚════════════════════════════════════════════╝                          │  │
│   │                                              │                                                    │  │
│   │                    ┌─────────────────────────┴─────────────────────────┐                         │  │
│   │                    ▼                                                   ▼                         │  │
│   │   ┌─────────────────────────────────┐     ┌─────────────────────────────────┐                   │  │
│   │   │  WEST US - AI Region            │     │  Database Region                │                   │  │
│   │   │  ⚠️ COMPLIANCE:  Different Region │     │                                 │                 │  │
│   │   │ ┌─────────────────────────────┐ │     │ ┌─────────────────────────────┐ │                   │  │
│   │   │ │ AZURE OPENAI SERVICE        │ │     │ │ AZURE SQL SERVER            │ │                   │  │
│   │   │ │ oai-gm-staging              │ │     │ │ sql-gm-staging              │ │                   │  │
│   │   │ │ (oai-<env>-<region>)        │ │     │ │ (sql-<env>-<region>)        │ │                   │  │
│   │   │ │ Model:  gpt-4o-mini          │ │     │ │ Database: customerdb        │ │                   │  │
│   │   │ │ ✓ Private Endpoint          │ │     │ │ ✓ Private Endpoint          │ │                   │  │
│   │   │ │ ✓ No Public Access          │ │     │ │ ✓ Geo-Redundant Backup      │ │                   │  │
│   │   │ └─────────────────────────────┘ │     │ └─────────────────────────────┘ │                   │  │
│   │   └─────────────────────────────────┘     └─────────────────────────────────┘                   │  │
│   └───────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                          │
│   ┌───────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│   │  MANAGED RESOURCE GROUP: MC_RG-GM_Assessment_aks-gm-staging_eastus                                 │  │
│   │  (Auto-created by AKS - Contains node VMs, disks, NICs, load balancers)                           │  │
│   └───────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                          │
│   ┌───────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│   │                              PRIVATE DNS ZONES (Global)                                            │  │
│   │  privatelink.database.windows.net | privatelink.vaultcore.azure. net | privatelink.blob.core...     │  │
│   │  privatelink.azurecr.io | privatelink.openai.azure.com                                            │  │
│   └───────────────────────────────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Infrastructure Components

### Resource Groups

| Resource Group | Purpose | Region |
|----------------|---------|--------|
| **RG-GM_Assessment** (Example: RG-<Name>_<Purpose>) | Primary resources | East US |
| **MC_RG-GM_Assessment_aks-gm-staging_eastus** | AKS managed (auto-created) | East US |

### Azure Resources

| Component | Resource Name | Pattern | Region | Purpose |
|-----------|---------------|---------|--------|---------|
| **AKS Cluster** | `aks-gm-staging` | `aks-<env>-<region>` | East US | Kubernetes orchestration |
| **Azure OpenAI** | `oai-gm-staging` | `oai-<env>-<region>` | **West US** | AI/LLM (Different Region ✓) |
| **Azure SQL Server** | `sql-gm-staging` | `sql-<env>-<region>` | East US | Database server |
| **Azure SQL Database** | `customerdb` | `customerdb` | East US | Application data |
| **Key Vault** | `kv-gm-staging` | `kv-<env>-<suffix>` | East US | Secrets management |
| **Storage Account** | `stgmstaging` | `st<env><suffix>` | East US | Terraform state, logs |
| **Container Registry** | `acrgmstaging` | `acr<env><suffix>` | East US | Docker images |
| **Virtual Network** | `vnet-gm-staging` | `vnet-<env>-<region>` | East US | Network (10.0.0.0/16) |
| **Log Analytics** | `log-gm-staging` | `log-<env>-<region>` | East US | Monitoring |

### ✅ Compliance Requirement Met

| Requirement | Implementation |
|-------------|---------------|
| AKS and OpenAI in different regions | AKS: **East US**, OpenAI: **West US** ✓ |
| Private endpoint connectivity | All data services use private endpoints ✓ |
| No public internet exposure | Zero public access to data/AI resources ✓ |

---

## 🔒 Network Security & Compliance

### Network Architecture

| Subnet | CIDR | Purpose | NSG |
|--------|------|---------|-----|
| snet-aks | 10.0.1.0/24 | AKS nodes and pods | nsg-aks-eastus |
| snet-private-endpoints | 10.0.2.0/24 | Private endpoints | nsg-pe-eastus |

### Private Endpoints

| Service | Private Endpoint | Private DNS Zone | Example Resource |
|---------|------------------|------------------|------------------|
| Azure SQL | pe-sql-staging | privatelink.database.windows.net | `sql-gm-staging` |
| Key Vault | pe-kv-staging | privatelink.vaultcore.azure.net | `kv-gm-staging` |
| Storage | pe-st-staging | privatelink.blob.core.windows.net | `stgmstaging` |
| ACR | (AKS integrated) | privatelink.azurecr.io | `acrgmstaging` |
| OpenAI | (Managed) | privatelink.openai.azure.com | `oai-gm-staging` |

### Kubernetes Network Security

#### Network Policies Approach
- **Pod-to-Pod**:  Restrict communication to only required services
- **Pod-to-External**: Allow only Azure backbone traffic (private endpoints)
- **Ingress**:  LoadBalancer service for external access

#### Ingress Controller Strategy
| Option | Use Case |
|--------|----------|
| LoadBalancer (Current) | Demo/Development |
| NGINX Ingress + TLS | Production |
| Azure App Gateway (AGIC) | Enterprise with WAF |

---

## 🌐 Private Endpoint Architecture & DNS Strategy

### DNS Resolution Flow

```
Pod (sql-agent)
       │
       │ DNS Query:  sql-gm-staging.database.windows.net
       ▼
Azure DNS Resolver (168.63.129.16)
       │
       │ Check Private DNS Zone
       ▼
Private DNS Zone:  privatelink.database.windows.net
       │
       │ A Record → 10.0.2.x (Private IP)
       ▼
Private Endpoint (pe-sql-staging)
       │
       │ Azure Backbone (No Public Internet)
       ▼
Azure SQL Database (sql-gm-staging/customerdb)
```

---

## 📋 Prerequisites

### Required Tools
```bash
az --version          # Azure CLI 2.50+
terraform --version   # Terraform 1.5+
kubectl version       # kubectl 1.28+
git --version         # Git
```

### Azure Requirements
- ✅ Azure Subscription with Contributor access
- ✅ Azure OpenAI service enabled
- ✅ Sufficient quota for AKS nodes (4+ vCPUs)

### Required Resource Providers
```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.ContainerRegistry
```

---

## 🚀 Deployment Instructions

### Step 1: Clone Repository
```bash
git clone https://github.com/Mujtaba10022/azure-infra-devops-assignment.git
cd azure-infra-devops-assignment
```

### Step 2: Deploy Infrastructure (Terraform)
```bash
cd terraform/environments/staging
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 3: Configure AKS Access
```bash
# Example: aks-gm-staging in RG-GM_Assessment
az aks get-credentials -g RG-GM_Assessment -n aks-gm-staging --overwrite-existing
kubectl get nodes
```

### Step 4: Update k8s/sql-agent.yaml with your values
```yaml
# Get values from Azure CLI and update ConfigMap: 
AZURE_OPENAI_ENDPOINT:  "https://westus.api.cognitive.microsoft.com/"  # az cognitiveservices account show... 
SQL_SERVER: "sql-gm-staging.database.windows.net"                      # az sql server show...
```

### Step 5: Build and Push Container Image
```bash
# Example: acrgmstaging
az acr build --registry acrgmstaging --image sql-agent:v2 --file app/Dockerfile app/
```

### Step 6: Deploy Application
```bash
# Create secrets (or use CI/CD)
kubectl create secret generic sql-agent-secrets \
  --from-literal=SQL_PASSWORD=<YOUR_PASSWORD> \
  --from-literal=AZURE_OPENAI_KEY=<YOUR_KEY>

# Deploy
kubectl apply -f k8s/sql-agent.yaml

# Verify
kubectl get pods -l app=sql-agent
kubectl get svc sql-agent-service
```

### Step 7: Access Application
```bash
kubectl get svc sql-agent-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# Open:  http://<EXTERNAL_IP>
```

---

## 🔄 CI/CD Pipelines

### GitHub Actions:  deploy-sql-agent.yml
- Creates K8s secrets from GitHub Secrets (secure!)
- Deploys ConfigMap, Deployment, Service
- No hardcoded credentials

### Azure DevOps Pipelines
- `azure-pipelines-infra.yml` - Terraform deployment
- `azure-pipelines-app.yml` - Build, push, deploy to AKS

### Security Patterns
| Pattern | Implementation |
|---------|----------------|
| ✅ No hardcoded secrets | GitHub Secrets / Key Vault |
| ✅ Service Connections | Azure credentials via SP |
| ✅ Dynamic injection | K8s secrets at deploy time |

---

## 🎛️ Kubernetes Resource Decisions

| Setting | Value | Rationale |
|---------|-------|-----------|
| Replicas | 2 | High availability |
| CPU Request/Limit | 250m/500m | Baseline + burst |
| Memory Request/Limit | 256Mi/512Mi | Handle AI responses |
| Service Type | LoadBalancer | Direct external access |

### Secret Management Flow
```
GitHub Secrets (Encrypted) → GitHub Actions → kubectl create secret → K8s Secret → Pod Env Vars
```

---

## 🔄 GitOps Strategy

| Aspect | Choice |
|--------|--------|
| **Tool** | Flux CD (recommended) |
| **Rationale** | CNCF graduated, lightweight |
| **Sync** | 1 minute interval |
| **Drift Detection** | Automatic |

---

## 🔒 Security Considerations

### Managed Identities
| Resource | Type | Purpose |
|----------|------|---------|
| AKS | System Assigned | ACR pull |
| Key Vault | System Assigned | Secrets |

### Private Endpoints
| Service | Public Access |
|---------|---------------|
| Azure SQL | ❌ Disabled |
| Key Vault | ❌ Disabled |
| Storage | ❌ Disabled |
| OpenAI | ❌ Disabled |

### Container Security
```dockerfile
FROM python:3.11-slim          # Minimal image
USER appuser                   # Non-root
HEALTHCHECK CMD curl -f ...     # Health check
```

---

## ✅ Validation Commands

### Infrastructure
```bash
# Verify AKS (Example:  aks-gm-staging)
az aks show -g RG-GM_Assessment -n aks-gm-staging --query provisioningState

# Verify OpenAI in different region (Compliance)
az cognitiveservices account show -n oai-gm-staging -g RG-GM_Assessment --query location
# Expected: westus (different from AKS in eastus)

# Verify Private Endpoints
az network private-endpoint list -g RG-GM_Assessment -o table
```

### Kubernetes
```bash
kubectl get nodes
kubectl get pods -l app=sql-agent
kubectl get svc sql-agent-service
kubectl logs -l app=sql-agent --tail=50
```

### Application
```bash
EXTERNAL_IP=$(kubectl get svc sql-agent-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP/api/health

```

---

## 📝 Assumptions & Design Decisions

| Decision | Rationale | Trade-off |
|----------|-----------|-----------|
| AKS in East US | Primary app region | N/A |
| OpenAI in West US | Compliance requirement | ~30-50ms latency |
| kubectl over Helm | Simpler for single app | Less templating |
| LoadBalancer | Quick demo access | No URL routing |
| 2 replicas | High availability | More cost |

---

## 🛠️ Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Hardcoded secrets | GitHub Secrets → K8s via CI/CD |
| Cross-region connectivity | Azure backbone routing |
| Gunicorn timeout | Increased to 300s |
| Wrong OpenAI endpoint | Use `az cognitiveservices account show` |

---

## 📁 Repository Structure

```
azure-infra-devops-assignment/
├── . github/workflows/           # GitHub Actions
│   └── deploy-sql-agent.yml
├── app/                         # Application
│   ├── Dockerfile
│   ├── main.py
│   └── templates/index.html
├── k8s/                         # Kubernetes manifests
│   └── sql-agent.yaml
├── terraform/                   # Infrastructure as Code
│   ├── modules/                 # aks/, sql/, openai/, keyvault/, storage/, acr/, networking/
│   └── environments/            # dev/, staging/, prod/
├── pipelines/                   # Azure DevOps
│   ├── azure-pipelines-infra.yml
│   └── azure-pipelines-app.yml
└── README.md
```

---

## 🎬 Demo

[![AI SQL Agent Demo](https://img.youtube.com/vi/eto3kSOqfFc/maxresdefault.jpg)](https://youtu.be/eto3kSOqfFc)

▶️ **[Watch Full Demo on YouTube](https://youtu.be/eto3kSOqfFc)**

### Sample Queries
| Query | SQL Generated |
|-------|--------------|
| "Show all customers" | `SELECT * FROM Customers` |
| "Total revenue" | `SELECT SUM(TotalAmount) FROM Orders` |
| "Top 5 customers" | `JOIN + GROUP BY + ORDER BY` |

---

## 📧 Contact

**Author**: Ghulam Mujtaba  
**Email**: mujtabacif@gmail.com  
**GitHub**: [@Mujtaba10022](https://github.com/Mujtaba10022)

---

<p align="center"><b>Built with 🧠 using Azure + Kubernetes + OpenAI</b></p>
