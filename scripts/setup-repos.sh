#!/bin/bash

# Este script clona TODOS los repositorios en la estructura correcta

currentDir=$(pwd)
echo -e "\033[0;36m📁 Directorio actual: $currentDir\033[0m"

# Subir DOS niveles (scripts -> infrastructure -> proyectos)
targetDir=$(dirname $(dirname "$currentDir"))
cd "$targetDir"
echo -e "\033[0;36m📂 Clonando en: $targetDir\033[0m"

echo -e "\033[0;32m🚀 Clonando repositorios...\033[0m"

repos=(
    "api-gateway-delicious-kitchen"
    "order-service-delicious-kitchen"
    "kitchen-service-delicious-kitchen"
    "notification-service-delicious-kitchen"
    "frontend-delicious-kitchen"
)

for repo in "${repos[@]}"; do
    if [ -d "$repo" ]; then
        echo -e "\033[0;33m⏭️  $repo ya existe, saltando...\033[0m"
    else
        echo -e "\033[0;36m📥 Clonando $repo...\033[0m"
        git clone "https://github.com/Karoll-esc/$repo.git"
    fi
done

echo -e "\033[0;32m✅ Todos los repositorios clonados y dependencias instaladas!\033[0m"

# Volver al directorio original
cd "$currentDir"
