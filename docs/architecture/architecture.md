# Architecture Documentation

## Overview
Production-grade SQL Agent Customer Service Portal on AKS with Azure OpenAI. 

## Network Topology

**East US (Primary Region)**
- VNet: 10.0.0.0/16
- AKS Subnet:  10.0.0.0/22
- Private Endpoints:  10.0.4.0/24

**West US (Compliance Region)**
- Azure OpenAI (Private endpoint only)

## Components

| Component | SKU | Access |
|-----------|-----|--------|
| AKS | Standard | Private cluster |
| SQL Database | S1 | Private endpoint |
| Key Vault | Standard | Private endpoint |
| Storage | Standard_GRS | Private endpoint |
| ACR | Premium | Private endpoint |
| OpenAI | S0 | Private endpoint |

## Security Layers

1. Network Security Groups
2. Private Endpoints
3. Kubernetes Network Policies
4. Managed Identities
5. Key Vault secrets
