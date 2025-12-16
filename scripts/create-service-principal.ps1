Write-Host "Creating Service Principal..." -ForegroundColor Cyan
$SUB = az account show --query id -o tsv
az ad sp create-for-rbac --name "github-actions-sp" --role contributor --scopes /subscriptions/$SUB --sdk-auth
Write-Host "Copy JSON to GitHub Secret:  AZURE_CREDENTIALS" -ForegroundColor Yellow
