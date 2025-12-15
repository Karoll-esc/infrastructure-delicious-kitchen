#!/bin/bash

echo "Iniciando infraestructura..."
docker-compose -f ../docker-compose.dev.yml up -d

sleep 5

echo "Iniciando API Gateway..."
gnome-terminal -- bash -c "cd ../../api-gateway-delicious-kitchen && npm run dev; exec bash" 2>/dev/null || \
xterm -hold -e "cd ../../api-gateway-delicious-kitchen && npm run dev" 2>/dev/null || \
x-terminal-emulator -e "cd ../../api-gateway-delicious-kitchen && npm run dev" &

echo "Iniciando Order Service..."
gnome-terminal -- bash -c "cd ../../order-service-delicious-kitchen && npm run dev; exec bash" 2>/dev/null || \
xterm -hold -e "cd ../../order-service-delicious-kitchen && npm run dev" 2>/dev/null || \
x-terminal-emulator -e "cd ../../order-service-delicious-kitchen && npm run dev" &

echo "Iniciando Kitchen Service..."
gnome-terminal -- bash -c "cd ../../kitchen-service-delicious-kitchen && npm run dev; exec bash" 2>/dev/null || \
xterm -hold -e "cd ../../kitchen-service-delicious-kitchen && npm run dev" 2>/dev/null || \
x-terminal-emulator -e "cd ../../kitchen-service-delicious-kitchen && npm run dev" &

echo "Iniciando Notification Service..."
gnome-terminal -- bash -c "cd ../../notification-service-delicious-kitchen && npm run dev; exec bash" 2>/dev/null || \
xterm -hold -e "cd ../../notification-service-delicious-kitchen && npm run dev" 2>/dev/null || \
x-terminal-emulator -e "cd ../../notification-service-delicious-kitchen && npm run dev" &

sleep 3

echo "Iniciando Frontend..."
gnome-terminal -- bash -c "cd ../../frontend-delicious-kitchen && npm run dev; exec bash" 2>/dev/null || \
xterm -hold -e "cd ../../frontend-delicious-kitchen && npm run dev" 2>/dev/null || \
x-terminal-emulator -e "cd ../../frontend-delicious-kitchen && npm run dev" &

echo "Todos los servicios iniciados!"
