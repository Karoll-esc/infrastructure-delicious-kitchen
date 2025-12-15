Write-Host "🚀 Iniciando infraestructura..." -ForegroundColor Green
docker-compose -f ..\docker-compose.dev.yml up -d

Start-Sleep -Seconds 5

Write-Host "🌐 Iniciando API Gateway..." -ForegroundColor Cyan
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd ..\..\api-gateway-delicious-kitchen; npm run dev"

Write-Host "📦 Iniciando Order Service..." -ForegroundColor Yellow
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd ..\..\order-service-delicious-kitchen; npm run dev"

Write-Host "👨‍🍳 Iniciando Kitchen Service..." -ForegroundColor Magenta
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd ..\..\kitchen-service-delicious-kitchen; npm run dev"

Write-Host "🔔 Iniciando Notification Service..." -ForegroundColor Blue
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd ..\..\notification-service-delicious-kitchen; npm run dev"

Start-Sleep -Seconds 3

Write-Host "🎨 Iniciando Frontend..." -ForegroundColor Red
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd ..\..\frontend-delicious-kitchen; npm run dev"

Write-Host "✅ Todos los servicios iniciados!" -ForegroundColor Green