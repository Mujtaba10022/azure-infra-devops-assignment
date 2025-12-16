# Terraform Backend Setup Script
$ErrorActionPreference = "Stop"

$RG = "rg-terraform-state"
$LOCATION = "eastus"
$SA = "tfstate" + (Get-Random -Minimum 10000 -Maximum 99999)
$CONTAINER = "tfstate"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Setting up Terraform Backend" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nLogging in to Azure..." -ForegroundColor Yellow
az login

Write-Host "`nCreating Resource Group:  $RG" -ForegroundColor Yellow
az group create --name $RG --location $LOCATION

Write-Host "`nCreating Storage Account: $SA" -ForegroundColor Yellow
az storage account create `
    --resource-group $RG `
    --name $SA `
    --sku Standard_LRS `
    --encryption-services blob

$KEY = (az storage account keys list --resource-group $RG --account-name $SA --query '[0].value' -o tsv)

Write-Host "`nCreating Container: $CONTAINER" -ForegroundColor Yellow
az storage container create `
    --name $CONTAINER `
    --account-name $SA `
    --account-key $KEY

Write-Host "`n============================================" -ForegroundColor Green
Write-Host " Backend Setup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Storage Account: $SA" -ForegroundColor Yellow
Write-Host "Resource Group:   $RG" -ForegroundColor Yellow
Write-Host ""
Write-Host "UPDATE:  terraform/environments/staging/providers.tf" -ForegroundColor Cyan
Write-Host "UPDATE: GitHub Secret TF_STATE_STORAGE = $SA" -ForegroundColor Cyan
