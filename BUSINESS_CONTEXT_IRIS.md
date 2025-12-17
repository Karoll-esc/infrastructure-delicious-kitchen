# Plantilla para Diligenciar Contexto de Negocio
## Proyecto: Delicious Kitchen

---

## 1. Descripción del Proyecto

**Nombre del Proyecto:** Delicious Kitchen

**Objetivo del Proyecto:** Sistema de gestión de pedidos para un restaurante de comida rápida que permite a los clientes realizar pedidos sin necesidad de registro, hacer seguimiento del estado de preparación en tiempo real, y recibir notificaciones cuando su pedido esté listo para recoger. Incluye panel de administración para gestión de usuarios, cocina, reportes/analytics y reseñas de clientes.

---

## 2. Flujos Críticos del Negocio

### Principales Flujos de Trabajo

1. **Flujo de Pedido del Cliente:**
   - Cliente selecciona productos del menú
   - Ingresa datos: dirección, correo electrónico y notas adicionales (sin registro requerido)
   - Se genera número de pedido único
   - El pedido llega al panel de cocina
   - Cliente recibe notificaciones de estado (en preparación → listo)
   - Cliente recoge el pedido

2. **Flujo de Cocina:**
   - Pedidos aparecen en panel de Kitchen con estado "Recibido"
   - Cocinero inicia preparación → "Start Cooking" → estado cambia a "En Preparación"
   - Al terminar → "Mark as Ready" → estado cambia a "Listo"
   - Se envía notificación automática al cliente

3. **Flujo de Cancelación:**
   - Cliente puede cancelar pedido SOLO si no ha iniciado la preparación
   - Una vez en preparación, el botón de cancelar no debe estar disponible
   - Al cancelar, el pedido queda marcado como "Cancelado"

4. **Flujo de Reseñas:**
   - Cliente puede dejar reseña después de que el pedido esté listo
   - Reseña incluye rating (estrellas) y comentarios
   - Admin debe aprobar reseña antes de que sea visible públicamente
   - Admin puede aprobar ("Approve") u ocultar ("Hide") reseñas

5. **Flujo de Gestión de Usuarios (Admin):**
   - Admin crea usuarios con: nombre completo, correo, contraseña y rol
   - Admin puede activar/desactivar usuarios (no se eliminan de la BD, solo se inhabilitan)
   - Usuarios deshabilitados pierden acceso al sistema

### Módulos o Funcionalidades Críticas

| Módulo | Descripción |
|--------|-------------|
| **Panel de Pedidos** | Creación de pedidos por clientes sin registro |
| **Panel de Cocina (Kitchen)** | Gestión de estados de preparación de pedidos |
| **Sistema de Notificaciones** | Alertas en tiempo real al cliente sobre estado del pedido |
| **Gestión de Usuarios** | CRUD de usuarios administradores y personal de cocina |
| **Gestión de Reseñas** | Aprobación/ocultamiento de reseñas de clientes |
| **Reportes/Analytics** | Dashboard con métricas, filtros por fecha, exportación CSV |
| **Internacionalización (i18n)** | Soporte para inglés y español (parcialmente implementado) |

---

## 3. Reglas de Negocio y Restricciones

### Reglas de Negocio Relevantes

1. **Cancelación de Pedidos:**
   - Un pedido SOLO puede cancelarse si aún no ha iniciado la preparación
   - Una vez que el estado cambia a "En Preparación", la cancelación debe estar bloqueada

2. **Gestión de Usuarios:**
   - Los usuarios eliminados NO se borran de la base de datos
   - Solo se deshabilitan (campo en Firebase Auth: `disabled: true`)
   - Los usuarios deshabilitados no pueden acceder al sistema

3. **Reseñas:**
   - Las reseñas requieren aprobación de un administrador antes de ser visibles públicamente
   - Solo se pueden crear reseñas cuando el pedido está en estado "Listo"

4. **Rutas Protegidas:**
   - Cada rol tiene acceso únicamente a las rutas permitidas según su perfil
   - Si un usuario intenta acceder a una ruta no autorizada, es redirigido al login

5. **Productos del Menú:**
   - ⚠️ **LIMITACIÓN ACTUAL:** Los productos están "quemados" (hardcoded)
   - No existe funcionalidad para crear/editar productos desde el sistema

### Regulaciones o Normativas

- **Seguridad de Contraseñas:** Las contraseñas deben estar enmascaradas en la interfaz (⚠️ pendiente de implementar completamente)
- **Protección de Datos:** Configuración de Firebase Auth para manejo seguro de credenciales
- **Archivos Sensibles:** Los archivos de configuración con claves (`.env`, credenciales Firebase) NO deben subirse al repositorio

---

## 4. Perfiles de Usuario y Roles

### Perfiles o Roles de Usuario en el Sistema

| Rol | Descripción |
|-----|-------------|
| **Admin (Administrador)** | Acceso completo a todas las funcionalidades del sistema |
| **Kitchen (Cocina)** | Acceso únicamente al panel de cocina para gestionar preparación de pedidos |
| **Cliente (sin registro)** | Usuario anónimo que realiza pedidos sin necesidad de cuenta |

### Permisos y Limitaciones de Cada Perfil

