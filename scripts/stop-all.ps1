Write-Host "🛑 Deteniendo infraestructura..." -ForegroundColor Red
docker-compose -f docker-compose.dev.yml down
Write-Host "✅ Infraestructura detenida" -ForegroundColor Green