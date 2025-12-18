# Este script clona TODOS los repositorios en la estructura correcta

$currentDir = Get-Location
Write-Host "📁 Directorio actual: $currentDir" -ForegroundColor Cyan

# Subir DOS niveles (scripts -> infrastructure -> proyectos)
$targetDir = Split-Path -Parent (Split-Path -Parent $currentDir)
Set-Location $targetDir
Write-Host "📂 Clonando en: $targetDir" -ForegroundColor Cyan

Write-Host "🚀 Clonando repositorios..." -ForegroundColor Green

$repos = @(
    "api-gateway-delicious-kitchen",
    "order-service-delicious-kitchen",
    "kitchen-service-delicious-kitchen",
    "notification-service-delicious-kitchen",
    "frontend-delicious-kitchen"
)

foreach ($repo in $repos) {
    if (Test-Path $repo) {
        Write-Host "⏭️  $repo ya existe, saltando..." -ForegroundColor Yellow
    } else {
        Write-Host "📥 Clonando $repo..." -ForegroundColor Cyan
        git clone "https://github.com/Karoll-esc/$repo.git"
    }
}

Write-Host "✅ Todos los repositorios clonados y dependencias instaladas!" -ForegroundColor Green

# Volver al directorio original
Set-Location $currentDir