| Funcionalidad | Admin | Kitchen | Cliente |
|---------------|:-----:|:-------:|:-------:|
| Ver panel de administración | ✅ | ❌ | ❌ |
| Gestión de usuarios | ✅ | ❌ | ❌ |
| Panel de cocina | ✅ | ✅ | ❌ |
| Reportes/Analytics | ✅ | ❌ | ❌ |
| Gestión de reseñas | ✅ | ❌ | ❌ |
| Crear pedidos | ✅ | ❌ | ✅ |
| Ver estado de pedido | ✅ | ✅ | ✅ (solo su pedido) |
| Cancelar pedido | ✅ | ❌ | ✅ (solo antes de preparación) |
| Crear reseña | ❌ | ❌ | ✅ (solo cuando pedido está listo) |

---

## 5. Condiciones del Entorno Técnico

### Plataformas Soportadas

- **Web únicamente** - Aplicación web accesible desde navegador
- **No hay soporte móvil nativo** - No existe app iOS/Android

### Tecnologías o Integraciones Clave

| Tecnología | Uso |
|------------|-----|
| **Firebase Auth** | Autenticación de usuarios administradores y personal |
| **Firebase Firestore** | Colección de usuarios con datos adicionales (nombre, rol) |
| **MongoDB** | Base de datos principal para pedidos, reseñas, analytics |
| **Docker + Docker Compose** | Contenedorización y orquestación de servicios |
| **RabbitMQ** | Mensajería entre microservicios |
| **Node.js + TypeScript** | Backend con 4 microservicios |
| **React + Vite** | Frontend |
| **i18next** | Internacionalización (inglés/español) |

### Arquitectura de Microservicios (Backend)

1. **API Gateway** - Punto de entrada, conexión con Firebase
2. **Order Service** - Gestión de pedidos
3. **Kitchen Service** - Gestión de cocina
4. **Notification Service** - Envío de notificaciones

---

## 6. Casos Especiales o Excepciones

### Escenarios Alternos que Deben Considerarse

1. **Token de Sesión Corto:**
   - ⚠️ El tiempo del token es de 3.6 segundos (muy corto)
   - Causa que los usuarios deban re-loguearse frecuentemente
   - **Acción requerida:** Aumentar tiempo de expiración del token

2. **Recuperación de Contraseña:**
   - ⚠️ El botón existe en la UI pero NO funciona
   - No estaba en el alcance original

3. **Inconsistencia en Nombres de Base de Datos:**
   - Se detectaron variaciones en mayúsculas/minúsculas en nombres de colecciones
   - Ejemplo: "Batabase" vs "batabase" vs "DATABASE"
   - **Acción requerida:** Verificar consistencia en todo el código

4. **Validación de Datos en Analytics:**
   - Los reportes pueden mostrar datos inconsistentes
   - Ejemplo: Total de órdenes vs cantidad no coinciden (posiblemente por pedidos cancelados)
   - **Acción requerida:** Validar que los datos correspondan a la base de datos real

5. **Productos Hardcodeados:**
   - No hay CRUD de productos/menú
   - Los items del menú están fijos en el código
   - **Posible mejora futura**

6. **Internacionalización Incompleta:**
   - Algunas secciones no tienen traducción (generación de orden, roles)
   - **Acción requerida:** Completar archivos de traducción

7. **Ajuste Visual en Gráficos:**
   - El texto en las barras de los gráficos de analytics no se ajusta correctamente
   - **Mejora de UI pendiente**

8. **URLs Hardcodeadas:**
   - Las URLs del backend están "quemadas" en el frontend
   - **Recomendación:** Centralizar en variables de entorno

---

## 7. Resumen de Dolores Técnicos (de la Transferencia)

| Dolor | Prioridad | Estado |
|-------|-----------|--------|
| Token de sesión muy corto (3.6s) | 🔴 Alta | Pendiente |
| Contraseñas sin enmascarar | 🔴 Alta | Parcialmente resuelto |
| No hay CRUD de productos/menú | 🟡 Media | Limitación conocida |
| Recuperar contraseña no funciona | 🟡 Media | Fuera de alcance |
| Nombres de BD inconsistentes | 🟡 Media | Parcialmente resuelto |
| Validación de datos en analytics | 🟡 Media | Pendiente |
| i18n incompleto | 🟢 Baja | Pendiente |
| Texto en gráficos no ajusta | 🟢 Baja | Pendiente |
| URLs hardcodeadas | 🟢 Baja | Pendiente |

---

## 8. Ubicación de Recursos Clave

| Recurso | Ubicación |
|---------|-----------|
| Historias de Usuario | `/hu/` (carpeta en frontend y backend) |
| Tests Unitarios | Cada microservicio tiene su carpeta de tests |
| Configuración Firebase | Archivo compartido por el equipo anterior (no en repo) |
| Resultados de Tests | Archivo `.md` informativo en el proyecto |

---

*Documento generado a partir de la sesión de Transferencia de Conocimiento*  
*Fecha: 11 de Diciembre de 2024*  
*Participantes: Gerardo Leyton, Andrés Burgos, Nevardo Ospina → Carlos Cuadrado, Karoll Escalante*
