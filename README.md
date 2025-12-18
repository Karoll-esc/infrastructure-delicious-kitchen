# 🏗️ Infraestructura - Delicious Kitchen

Este repositorio contiene la **infraestructura central** del proyecto **Delicious Kitchen**, incluyendo documentación técnica, contexto de negocio, scripts de inicialización y archivos de configuración para orquestar todos los microservicios del sistema.

---

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Scripts de Configuración](#-scripts-de-configuración)
- [Documentación de Negocio](#-documentación-de-negocio)
- [Documentación Técnica](#-documentación-técnica)
- [Documentación de Testing](#-documentación-de-testing)
- [Archivos de Configuración](#️-archivos-de-configuración)
- [Requisitos](#-requisitos)
- [Inicio Rápido](#-inicio-rápido)

---

## 🎯 Descripción General

La carpeta `infrastructure-delicious-kitchen` centraliza:

- **Documentación de negocio** y reglas del dominio
- **Scripts automatizados** para clonar repositorios y levantar servicios
- **Archivos Docker Compose** para entornos de desarrollo y producción
- **Análisis técnico** del estado actual (AS IS) y evolución planificada (TO BE)
- **Historias de Usuario** refinadas y casos de prueba

---

## 🚀 Scripts de Configuración

La carpeta [`scripts/`](scripts/) contiene scripts automatizados para facilitar la configuración inicial y el arranque del proyecto:

### `setup-repos.ps1`
**Propósito:** Clona automáticamente todos los repositorios del proyecto Delicious Kitchen en la estructura correcta.

**Repositorios que clona:**
- [`api-gateway-delicious-kitchen`](https://github.com/Karoll-esc/api-gateway-delicious-kitchen)
- [`order-service-delicious-kitchen`](https://github.com/Karoll-esc/order-service-delicious-kitchen)
- [`kitchen-service-delicious-kitchen`](https://github.com/Karoll-esc/kitchen-service-delicious-kitchen)
- [`notification-service-delicious-kitchen`](https://github.com/Karoll-esc/notification-service-delicious-kitchen)
- [`frontend-delicious-kitchen`](https://github.com/Karoll-esc/frontend-delicious-kitchen)

**Uso:**
```powershell
cd infrastructure-delicious-kitchen/scripts
.\setup-repos.ps1
```

### `start-all.ps1` / `start-all.sh`
**Propósito:** Inicia todos los servicios usando Docker Compose.

**Uso (Windows):**
```powershell
.\scripts\start-all.ps1
```

**Uso (Linux/Mac):**
```bash
./scripts/start-all.sh
```

### `stop-all.ps1`
**Propósito:** Detiene y elimina todos los contenedores Docker del proyecto.

**Uso:**
```powershell
.\scripts\stop-all.ps1
```

---

## 📚 Documentación de Negocio

### [BUSINESS_CONTEXT_IRIS.md](BUSINESS_CONTEXT_IRIS.md)
**Descripción:** Define el **contexto completo del negocio** del proyecto Delicious Kitchen.

**Contiene:**
- Descripción del proyecto y objetivos
- Flujos críticos de negocio (pedidos, cocina, notificaciones, admin)
- Reglas de negocio explícitas
- Actores del sistema (Cliente, Cocinero, Admin)
- Validaciones y restricciones funcionales
- Estados de pedidos y transiciones permitidas

**¿Cuándo consultarlo?** Cuando necesites entender las reglas de negocio, validaciones funcionales o el comportamiento esperado del sistema desde la perspectiva del usuario final.

---

## 🔍 Documentación Técnica

### [HALLAZGOS_AS_IS.md](HALLAZGOS_AS_IS.md)
**Descripción:** Reporte técnico del **estado actual (AS IS)** del sistema, identificando ambigüedades, deuda técnica y problemas críticos.

**Contiene:**
- Ambigüedades funcionales identificadas
- Problemas de seguridad (credenciales expuestas, autenticación dual)
- Deuda técnica acumulada
- Inconsistencias en flujos de negocio
- Riesgos y vulnerabilidades

**¿Cuándo consultarlo?** Para entender qué problemas tenía el sistema antes de la refactorización y por qué se tomaron ciertas decisiones técnicas.

---

### [EVOLUCION_TO_BE.md](EVOLUCION_TO_BE.md)
**Descripción:** Documenta la **transformación del sistema** desde el estado AS IS hacia el estado objetivo (TO BE).

**Contiene:**
- Historias de Usuario implementadas (18 HUs)
- Soluciones aplicadas a problemas críticos
- Arquitectura mejorada y refinada
- Comparativas AS IS → TO BE
- Estrategias de seguridad implementadas
- Consolidación de microservicios

**¿Cuándo consultarlo?** Para comprender la evolución técnica del proyecto, las mejoras implementadas y la arquitectura objetivo.

---

### [HISTORIAS_SIN_REFINAR.md](HISTORIAS_SIN_REFINAR.md)
**Descripción:** Historias de Usuario en su **versión preliminar**, sin casos de prueba ni criterios de aceptación formales.

**¿Cuándo consultarlo?** Para revisar ideas iniciales de funcionalidades antes de su refinamiento formal.

---

### [HISTORIAS_USUARIO_REFINADAS.md](HISTORIAS_USUARIO_REFINADAS.md)
**Descripción:** Historias de Usuario **completamente refinadas** con:
- Descripción formal (Como... Quiero... Para...)
- Criterios de aceptación en formato Gherkin
- Casos de prueba detallados (positivos, negativos, de borde)

**¿Cuándo consultarlo?** Es el documento principal para implementar nuevas funcionalidades o refactorizaciones, ya que define exactamente qué debe hacer cada característica y cómo validarla.

---

## 🧪 Documentación de Testing

### [TEST-PLAN.md](TEST-PLAN.md)
**Descripción:** Plan maestro de pruebas del proyecto.

**Contiene:**
- Estrategia de testing (unitarias, integración, E2E)
- Alcance de las pruebas
- Herramientas utilizadas (Jest, Supertest, etc.)
- Criterios de entrada/salida
- Métricas de cobertura esperadas

**¿Cuándo consultarlo?** Para entender la estrategia completa de testing del proyecto y los estándares de calidad establecidos.

---

### [TEST_CASES.md](TEST_CASES.md)
**Descripción:** Catálogo completo de **casos de prueba** organizados por Historia de Usuario.

**Contiene:**
- Casos de prueba positivos
- Casos de prueba negativos
- Casos de prueba de borde (edge cases)
- Precondiciones y datos de prueba
- Resultados esperados

**¿Cuándo consultarlo?** Al implementar pruebas automatizadas o realizar pruebas manuales de una funcionalidad específica.

---

### [TEST_COVERAGE.md](TEST_COVERAGE.md)
**Descripción:** Reporte de **cobertura de pruebas** del proyecto.

**Contiene:**
- Cobertura por microservicio
- Métricas de líneas, ramas, funciones
- Áreas con baja cobertura
- Objetivos de cobertura

**¿Cuándo consultarlo?** Para evaluar la calidad del testing y identificar áreas que requieren más pruebas.

---

## ⚙️ Archivos de Configuración

### `docker-compose.yml`
Configuración de **producción** para orquestar todos los microservicios con Docker Compose.

**Servicios incluidos:**
- API Gateway
- Order Service
- Kitchen Service
- Notification Service
- Frontend
- MongoDB
- Redis

---

### `docker-compose.dev.yml`
Configuración de **desarrollo** con:
- Montaje de volúmenes para hot-reload
- Puertos expuestos para debugging
- Variables de entorno de desarrollo
- Configuraciones optimizadas para debugging

---

### `.env.example`
Plantilla de variables de entorno requeridas por el proyecto.

**Uso:**
```bash
cp .env.example .env
# Editar .env con tus credenciales reales
```

---

## 🛠️ Requisitos

Antes de usar los scripts de infraestructura, asegúrate de tener instalado:

- **Git** (para clonar repositorios)
- **Docker** y **Docker Compose** (para ejecutar los contenedores)
- **PowerShell** (Windows) o **Bash** (Linux/Mac)
- **Node.js** v18+ (para desarrollo local)

---

## ⚡ Inicio Rápido

### 1️⃣ Clonar todos los repositorios

```powershell
cd infrastructure-delicious-kitchen/scripts
.\setup-repos.ps1
```

### 2️⃣ Configurar variables de entorno

```bash
cp .env.example .env
# Editar .env con tus credenciales de Firebase, SMTP, etc.
```

### 3️⃣ Levantar todos los servicios

**Desarrollo:**
```bash
docker-compose -f docker-compose.dev.yml up -d
```

**Producción:**
```bash
docker-compose up -d
```

### 4️⃣ Verificar que todo está corriendo

```bash
docker-compose ps
```

**URLs de acceso:**
- Frontend: http://localhost:5173
- API Gateway: http://localhost:3000
- Order Service: http://localhost:3001
- Kitchen Service: http://localhost:3002
- Notification Service: http://localhost:3003

