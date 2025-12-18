# 🚀 AI SQL Agent - Azure Infrastructure & DevOps

## By:  Ghulam Mujtaba
## Live Demo: http://4.157.31.99

---

## 📋 Table of Contents

1. [Architecture Overview](#-architecture-overview)
2. [Infrastructure Components](#-infrastructure-components)
3. [Network Topology & DNS Strategy](#-network-topology--dns-strategy)
4. [Prerequisites](#-prerequisites)
5. [Deployment Instructions](#-deployment-instructions)
6. [Validation Commands](#-validation-commands)
7. [Kubernetes Resource Decisions](#-kubernetes-resource-decisions)
8. [Security Considerations](#-security-considerations)
9. [Assumptions & Design Decisions](#-assumptions--design-decisions)
10. [Challenges & Solutions](#-challenges--solutions)

---

## 🏗️ Architecture Overview

### High-Level Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      AZURE CLOUD INFRASTRUCTURE                                         │
│                              Multi-Region Compliance Architecture                                       │
│                                      Resource Group: RG-GM_Assessment                                   │
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│   │                                AZURE DEVOPS / GITHUB ACTIONS                                     │  │
│   │  ┌───────────────────────────┐              ┌───────────────────────────┐                       │  │
│   │  │ azure-pipelines-infra.yml │              │ azure-pipelines-app.yml   │                       │  │
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
│   │                              REGION:  EAST US (Application Region)                                │  │
│   │  ┌───────────────────────────────────────────────────────────────────────────────────────────┐  │  │
│   │  │                        VIRTUAL NETWORK:  vnet-gm-staging (10.0.0.0/16)                      │  │  │
│   │  │                                                                                            │  │  │
│   │  │   ┌────────────────────────────────────────────────────────────────────────────────────┐  │  │  │
│   │  │   │ SUBNET: snet-aks (10.0.1.0/24)                     NSG: nsg-aks-eastus              │  │  │  │
│   │  │   │  ┌──────────────────────────────────────────────────────────────────────────────┐  │  │  │  │
│   │  │   │  │                    AKS CLUSTER: aks-gm-staging                                │  │  │  │  │
│   │  │   │  │                    Kubernetes Version: 1.30.9 | Azure CNI Networking          │  │  │  │  │
│   │  │   │  │  ┌──────────────────────────┐    ┌──────────────────────────┐                 │  │  │  │  │
│   │  │   │  │  │ SYSTEM NODE POOL         │    │ USER NODE POOL           │                 │  │  │  │  │
│   │  │   │  │  │ agentpool                │    │ userpool                 │                 │  │  │  │  │
│   │  │   │  │  │ • VM:  Standard_DS2_v2    │    │ • VM: Standard_DS2_v2    │                 │  │  │  │  │
│   │  │   │  │  │ • Nodes: 2               │    │ • Nodes: 2               │                 │  │  │  │  │
│   │  │   │  │  │ • Auto-scaling:  Yes      │    │ • Auto-scaling:  Yes      │                 │  │  │  │  │
│   │  │   │  │  └──────────────────────────┘    └──────────────────────────┘                 │  │  │  │  │
│   │  │   │  │                                                                               │  │  │  │  │
│   │  │   │  │  ┌───────────────────────────────────────────────────────────────────────┐   │  │  │  │  │
│   │  │   │  │  │                      KUBERNETES WORKLOADS                              │   │  │  │  │  │
│   │  │   │  │  │  ┌─────────────────────────────────────────────────────────────────┐  │   │  │  │  │  │
│   │  │   │  │  │  │ Namespace: default                                               │  │   │  │  │  │  │
│   │  │   │  │  │  │ ┌─────────────────────┐    ┌─────────────────────┐              │  │   │  │  │  │  │
│   │  │   │  │  │  │ │ Deployment:          │    │ Service:             │              │  │   │  │  │  │  │
│   │  │   │  │  │  │ │ sql-agent           │    │ sql-agent-service   │              │  │   │  │  │  │  │
│   │  │   │  │  │  │ │ Image: v17-fix      │    │ Type: LoadBalancer  │              │  │   │  │  │  │  │
│   │  │   │  │  │  │ │ Replicas: 2         │    │ IP: 172.171.132.109 │              │  │   │  │  │  │  │
│   │  │   │  │  │  │ │ Port: 8080          │    │ Port: 80 → 8080     │              │  │   │  │  │  │  │
│   │  │   │  │  │  │ └─────────────────────┘    └─────────────────────┘              │  │   │  │  │  │  │
│   │  │   │  │  │  │ ┌─────────────────────┐    ┌─────────────────────┐              │  │   │  │  │  │  │
│   │  │   │  │  │  │ │ ConfigMap:           │    │ Secret:             │              │  │   │  │  │  │  │
│   │  │   │  │  │  │ │ sql-agent-config    │    │ sql-agent-secrets   │              │  │   │  │  │  │  │
│   │  │   │  │  │  │ └─────────────────────┘    └─────────────────────┘              │  │   │  │  │  │  │
│   │  │   │  │  │  └─────────────────────────────────────────────────────────────────┘  │   │  │  │  │  │
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
│   │   │ │ Secrets:         │ │  │ │ Containers:   │ │  │ │ Repositories:  │ │  │ │ Logs & Metrics │ │  │  │
│   │   │ │ • SQL_PASSWORD  │ │  │ │ • tfstate     │ │  │ │ • sql-agent   │ │  │ │ • AKS Logs     │ │  │  │
│   │   │ │ • OPENAI_KEY    │ │  │ │ • logs        │ │  │ │   : v17-fix    │ │  │ │ • App Insights │ │  │  │
│   │   │ └─────────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │  │ └────────────────┘ │  │  │
│   │   │ Private Endpoint ✓  │  │ Private Endpoint ✓│  │ AKS Integrated ✓  │  │                    │  │  │
│   │   └─────────────────────┘  └───────────────────┘  └───────────────────┘  └────────────────────┘  │  │
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
│   │  │ │ Model: gpt-4o-mini│ │  │  │  │ │ Database:          │ │  │  │  │ privatelink.vaultcore │  │    │
│   │  │ │ API: 2024-02-15   │ │  │  │  │ │ customerdb        │ │  │  │  │ . azure.net            │  │    │
│   │  │ │                   │ │  │  │  │ │ • Customers table │ │  │  │  ├───────────────────────┤  │    │
│   │  │ │ Endpoint:          │ │  │  │  │ │ • Products table  │ │  │  │  │ privatelink. blob.     │  │    │
│   │  │ │ oai-gm-staging.    │ │  │  │  │ │ • Orders table    │ │  │  │  │ core.windows.net      │  │    │
│   │  │ │ openai. azure.com  │ │  │  │  │ └───────────────────┘ │  │  │  ├───────────────────────┤  │    │
│   │  │ └───────────────────┘ │  │  │  │                       │  │  │  │ privatelink.azurecr.  │  │    │
│   │  │                       │  │  │  │ Private Endpoint ✓    │  │  │  │ io                    │  │    │
│   │  │ ⚠️ Different Region   │  │  │  │ Geo-Redundant ✓       │  │  │  ├───────────────────────┤  │    │
│   │  │ from AKS (Compliance) │  │  │  │ No Public Access ✓    │  │  │  │ privatelink.openai.   │  │    │
│   │  └───────────────────────┘  │  │  └───────────────────────┘  │  │  │ azure.com             │  │    │
│   └─────────────────────────────┘  └─────────────────────────────┘  │  └───────────────────────┘  │    │
│                                                                      └─────────────────────────────┘    │
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
| **AKS Cluster** | aks-gm-staging | **East US** | Kubernetes cluster |
| **Azure OpenAI** | oai-gm-staging | **West US** | AI/LLM (Compliance - Different Region) ✓ |
| **Azure SQL Server** | sqlgmstaging2025 | **West US 2** | Database server |
| **Azure SQL Database** | customerdb | **West US 2** | Application data |
| **Key Vault** | kv-gm-staging | **East US** | Secrets management |
| **Storage Account** | stgmstaging | **East US** | Terraform state & logs |
| **Container Registry** | acrgmstaging | **East US** | Docker images |
| **Virtual Network** | vnet-gm-staging | **East US** | Network segmentation |
| **Log Analytics** | log-gm-staging | **East US** | Monitoring & logging |
| **NSG** | nsg-aks-eastus | **East US** | Network security rules |

### ✅ Compliance Requirement Met
- **AKS Cluster**: East US
- **Azure OpenAI**: West US (**Different Region - Compliant!**)

---

## 🌐 Network Topology & DNS Strategy

### Private Endpoint Configuration

| Service | Private Endpoint | Private DNS Zone | Region |
|---------|------------------|------------------|--------|
| Azure SQL | pe-sql-staging | privatelink.database. windows.net | East US → West US 2 |
| Key Vault | pe-keyvault-staging | privatelink.vaultcore.azure.net | East US |
| Storage | pe-storage-staging | privatelink.blob.core.windows. net | East US |
| ACR | (AKS integrated) | privatelink.azurecr. io | East US |
| OpenAI | (via managed endpoint) | privatelink.openai.azure. com | West US |

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

---

## 📋 Prerequisites

### Required Tools

```powershell
# PowerShell 7+ (Run as Administrator)
# Download:  https://github.com/PowerShell/PowerShell/releases
$PSVersionTable. PSVersion    # Should be 7.0+

# Azure CLI
az --version          # 2.50+

# Terraform
terraform --version   # 1.5+

# Kubernetes CLI
kubectl version       # 1.28+

# Docker (optional for local builds)
docker --version      # 24.0+
```

### ⚠️ Important:  Run PowerShell 7 as Administrator

```powershell
# To open PowerShell 7 as Administrator: 
# 1. Search for "PowerShell 7" or "pwsh" in Start Menu
# 2. Right-click → "Run as Administrator"
# 
# Or run from existing PowerShell: 
Start-Process pwsh -Verb RunAs
```

### Verify PowerShell Version

```powershell
# Check PowerShell version
$PSVersionTable

# Expected output:
# Name                           Value
# ----                           -----
# PSVersion                      7.4.x
# PSEdition                      Core
# OS                             Microsoft Windows 10.0.xxxxx
```

### Azure Requirements

- ✅ Contributor access to Azure subscription
- ✅ Azure OpenAI service enabled
- ✅ Sufficient quota for AKS nodes (4+ vCPUs)
- ✅ Required resource providers registered: 
  - Microsoft.ContainerService
  - Microsoft. CognitiveServices
  - Microsoft. Sql
  - Microsoft. KeyVault
  - Microsoft.Storage
  - Microsoft.ContainerRegistry

---

## 🚀 Deployment Instructions

### Deployment Method:  Kubernetes Manifests (kubectl)

The application is deployed using **kubectl** with a single manifest file containing all resources. 

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/azure-infra-devops-assignment.git
cd azure-infra-devops-assignment
```

### Step 2: Deploy Infrastructure with Terraform

```bash
cd terraform/environments/staging

# Initialize
terraform init

# Plan
terraform plan -out=staging. tfplan

# Apply
terraform apply staging. tfplan
```

### Step 3: Configure AKS Access

```bash
az aks get-credentials --resource-group RG-GM_Assessment --name aks-gm-staging
kubectl get nodes
```

### Step 4: Build and Push Container Image

```bash
az acr build --registry acrgmstaging --image sql-agent:v17-fix --file app/Dockerfile app/
```

### Step 5: Deploy Application using kubectl

```bash
# Deploy all resources (Secret, ConfigMap, Deployment, Service)
kubectl apply -f k8s/sql-agent. yaml

# Verify deployment
kubectl get pods -l app=sql-agent
kubectl get svc sql-agent-service
```

### What's in k8s/sql-agent.yaml

The manifest file contains:
- **Secret**: `sql-agent-secrets` - Database and OpenAI credentials
- **ConfigMap**: `sql-agent-config` - Application configuration
- **Deployment**:  `sql-agent` - 2 replicas of the application
- **Service**: `sql-agent-service` - LoadBalancer exposing port 80

---

## ✅ Validation Commands

### Infrastructure Validation

```bash
# Verify Resource Group
az group show --name RG-GM_Assessment -o table

# Verify AKS Cluster
az aks show --resource-group RG-GM_Assessment --name aks-gm-staging \
  --query "{Name: name, State:provisioningState, K8sVersion:kubernetesVersion}" -o table

# Verify Azure OpenAI (Different Region)
az cognitiveservices account show --name oai-gm-staging --resource-group RG-GM_Assessment \
  --query "{Name:name, Location:location}" -o table

# Verify Private Endpoints
az network private-endpoint list --resource-group RG-GM_Assessment -o table
```

### Kubernetes Validation

```bash
# Verify Nodes
kubectl get nodes -o wide

# Verify Pods
kubectl get pods -l app=sql-agent

# Verify Service
kubectl get svc sql-agent-service

# Verify Image Version
kubectl describe pod -l app=sql-agent | grep "Image:"

# Check Logs
kubectl logs -l app=sql-agent --tail=50
```

### Application Validation

```bash
# Health Check
curl -s [http://1](http://4.157.31.99)/api/health

# Test Customers API
curl -s http://4.157.31.99/api/customers

# Test AI Query
curl -s -X POST http://4.157.31.99/api/ask \
  -H "Content-Type:  application/json" \
  -d '{"question":  "show all customers"}'
```

### PowerShell Validation (Windows)

```powershell
# Health Check
Invoke-WebRequest -Uri "http://4.157.31.99/api/health" -UseBasicParsing | Select-Object -ExpandProperty Content

# Verify Pods
kubectl get pods -l app=sql-agent

# Verify Image
kubectl describe pod -l app=sql-agent | findstr "Image:"
```

---

## 🎛️ Kubernetes Resource Decisions

### Deployment Strategy

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Deployment Method** | kubectl apply | Simple, declarative, version controlled |
| **Manifest Location** | `k8s/sql-agent.yaml` | Single file for easy deployment |
| **Replicas** | 2 | High availability |
| **Service Type** | LoadBalancer | Direct external access |

### Secret Management

| Approach | Implementation |
|----------|----------------|
| **Storage** | Kubernetes Secrets |
| **Injection** | Environment variables via `secretRef` |
| **Source** | Created from Azure Key Vault values |

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

### ConfigMap Usage

```yaml
# Environment variables from ConfigMap
envFrom:
  - configMapRef: 
      name: sql-agent-config
  - secretRef:
      name: sql-agent-secrets
```

---

## 🔒 Security Considerations

### Managed Identity Implementation

| Resource | Identity Type | Purpose |
|----------|---------------|---------|
| AKS | System Assigned | Cluster operations, ACR pull |
| Key Vault | System Assigned | Secret management |
| OpenAI | System Assigned | API authentication |

### Private Endpoint Configuration

| Service | Private Endpoint | Public Access |
|---------|------------------|---------------|
| Azure SQL | pe-sql-staging | ❌ Disabled |
| Key Vault | pe-keyvault-staging | ❌ Disabled |
| Storage | pe-storage-staging | ❌ Disabled |

### Container Security

```dockerfile
# Non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Minimal base image
FROM python:3.11-slim-bookworm
```

### Network Security

- ✅ NSG on AKS subnet (nsg-aks-eastus)
- ✅ Private DNS zones for all services
- ✅ No public access to data services

---

## 📝 Assumptions & Design Decisions

### Assumptions Made

1. **Single Subscription**: All resources in one Azure subscription
2. **Existing Quotas**: Sufficient compute quota for AKS nodes
3. **OpenAI Access**: Azure OpenAI service enabled
4. **DNS Resolution**: Azure DNS handles private DNS zones

### Design Decisions

| Decision | Rationale | Trade-off |
|----------|-----------|-----------|
| AKS in East US | Primary application region | N/A |
| OpenAI in West US | Compliance - different region | ~30-50ms added latency |
| SQL in West US 2 | Geo-redundancy | Cross-region latency |
| kubectl (not Helm) | Simpler for single app | Less templating flexibility |
| LoadBalancer | Direct access | No URL-based routing |
| 300s Gunicorn timeout | Handle slow AI queries | Higher resource usage |

---

## 🛠️ Challenges & Solutions

### Challenge 1: Cross-Region AI Connectivity

**Problem**: Azure OpenAI must be in different region but accessible from AKS

**Solution**: 
- Deployed OpenAI in West US, AKS in East US
- Created Private DNS Zone for OpenAI
- Traffic routes via Azure backbone

### Challenge 2: Gunicorn Worker Timeouts

**Problem**:  Default 30-second timeout caused worker crashes

**Solution**: 
```dockerfile
CMD gunicorn --bind 0.0.0.0:8080 --workers 2 --timeout 300 --keep-alive 5 main:app
```

### Challenge 3: Rate Limiting (429 Errors)

**Problem**: Azure OpenAI rate limit exceeded during testing

**Solution**:  
- Wait 60 seconds between heavy queries
- Consider increasing OpenAI quota for production

### Lessons Learned

1. ✅ Gunicorn timeout must exceed AI response time
2. ✅ Private DNS Zones must be linked to VNets
3. ✅ Cross-region networking requires careful planning
4. ✅ Use managed identities to avoid credential management

---

## 🎬 Demo

[![AI SQL Agent Demo](https://img.youtube.com/vi/eto3kSOqfFc/maxresdefault.jpg)](https://youtu.be/eto3kSOqfFc)

▶️ **[Watch Full Demo on YouTube](https://youtu.be/eto3kSOqfFc)**

**Live Application**:  http://4.157.31.99

### Quick Demo Commands

```powershell
# Open in browser
Start-Process "http://4.157.31.99"

# Test queries in UI: 
# - "show all customers" → Basic SELECT
# - "total revenue" → Aggregation
# - "top 5 customers by spending" → JOIN + GROUP BY
# - "products low in stock" → Filtering
```

---

## 📁 Repository Structure

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
├── k8s/                               # Kubernetes manifests (USED)
│   └── sql-agent. yaml                 # Main deployment manifest
│
├── kubernetes/                        # Alternative:  Kustomize structure
│   ├── base/
│   └── overlays/staging/
│
├── helm/sql-agent/                    # Alternative: Helm chart
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
│
└── docs/                              # Documentation
    └── architecture/
```

---

## 📧 Contact

**Author**:  Ghulam Mujtaba  | mujtabacif@gmail.com 

**Live Demo**: http://4.157.31.99
