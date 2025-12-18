# 🚀 AI SQL Agent - Azure Infrastructure & DevOps Assignment

## By:  Ghulam Mujtaba
## Live Demo: http://172.171.132.109

---

## 📋 Table of Contents

1. [Architecture Overview](#-architecture-overview)
2. [Infrastructure Components](#-infrastructure-components)
3. [Network Topology & DNS Strategy](#-network-topology--dns-strategy)
4. [Prerequisites](#-prerequisites)
5. [Deployment Instructions](#-deployment-instructions)
6. [Validation Commands](#-validation-commands)
7. [GitOps Strategy](#-gitops-strategy)
8. [Kubernetes Resource Decisions](#-kubernetes-resource-decisions)
9. [Security Considerations](#-security-considerations)
10. [Assumptions & Design Decisions](#-assumptions--design-decisions)
11. [Challenges & Solutions](#-challenges--solutions)

---

## 🏗️ Architecture Overview

### High-Level Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      AZURE CLOUD INFRASTRUCTURE                                         │
│                              Multi-Region Compliance Architecture                                       │
│                                      Resource Group:   RG-GM_Assessment                                   │
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│   │                                AZURE DEVOPS / GITHUB ACTIONS                                     │  │
│   │  ┌───────────────────────────┐              ┌───────────────────────────┐                       │  │
│   │  │ azure-pipelines-infra. yml │              │ azure-pipelines-app.  yml   │                       │  │
│   │  │ ┌───────────────────────┐ │              │ ┌───────────────────────┐ │                       │  │
│   │  │ │ • Terraform Init      │ │              │ │ • Docker Build        │ │                       │  │
│   │  │ │ • Terraform Plan      │ │              │ │ • Push to ACR         │ │                       │  │
│   │  │ │ • Terraform Apply     │ │              │ │ • Deploy to AKS       │ │                       │  │
│   │  │ └───────────────────────┘ │              │ └───────────────────────┘ │                       │  │
│   │  └─────────────┬─────────────┘              └─────────────┬─────────────┘                       │  │
│   └────────────────┼──────────────────────────────────────────┼──────────────────────────────────────┘  │
│                    │                                          │                                         │
│                    ▼                                          ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│   │                              REGION:   EAST US (Application Region)                                │  │
│   │  ┌───────────────────────────────────────────────────────────────────────────────────────────┐  │  │
│   │  │                        VIRTUAL NETWORK:  vnet-gm-staging (10.0.0.0/16)                      │  │  │
│   │  │                                                                                            │  │  │
│   │  │   ┌────────────────────────────────────────────────────────────────────────────────────┐  │  │  │
│   │  │   │ SUBNET: snet-aks (10.0.1.0/24)                     NSG: nsg-aks-eastus              │  │  │  │
│   │  │   │  ┌──────────────────────────────────────────────────────────────────────────────┐  │  │  │  │
│   │  │   │  │                    AKS CLUSTER: aks-gm-staging                                │  │  │  │  │
│   │  │   │  │                    Kubernetes Version: 1.30. 9 | Azure CNI Networking          │  │  │  │  │
│   │  │   │  │  ┌──────────────────────────┐    ┌──────────────────────────┐                 │  │  │  │  │
│   │  │   │  │  │ SYSTEM NODE POOL         │    │ USER NODE POOL           │                 │  │  │  │  │
│   │  │   │  │  │ agentpool                │    │ userpool                 │                 │  │  │  │  │
│   │  │   │  │  │ • VM:  Standard_DS2_v2    │    │ • VM: Standard_DS2_v2    │                 │  │  │  │  │
│   │  │   │  │  │ • Nodes: 2               │    │ • Nodes: 2               │                 │  │  │  │  │
│   │  │   │  │  │ • Auto-scaling: Yes      │    │ • Auto-scaling:  Yes      │                 │  │  │  │  │
│   │  │   │  │  └──────────────────────────┘    └──────────────────────────┘                 │  │  │  │  │
│   │  │   │  │                                                                               │  │  │  │  │
│   │  │   │  │  ┌───────────────────────────────────────────────────────────────────────┐   │  │  │  │  │
│   │  │   │  │  │                      KUBERNETES WORKLOADS                              │   │  │  │  │  │
│   │  │   │  │  │  ┌─────────────────────────┐    ┌─────────────────────────┐            │   │  │  │  │  │
│   │  │   │  │  │  │ Namespace: default      │    │ Namespace:  staging      │            │   │  │  │  │  │
│   │  │   │  │  │  │ ┌─────────────────────┐ │    │ ┌─────────────────────┐ │            │   │  │  │  │  │
│   │  │   │  │  │  │ │ Deployment:           │ │    │ │ Deployment:         │ │            │   │  │  │  │  │
│   │  │   │  │  │  │ │ sql-agent           │ │    │ │ sql-agent           │ │            │   │  │  │  │  │
│   │  │   │  │  │  │ │ Image: v17-fix      │ │    │ │ Replicas: 2         │ │            │   │  │  │  │  │
│   │  │   │  │  │  │ │ Replicas: 2         │ │    │ │ Port: 8080          │ │            │   │  │  │  │  │
│   │  │   │  │  │  │ └─────────────────────┘ │    │ └─────────────────────┘ │            │   │  │  │  │  │
│   │  │   │  │  │  │ ┌─────────────────────┐ │    │                         │            │   │  │  │  │  │
│   │  │   │  │  │  │ │ Service: LoadBalancer│ │    │                         │            │   │  │  │  │  │
│   │  │   │  │  │  │ │ IP: 172.171.132.109 │ │    │                         │            │   │  │  │  │  │
│   │  │   │  │  │  │ │ Port: 80 → 8080     │ │    │                         │            │   │  │  │  │  │
│   │  │   │  │  │  │ └─────────────────────┘ │    │                         │            │   │  │  │  │  │
│   │  │   │  │  │  └─────────────────────────┘    └─────────────────────────┘            │   │  │  │  │  │
│   │  │   │  │  └───────────────────────────────────────────────────────────────────────┘   │  │  │  │  │
│   │  │   │  └──────────────────────────────────────────────────────────────────────────────┘  │  │  │  │
│   │  │   └────────────────────────────────────────────────────────────────────────────────────┘  │  │  │
│   │  │                                                                                            │  │  │
│   │  │   ┌────────────────────────────────────────────────────────────────────────────────────┐  │  │  │
│   │  │   │ SUBNET: snet-private-endpoints (10.0.2.0/24)                                        │  │  │  │
│   │  │   │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐                  │  │  │  │
│   │  │   │  │ pe-sql-staging   │  │ pe-keyvault-     │  │ pe-storage-      │                  │  │  │  │
│   │  │   │  │ (SQL Server)     │  │ staging          │  │ staging          │                  │  │  │  │
│   │  │   │  │                  │  │ (Key Vault)      │  │ (Storage)        │                  │  │  │  │
│   │  │   │  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘                  │  │  │  │
│   │  │   └───────────┼─────────────────────┼─────────────────────┼─────────────────────────────┘  │  │  │
│   │  └───────────────┼─────────────────────┼─────────────────────┼─────────────────────────────────┘  │  │
│   │                  │                     │                     │                                    │  │
│   │   ┌──────────────▼──────┐  ┌───────────▼───────┐  ┌──────────▼────────┐  ┌────────────────────┐  │  │
│   │   │ KEY VAULT           │  │ STORAGE ACCOUNT   │  │ CONTAINER REGISTRY│  │ LOG ANALYTICS      │  │  │
│   │   │ kv-gm-staging       │  │ stgmstaging       │  │ acrgmstaging      │  │ log-gm-staging     │  │  │
│   │   │ (East US)           │  │ (East US)         │  │ (East US)         │  │ (East US)          │  │  │
│   │   │ ┌─────────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌────────────────┐ │  │  │
│   │   │ │ Secrets:          │ │  │ │ Containers:   │ │  │ │ Repositories:  │ │  │ │ Logs & Metrics │ │  │  │
│   │   │ │ • SQL_PASSWORD  │ │  │ │ • tfstate     │ │  │ │ • sql-agent   │ │  │ │ • AKS Logs     │ │  │  │
│   │   │ │ • OPENAI_KEY    │ │  │ │ • logs        │ │  │ │   : v17-fix    │ │  │ │ • App Insights │ │  │  │
│   │   │ │ • ACR_PASSWORD  │ │  │ │ • data-lake   │ │  │ └───────────────┘ │  │ └────────────────┘ │  │  │
│   │   │ └─────────────────┘ │  │ └───────────────┘ │  │                   │  │                    │  │  │
│   │   │ Private Endpoint ✓  │  │ Private Endpoint ✓│  │ Private Endpoint ✓│  │                    │  │  │
│   │   └─────────────────────┘  └───────────────────┘  └───────────────────┘  └────────────────────┘  │  │
│   │                                                                                                   │  │
│   └───────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                          │
│                                    ╔═══════════════════════════════════╗                                │
│                                    ║     CROSS-REGION CONNECTIVITY     ║                                │
│                                    ║   (Private Endpoint via Azure)    ║                                │
│                                    ╚═══════════════════════════════════╝                                │
│                                                   │                                                      │
│                     ┌─────────────────────────────┼─────────────────────────────┐                       │
│                     │                             │                             │                       │
│                     ▼                             ▼                             ▼                       │
│   ┌─────────────────────────────┐  ┌─────────────────────────────┐  ┌─────────────────────────────┐    │
│   │   REGION:  WEST US           │  │   REGION: WEST US 2         │  │   PRIVATE DNS ZONES         │    │
│   │   (AI Region - Compliance)  │  │   (Database Region)         │  │   (Global)                  │    │
│   │  ┌───────────────────────┐  │  │  ┌───────────────────────┐  │  │  ┌───────────────────────┐  │    │
│   │  │ AZURE OPENAI SERVICE  │  │  │  │ AZURE SQL SERVER      │  │  │  │ privatelink.database.  │  │    │
│   │  │ oai-gm-staging        │  │  │  │ sqlgmstaging2025      │  │  │  │ windows.net           │  │    │
│   │  │ ┌───────────────────┐ │  │  │  │ ┌───────────────────┐ │  │  │  ├───────────────────────┤  │    │
│   │  │ │ Model: gpt-4o-mini│ │  │  │  │ │ Database:           │ │  │  │  │ privatelink.vaultcore│  │    │
│   │  │ │ API: 2024-02-15   │ │  │  │  │ │ customerdb        │ │  │  │  │ . azure.net           │  │    │
│   │  │ │                   │ │  │  │  │ │ • Customers table │ │  │  │  ├───────────────────────┤  │    │
│   │  │ │ Endpoint:           │ │  │  │  │ │ • Products table  │ │  │  │  │ privatelink. blob.    │  │    │
│   │  │ │ oai-gm-staging.    │ │  │  │  │ │ • Orders table    │ │  │  │  │ core.windows.net     │  │    │
│   │  │ │ openai. azure.com  │ │  │  │  │ └───────────────────┘ │  │  │  ├───────────────────────┤  │    │
│   │  │ └───────────────────┘ │  │  │  │                       │  │  │  │ privatelink.azurecr.  │  │    │
│   │  │                       │  │  │  │ Private Endpoint ✓    │  │  │  │ io                    │  │    │
│   │  │ ⚠️  Different Region  │  │  │  │ Geo-Redundant ✓       │  │  │  ├───────────────────────┤  │    │
│   │  │ from AKS (Compliance)│  │  │  │ No Public Access ✓    │  │  │  │ privatelink.openai.   │  │    │
│   │  └───────────────────────┘  │  │  └───────────────────────┘  │  │  │ azure.com             │  │    │
│   └─────────────────────────────┘  └─────────────────────────────┘  │  └───────────────────────┘  │    │
│                                                                      └─────────────────────────────┘    │
│                                                                                                          │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘

                                         
    ┌──────────────────────────────────────────────────────────────────────────────┐
    │  ✓ Private Endpoint    ═══ Cross-Region Link    ──► Data Flow              │
    │  ⚠️ Compliance Note     [  ] Azure Service       NSG Network Security Group │
    └──────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Infrastructure Components

| Component | Resource Name | Region | Purpose |
|-----------|---------------|--------|---------|
| **Resource Group** | RG-GM_Assessment | Global | Container for all resources |
| **AKS Cluster** | aks-gm-staging | **East US** | Private Kubernetes cluster |
| **Azure OpenAI** | oai-gm-staging | **West US** | AI/LLM (Compliance - Different Region) ✓ |
| **Azure SQL Server** | sqlgmstaging2025 | **West US 2** | Database server |
| **Azure SQL Database** | customerdb | **West US 2** | Application data |
| **Key Vault** | kv-gm-staging | **East US** | Secrets management |
| **Storage Account** | stgmstaging | **East US** | Terraform state & logs |
| **Container Registry** | acrgmstaging | **East US** | Docker images |
| **Virtual Network** | vnet-gm-staging | **East US** | Network segmentation |
| **Log Analytics** | log-gm-staging | **East US** | Monitoring & logging |
| **NSG** | nsg-aks-eastus | **East US** | Network security rules |

### ✅ Compliance Requirement:  AI in Different Region
- **AKS Cluster**: East US
- **Azure OpenAI**: West US (**Different Region - Compliant! **)

---

## 🌐 Network Topology & DNS Strategy

### Private Endpoint Configuration

| Service | Private Endpoint | Private DNS Zone | Region |
|---------|------------------|------------------|--------|
| Azure SQL | pe-sql-staging | privatelink.database. windows.net | East US → West US 2 |
| Key Vault | pe-keyvault-staging | privatelink.vaultcore.azure. net | East US |
| Storage | pe-storage-staging | privatelink.blob.core.windows. net | East US |
| ACR | (integrated) | privatelink.azurecr.io | East US |
| OpenAI | (via public/managed) | privatelink.openai.azure. com | West US |

### Private DNS Zones (Global)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           PRIVATE DNS ZONES                                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │ privatelink.database.windows.net                                         │    │
│  │ └── sqlgmstaging2025 → Private Endpoint IP                              │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │ privatelink.vaultcore.azure. net                                          │    │
│  │ └── kv-gm-staging → Private Endpoint IP                                  │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │ privatelink.blob.core. windows.net                                        │    │
│  │ └── stgmstaging → Private Endpoint IP                                    │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │ privatelink.azurecr.io                                                   │    │
│  │ └── acrgmstaging → Private Endpoint IP                                   │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │ privatelink.openai.azure.com                                             │    │
│  │ └── oai-gm-staging → Private Endpoint IP                                 │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### DNS Resolution Flow

```
┌─────────────────┐
│ Pod (sql-agent) │
└────────┬────────┘
         │ 1. DNS Query:  sqlgmstaging2025.database.windows.net
         ▼
┌─────────────────────────┐
│ Azure DNS Resolver      │
│ (168.63.129.16)         │
└────────┬────────────────┘
         │ 2. Check Private DNS Zone
         ▼
┌──────────────────────────────────────┐
│ privatelink.database.windows.net     │
│ A Record: sqlgmstaging2025 → 10.x.x.x│
└────────┬─────────────────────────────┘
         │ 3. Return Private IP
         ▼
┌─────────────────────────┐
│ Private Endpoint        │
│ pe-sql-staging          │
└────────┬────────────────┘
         │ 4. Route via Azure Backbone (No Public Internet)
         ▼
┌─────────────────────────┐
│ Azure SQL Database      │
│ sqlgmstaging2025        │
│ (West US 2)             │
└─────────────────────────┘
```

---

## 📋 Prerequisites

### Required Tools

```bash
# Azure CLI
az --version          # 2.50+

# Terraform
terraform --version   # 1.5+

# Kubernetes CLI
kubectl version       # 1.28+

# Helm
helm version          # 3.12+

# Docker (optional for local builds)
docker --version      # 24.0+
```

### Azure Requirements

- ✅ Contributor access to Azure subscription
- ✅ Azure OpenAI service enabled for subscription
- ✅ Sufficient quota for AKS nodes (4+ vCPUs)
- ✅ Required resource providers registered: 
  - Microsoft.ContainerService
  - Microsoft. CognitiveServices
  - Microsoft. Sql
  - Microsoft. KeyVault
  - Microsoft.Storage
  - Microsoft. ContainerRegistry

---

## 🚀 Deployment Instructions

### Option A: Using Azure DevOps Pipelines (Recommended)

1. **Import Repository** to Azure DevOps project
2. **Create Service Connection**:  
   - Settings → Service Connections → Azure Resource Manager
   - Name: `Azure-Service-Connection`
3. **Create Variable Group**:
   - Pipelines → Library → Variable Groups
   - Name: `terraform-secrets`
   - Link to Azure Key Vault:  `kv-gm-staging`
4. **Run Infrastructure Pipeline**:
   - Pipelines → azure-pipelines-infra. yml
5. **Run Application Pipeline**:
   - Pipelines → azure-pipelines-app.yml

### Option B: Manual Deployment via CLI

#### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/azure-infra-devops-assignment.git
cd azure-infra-devops-assignment
```

#### Step 2: Azure Authentication

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
az account show
```

#### Step 3: Deploy Infrastructure with Terraform

```bash
cd terraform/environments/staging

# Initialize Terraform with backend
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -out=staging. tfplan

# Apply infrastructure
terraform apply staging. tfplan

# Get outputs
terraform output
```

#### Step 4: Configure AKS Access

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group RG-GM_Assessment \
  --name aks-gm-staging

# Verify cluster connection
kubectl get nodes
kubectl cluster-info
```

#### Step 5: Create Kubernetes Secrets

```bash
# Get secrets from Key Vault
SQL_PASSWORD=$(az keyvault secret show --vault-name kv-gm-staging --name sql-password --query value -o tsv)
OPENAI_KEY=$(az keyvault secret show --vault-name kv-gm-staging --name openai-key --query value -o tsv)

# Create Kubernetes secret
kubectl create secret generic sql-agent-secrets \
  --from-literal=SQL_PASSWORD=$SQL_PASSWORD \
  --from-literal=AZURE_OPENAI_KEY=$OPENAI_KEY
```

#### Step 6: Build and Push Container Image

```bash
# Login to ACR
az acr login --name acrgmstaging

# Build using ACR Tasks
az acr build \
  --registry acrgmstaging \
  --image sql-agent: v17-fix \
  --file app/Dockerfile \
  app/

# Verify image
az acr repository show-tags --name acrgmstaging --repository sql-agent
```

#### Step 7: Deploy Application

```bash
# Option A: Using kubectl
kubectl apply -f k8s/sql-agent. yaml

# Option B: Using Helm
helm upgrade --install sql-agent ./helm/sql-agent \
  --values ./helm/sql-agent/values. yaml

# Verify deployment
kubectl rollout status deployment/sql-agent
kubectl get pods -l app=sql-agent
kubectl get svc sql-agent
```

---

## ✅ Validation Commands

### Infrastructure Validation

```bash
# ═══════════════════════════════════════════════════════════════════════════════
#                         INFRASTRUCTURE VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# 1. Verify Resource Group
az group show --name RG-GM_Assessment -o table

# 2. Verify AKS Cluster
az aks show --resource-group RG-GM_Assessment --name aks-gm-staging \
  --query "{Name: name, State:provisioningState, K8sVersion:kubernetesVersion, Location:location}" -o table

# 3. Verify Azure OpenAI (Different Region)
az cognitiveservices account show --name oai-gm-staging --resource-group RG-GM_Assessment \
  --query "{Name:name, Location:location, Kind:kind}" -o table

# 4. Verify SQL Server
az sql server show --resource-group RG-GM_Assessment --name sqlgmstaging2025 \
  --query "{Name:name, Location:location, PublicAccess:publicNetworkAccess}" -o table

# 5. Verify Private Endpoints
az network private-endpoint list --resource-group RG-GM_Assessment -o table

# 6. Verify Private DNS Zones
az network private-dns zone list --resource-group RG-GM_Assessment -o table

# 7. Verify Key Vault
az keyvault show --name kv-gm-staging \
  --query "{Name:name, Location:location, PublicAccess:properties.publicNetworkAccess}" -o table
```

### Kubernetes Validation

```bash
# ═══════════════════════════════════════════════════════════════════════════════
#                         KUBERNETES VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# 1. Verify Nodes
kubectl get nodes -o wide

# 2. Verify Pods
kubectl get pods -l app=sql-agent -o wide

# 3. Verify Deployment
kubectl get deployment sql-agent -o wide

# 4. Verify Service
kubectl get svc sql-agent

# 5. Verify Pod Logs
kubectl logs -l app=sql-agent --tail=50

# 6. Verify Image Version
kubectl describe pod -l app=sql-agent | grep "Image:"

# 7. Verify Secrets
kubectl get secrets
```

### Application Validation

```bash
# ═══════════════════════════════════════════════════════════════════════════════
#                         APPLICATION VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# 1. Health Check
curl -s http://172.171.132.109/api/health | jq . 
# Expected: {"status":"healthy","database":"customerdb","ai_status":"connected","model":"gpt-4o-mini"}

# 2. Test Customers API
curl -s http://172.171.132.109/api/customers | jq . 

# 3. Test Products API
curl -s http://172.171.132.109/api/products | jq .

# 4. Test Orders API
curl -s http://172.171.132.109/api/orders | jq .

# 5. Test AI Query - Basic
curl -s -X POST http://172.171.132.109/api/ask \
  -H "Content-Type: application/json" \
  -d '{"question":  "show all customers"}' | jq . 

# 6. Test AI Query - Name Search (PRO Feature)
curl -s -X POST http://172.171.132.109/api/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "mujtaba"}' | jq . 

# 7. Test AI Query - Aggregation
curl -s -X POST http://172.171.132.109/api/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "total revenue"}' | jq . 
```

### Network Security Validation

```bash
# ═══════════════════════════════════════════════════════════════════════════════
#                         NETWORK SECURITY VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# 1. Verify SQL has no public access
az sql server show --resource-group RG-GM_Assessment --name sqlgmstaging2025 \
  --query publicNetworkAccess -o tsv
# Expected:  Disabled

# 2. Verify Key Vault private access
az keyvault show --name kv-gm-staging \
  --query properties.publicNetworkAccess -o tsv
# Expected: Disabled

# 3. Verify NSG Rules
az network nsg rule list --resource-group RG-GM_Assessment \
  --nsg-name nsg-aks-eastus -o table

# 4. Test DNS Resolution from Pod
POD_NAME=$(kubectl get pod -l app=sql-agent -o jsonpath='{.items[0].metadata. name}')
kubectl exec -it $POD_NAME -- nslookup sqlgmstaging2025.database.windows.net

# 5. Verify Private Endpoint Connectivity
kubectl exec -it $POD_NAME -- nc -zv sqlgmstaging2025.database.windows.net 1433
```

### PowerShell Validation (Windows)

```powershell
# ═══════════════════════════════════════════════════════════════════════════════
#                         POWERSHELL VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# 1. Health Check
Invoke-WebRequest -Uri "http://172.171.132.109/api/health" -UseBasicParsing | Select-Object -ExpandProperty Content

# 2. Test AI Query
$body = '{"question": "show all customers"}'
Invoke-WebRequest -Uri "http://172.171.132.109/api/ask" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 120 | Select-Object -ExpandProperty Content

# 3. Verify Pods
kubectl get pods -l app=sql-agent

# 4. Verify Image
kubectl describe pod -l app=sql-agent | findstr "Image:"
```

---

## 🔄 GitOps Strategy

### Chosen Tool: ArgoCD

**Rationale:**
- ✅ Declarative GitOps for Kubernetes
- ✅ Automatic sync from Git repository
- ✅ Visual dashboard for deployment status
- ✅ Native Helm and Kustomize support
- ✅ Rollback capabilities
- ✅ Multi-cluster support

### Repository Structure

```
├── kubernetes/
│   ├── base/                      # Base manifests
│   │   ├── namespace.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap. yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml
│   │   ├── network-policy.yaml
│   │   └── service-account.yaml
│   └── overlays/                  # Environment overlays
│       └── staging/
│           └── kustomization.yaml
├── helm/
│   └── sql-agent/
│       ├── Chart.yaml
│       ├── values.yaml            # Default values
│       └── templates/
│           ├── deployment.yaml
│           └── service.yaml
```

### Synchronization Workflow

```
Developer Push → GitHub → ArgoCD Detects → Sync to Cluster → Pods Updated
       │              │           │               │               │
       ▼              ▼           ▼               ▼               ▼
   git push     Webhook     Compare State    kubectl apply   Rollout
                Trigger     Git ↔ Cluster                    Complete
```

### ArgoCD Application Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind:  Application
metadata: 
  name: sql-agent
  namespace:  argocd
spec:
  project:  default
  source: 
    repoURL: https://github.com/yourusername/azure-infra-devops-assignment
    targetRevision: main
    path: kubernetes/overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: staging
  syncPolicy: 
    automated: 
      prune: true
      selfHeal: true
```

---

## 🎛️ Kubernetes Resource Decisions

### Network Policies

```yaml
# File: kubernetes/base/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind:  NetworkPolicy
metadata: 
  name: sql-agent-network-policy
spec: 
  podSelector: 
    matchLabels:
      app:  sql-agent
  policyTypes: 
    - Ingress
    - Egress
  ingress: 
    - from: 
        - podSelector:  {}
      ports: 
        - protocol:  TCP
          port:  8080
  egress:
    - to:
        - ipBlock:
            cidr: 10.0.0.0/8      # Azure private network
      ports:
        - protocol: TCP
          port: 1433              # SQL Server
        - protocol: TCP
          port: 443               # HTTPS (OpenAI, Key Vault)
```

### Secret Management

| Approach | Implementation |
|----------|----------------|
| **Storage** | Kubernetes Secrets + Azure Key Vault |
| **Injection** | Environment variables from secrets |
| **Rotation** | Manual (can use CSI Driver for auto) |
| **Encryption** | etcd encryption at rest |

### Resource Limits

```yaml
resources:
  requests:
    memory:  "256Mi"
    cpu: "250m"
  limits: 
    memory: "512Mi"
    cpu: "500m"
```

### Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: sql-agent-hpa
spec: 
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: sql-agent
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type:  Utilization
          averageUtilization: 70
```

---

## 🔒 Security Considerations

### Managed Identity Implementation

| Resource | Identity Type | Purpose |
|----------|---------------|---------|
| AKS | System Assigned | Cluster operations |
| AKS Kubelet | User Assigned | ACR pull, Key Vault access |
| Key Vault | System Assigned | Secret management |
| OpenAI | System Assigned | API authentication |

### Private Endpoint Configuration

| Service | Private Endpoint | Public Access |
|---------|------------------|---------------|
| Azure SQL | pe-sql-staging | ❌ Disabled |
| Key Vault | pe-keyvault-staging | ❌ Disabled |
| Storage | pe-storage-staging | ❌ Disabled |
| ACR | (AKS integrated) | ❌ Disabled |

### Network Security Controls

- ✅ NSG on AKS subnet (nsg-aks-eastus)
- ✅ Default deny inbound from internet
- ✅ Allow only required ports (80, 443, 1433)
- ✅ Kubernetes Network Policies
- ✅ Private DNS zones for all services

### Container Security

```dockerfile
# Non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Minimal base image
FROM python:3.11-slim-bookworm

# No secrets in image
# Secrets injected via environment variables at runtime
```

---

## 📝 Assumptions & Design Decisions

### Assumptions Made

1. **Single Subscription**:  All resources in one Azure subscription
2. **Existing Quotas**: Sufficient compute quota for 4 AKS nodes
3. **OpenAI Access**: Azure OpenAI service enabled
4. **DNS Resolution**: Azure DNS handles private DNS zones

### Design Decisions

| Decision | Rationale | Trade-off |
|----------|-----------|-----------|
| AKS in East US | Primary application region | N/A |
| OpenAI in West US | Compliance - different region from AKS | ~30-50ms added latency |
| SQL in West US 2 | Geo-redundancy from East US | Cross-region latency |
| Azure CNI | Better pod networking | Uses more IP addresses |
| LoadBalancer | Simpler than Ingress for demo | Less flexible routing |
| 300s Gunicorn timeout | Handle slow AI queries | Higher resource usage |

### Alternative Approaches Evaluated

| Approach | Considered | Chosen | Reason |
|----------|------------|--------|--------|
| Kubenet vs Azure CNI | Yes | Azure CNI | Better integration |
| Ingress vs LoadBalancer | Yes | LoadBalancer | Simpler demo |
| ArgoCD vs Flux | Yes | ArgoCD | Better UI |
| Terraform vs Bicep | Yes | Terraform | Multi-cloud support |

---

## 🛠️ Challenges & Solutions

### Challenge 1: Cross-Region AI Connectivity

**Problem**: Azure OpenAI must be in different region (compliance) but accessible from AKS

**Solution**: 
- Deployed OpenAI in West US, AKS in East US
- Created Private DNS Zone for OpenAI
- Traffic routes via Azure backbone (private)
- Verified with nslookup from pods

### Challenge 2: Gunicorn Worker Timeouts

**Problem**:  Default 30-second timeout caused worker crashes during AI queries

**Solution**:
```dockerfile
CMD gunicorn --bind 0.0.0.0:8080 --workers 2 --timeout 300 --keep-alive 5 main:app
```
- Increased timeout to 300 seconds
- Added keep-alive for connection persistence

### Challenge 3: Rate Limiting (429 Errors)

**Problem**: Azure OpenAI rate limit exceeded during testing

**Solution**: 
- Wait 60 seconds between heavy queries
- Implemented retry logic in application
- Consider increasing OpenAI quota for production

### Challenge 4: Private Endpoint DNS Resolution

**Problem**:  Pods couldn't resolve private endpoint FQDNs

**Solution**: 
- Created Private DNS Zones for each service
- Linked DNS Zones to VNet
- Verified resolution with nslookup from within pods

### Lessons Learned

1. ✅ Always test private endpoint connectivity before deploying apps
2. ✅ Gunicorn timeout must exceed expected AI response time
3. ✅ Private DNS Zones must be linked to VNets
4. ✅ Cross-region networking requires careful IP planning
5. ✅ Use managed identities to avoid credential management

---

## Demo

**Author**:  Ghulam Mujtaba  
**Live Application**: http://172.171.132.109

### Quick Demo Commands

```powershell
# Open in browser
Start-Process "http://172.171.132.109"

# Test queries in UI: 
# - "show all customers" → Basic SELECT
# - "total revenue" → Aggregation
# - "top 5 customers by spending" → JOIN + GROUP BY
# - "products low in stock" → Filtering
```

### Demo Video (Optional)

[Link to demo video if recorded]

---

## 📄 Repository Structure

```
azure-infra-devops-assignment/
├── README.md                          # This file
├── . gitignore
│
├── terraform/                         # Infrastructure as Code
│   ├── modules/                       # Reusable modules
│   │   ├── aks/
│   │   ├── networking/
│   │   ├── sql/
│   │   ├── openai/
│   │   ├── keyvault/
│   │   ├── storage/
│   │   └── acr/
│   └── environments/                  # Environment configs
│       ├── dev/
│       ├── staging/
│       └── prod/
│
├── kubernetes/                        # K8s manifests (Kustomize)
│   ├── base/
│   └── overlays/staging/
│
├── helm/sql-agent/                    # Helm chart
│
├── k8s/                               # Simple manifests
│   └── sql-agent. yaml
│
├── app/                               # Application code
│   ├── Dockerfile
│   ├── main.py
│   ├── requirements.txt
│   └── templates/index.html
│
├── pipelines/                         # Azure DevOps pipelines
│   ├── azure-pipelines-infra.yml
│   └── azure-pipelines-app. yml
│
├── . github/workflows/                 # GitHub Actions
│   ├── terraform-infra.yml
│   └── app-deploy.yml
│
├── scripts/                           # Helper scripts
│   ├── create-service-principal.ps1
│   └── setup-backend.ps1
│
└── docs/                              # Documentation
    └── architecture/
```

Ghulam Mujtaba 