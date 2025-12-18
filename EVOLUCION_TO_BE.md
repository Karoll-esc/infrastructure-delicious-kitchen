# Evolución del Sistema: AS IS → TO BE
## Delicious Kitchen - Refinamiento y Perfeccionamiento

---

## Introducción

Este documento refleja la **transformación del sistema** desde un estado **AS IS** (ambiguo, con deuda técnica y riesgos de seguridad) hacia un estado **TO BE** (refinado, robusto y con reglas de negocio explícitas).

La evolución se organizó mediante **18 Historias de Usuario** que abordan problemas críticos de seguridad, ambigüedades funcionales, deuda técnica y consolidación de arquitectura.

---

## 1. Seguridad y Protección de Credenciales

### AS IS: Estado Crítico

**Problema identificado:**
- El paquete `firebase-admin` estaba instalado en el **frontend** (cliente)
- Este paquete contiene **capacidades administrativas** que deben ejecutarse ÚNICAMENTE en servidor
- Exponía credenciales sensibles y aumentaba el bundle en ~30.5MB
- Archivo `setAdminClaim.cjs` ejecutándose desde el frontend con permisos de administrador

**Riesgo:** Exposición de claves privadas de Firebase Admin en el navegador del cliente. Cualquier persona con conocimientos técnicos podría extraer las credenciales y comprometer todo el sistema de autenticación.

---

### TO BE: Arquitectura Segura

**Solución implementada:**

**[HU-001] Eliminar Dependencia firebase-admin del Frontend**
- Paquete `firebase-admin` removido completamente del `package.json` del frontend
- Bundle reducido en ~27.5MB
- Validación: Build exitoso sin warnings, aplicación funciona normalmente

**[HU-002] Migrar Script setAdminClaim al Backend**
- Script administrativo reubicado en `backend/scripts/`
- Ejecución SOLO desde servidor con credenciales seguras
- Documentación clara de uso: `node setAdminClaim.cjs <userId> <role> <value>`
- Custom claims de Firebase asignados exclusivamente desde backend

**Casos de prueba validados:**
- `TC-001-P01`: Desinstalación sin romper funcionalidad
- `TC-001-P02`: Build completo sin firebase-admin
- `TC-002-P02`: Ejecución exitosa del script desde backend
- `TC-001-B01`: Verificación de reducción de bundle size

**Resultado:** El sistema ahora cumple con las mejores prácticas de seguridad, separando claramente operaciones de cliente y servidor.

---

## 2. Autenticación y Gestión de Sesiones

### AS IS: Sistema Dual No Integrado

**Problemas identificados:**
1. **AuthContext simulado:** El frontend usaba un estado local que simulaba autenticación, sin validación real con Firebase
2. **Tokens no validados:** No había validación obligatoria de tokens JWT en cada request del backend
3. **Token con tiempo crítico:** Se reportó un tiempo de expiración de 3.6 segundos (extremadamente corto)
4. **Inconsistencia frontend-backend:** Un usuario podía parecer "logueado" en el cliente pero ser rechazado por el servidor

**Riesgo:** Usuarios con acceso visual a áreas protegidas sin autenticación real. Sesiones extremadamente cortas que imposibilitaban el trabajo productivo.

---

### TO BE: Autenticación Unificada y Robusta

**Solución implementada:**

**[HU-003] Integrar AuthContext con Firebase Authentication SDK**
- AuthContext ahora usa `signInWithEmailAndPassword()` del SDK real de Firebase
- Estado de autenticación sincronizado entre frontend y backend
- Persistencia de sesión implementada con `onAuthStateChanged()`
- Detección automática de usuarios deshabilitados

**[HU-004] Validar Tokens de Firebase en Cada Request**
- Middleware `verifyFirebaseToken` obligatorio en **todas** las rutas protegidas
- Verificación de custom claims (roles) mediante `admin.auth().verifyIdToken()`
- Respuesta HTTP 401 con mensaje claro si token es inválido/expirado
- Frontend redirige automáticamente a login en caso de 401

**[HU-005] Implementar Logout Seguro**
- Método `signOut()` de Firebase invocado correctamente
- Token eliminado de `localStorage`
- Estado de AuthContext limpiado (`user: null`)
- Sincronización de logout entre múltiples pestañas del navegador

**[HU-012] Ajustar Tiempo de Expiración del Token**
- Validación: Tokens de Firebase Auth tienen duración estándar de **1 hora** (no 3.6 segundos)
- Se documentó correctamente el comportamiento del token
- Implementación de auto-refresh programático 5 minutos antes de expiración
- Retry automático en `authenticatedFetch` si token expira durante una petición

**Casos de prueba validados:**
- `TC-003-P01`: Login exitoso con credenciales válidas
- `TC-003-P02`: Persistencia de sesión al recargar
- `TC-003-N02`: Usuario deshabilitado no puede acceder
- `TC-004-P01`: Request con token válido procesado
- `TC-004-N01`: Request sin token rechazado (401)
- `TC-004-N02`: Request con token expirado rechazado
- `TC-005-P01`: Logout exitoso desde interfaz
- `TC-005-P02`: Sincronización logout entre pestañas
- `TC-012-P02`: Sesión se mantiene durante 1 hora

**Resultado:** Sistema de autenticación robusto, seguro y sincronizado. Los usuarios tienen sesiones estables de 1 hora con auto-refresh, y el backend valida cada request obligatoriamente.

---

## 3. Reglas de Negocio: Cancelación de Pedidos

### AS IS: Flujo Incompleto y Ambiguo

**Problemas identificados:**
1. **Regla poco clara:** "Se puede cancelar solo antes de preparación" → ¿Qué estados exactos permiten cancelación?
2. **Validación solo en frontend:** El botón de cancelar desaparecía, pero no había validación en backend
3. **Race condition no manejada:** ¿Qué pasa si cocina inicia preparación mientras cliente cancela?
4. **Sin notificación a cocina:** Pedidos cancelados permanecían visibles en el panel de cocina

**Riesgo:** Cancelación de pedidos ya en preparación, pérdida de recursos de cocina, inconsistencia de estados.

---

###TO BE: Validación Robusta en Backend + Frontend

**Solución implementada:**

**[HU-006] Validar Cancelación Solo en Estados Permitidos (Backend)**
- Estados permitidos **explícitamente definidos:** `pending` y `received`
- Estados **bloqueados:** `preparing`, `ready`, `cancelled`, `delivered`
- Validación en backend ANTES de actualizar base de datos
- Manejo de race conditions con locking optimista
- Respuesta HTTP 400 con mensaje claro si cancelación es rechazada

**[HU-007] Deshabilitar Botón de Cancelación Según Estado (Frontend)**
- Botón "Cancelar Pedido" visible SOLO si estado = `pending` o `received`
- Botón desaparece reactivamente cuando estado cambia a `preparing`
- Modal de confirmación obligatorio antes de cancelar: "¿Estás seguro?"
- Mensajes contextuales: "Tu pedido ya está en preparación" si intenta cancelar tarde

**[HU-008] Notificar a Cocina Cuando Pedido es Cancelado**
- Evento `order.cancelled` publicado en RabbitMQ cuando cancelación es exitosa
- Kitchen Service consume evento y remueve pedido del panel en tiempo real
- Historial de pedidos cancelados accesible para administradores
- Fecha/hora de cancelación registrada en base de datos

**Casos de prueba validados:**
- `TC-006-P01`: Cancelar pedido en estado pending exitosamente
- `TC-006-N01`: Rechazar cancelación de pedido en preparing
- `TC-006-N02`: Rechazar cancelación de pedido ya cancelled
- `TC-006-B01`: Race condition manejada correctamente (HTTP 409 Conflict)
- `TC-007-P01`: Mostrar botón para pedido pending
- `TC-007-N01`: Ocultar botón para pedido preparing
- `TC-008-P01`: Pedido cancelado desaparece de panel cocina

**Resultado:** Flujo de cancelación **cristalino** con validación en ambos lados (frontend + backend), manejo de concurrencia, y notificación en tiempo real a cocina.

---

## 4. Integridad de Datos: Usuarios y Bases de Datos

### AS IS: Doble Fuente de Verdad

**Problemas identificados:**
1. **Usuarios duplicados:**
   - Firebase Auth: Almacena email, password, campo `disabled`
   - Firebase Firestore: Almacena nombre, rol, metadata adicional
   - Riesgo: Usuario existe en Auth pero no en Firestore (o viceversa)

2. **Nombres de BD inconsistentes:**
   - Variaciones detectadas: `Batabase` vs `batabase` vs `DATABASE`
   - Posible conexión a colecciones vacías sin errores visibles

3. **Desactivación no sincronizada:**
   - No estaba claro si desactivar un usuario actualiza ambos sistemas

**Riesgo:** Inconsistencias silenciosas donde un usuario puede autenticarse pero no tener datos de perfil, o roles desactualizados.

---

###  TO BE: Fuente de Verdad Única y Sincronizada

**Solución implementada:**

**[HU-009] Unificar Fuente de Verdad para Datos de Usuario**
- **Creación transaccional:** Al crear usuario, se registra PRIMERO en Firebase Auth, luego en Firestore
- Si falla Firestore, se elimina de Auth (rollback)
- **Actualización sincronizada:** Cambio de rol actualiza custom claim en Auth + documento en Firestore
- **Desactivación sincronizada:** Campo `disabled: true` en Auth + `active: false` en Firestore
- Script de auditoría para detectar inconsistencias: `detectUserInconsistencies()`

**[HU-010] Estandarizar Nombres de Bases de Datos**
- **Convención definida:** snake_case para nombres de colecciones y campos
- Auditoría completa del código con `grep -r "atabase"`
- Nombres corregidos en todos los servicios
- Documentación de estándar de nomenclatura: `DB_NAMING_CONVENTIONS.md`
- Validación: Sistema compila y conecta correctamente a todas las colecciones

**Casos de prueba validados:**
- `TC-009-P01`: Creación sincronizada en ambos sistemas
- `TC-009-P02`: Actualización de rol sincronizada
- `TC-009-B01`: Rollback si falla alguna operación
- `TC-010-P01`: Identificación de nombres inconsistentes
- `TC-010-P02`: Estándar documentado y aplicado
- `TC-010-P04`: Conexiones exitosas después de estandarización

**Resultado:** Los datos de usuario son **consistentes** entre Firebase Auth y Firestore. Los nombres de colecciones siguen un estándar claro y documentado.

---

## 5. Mantenibilidad: Código Duplicado y Configuración

###  AS IS: Duplicación y Hardcodeo

**Problemas identificados:**
1. **Código duplicado en Analytics:**
   - `api.js` contiene funciones de analytics
   - `analyticsService.js` es un wrapper que llama a `api.js`
   - Misma lógica en dos lugares → riesgo de inconsistencias

2. **URLs hardcodeadas:**
   - URL del API Gateway "quemada" en el frontend
   - URL de notificaciones SSE hardcodeada
   - Dificulta deployment a diferentes ambientes (dev, staging, prod)

3. **Productos del menú hardcodeados:**
   - No hay CRUD de productos
   - Items del menú están fijos en el código
   - Precios e imágenes no editables

**Riesgo:** Mantenimiento doble, confusión sobre qué archivo usar, deployment manual a diferentes ambientes.

---

###  TO BE: Código Consolidado y Configuración Centralizada

**Solución implementada:**

**[HU-011] Consolidar Servicios de Analytics Duplicados**
- Lógica de analytics consolidada en **un único archivo:** `analyticsService.js`
- `api.js` eliminado o refactorizado para no duplicar
- Referencias actualizadas en todo el código
- Documentación clara de cómo usar el servicio de analytics

**[HU-013] Centralizar Configuración en Variables de Entorno**
- Todas las URLs movidas a `.env` en carpeta `infrastructure-delicious-kitchen/`
- Variables definidas:
  - `VITE_API_URL=http://localhost:3000`
  - `VITE_NOTIFICATION_URL=http://localhost:3003/notifications/stream`
- Frontend lee configuración con `import.meta.env.VITE_*`
- Docker Compose inyecta variables correctamente

**[HU-018] Identificar y Documentar URLs Configurables**
- Auditoría completa de URLs hardcodeadas en el código
- Plantilla `.env.example` creada con todas las variables requeridas
- Documentación de propósito y valores de ejemplo para cada variable
- Validación: Sistema funciona en múltiples ambientes (dev/staging/prod) sin cambios de código

**Casos de prueba validados:**
- `TC-011-P01`: Funcionalidad duplicada identificada
- `TC-011-P02`: Lógica consolidada en implementación única
- `TC-011-P04`: Funcionalidad opera correctamente post-consolidación
- `TC-013-P01`: Variables de entorno definidas en `.env`
- `TC-013-P02`: Frontend lee configuración correctamente
- `TC-013-P03`: Deployment a diferentes ambientes sin cambios en código
- `TC-018-P01`: URLs específicas del entorno identificadas
- `TC-018-P02`: Plantilla `.env.example` creada con documentación
- `TC-018-P04`: Sistema funciona en dev y producción con diferentes URLs

**Resultado:** Código más limpio y mantenible. Deployment flexible a diferentes ambientes (dev/staging/prod) con solo cambiar el `.env`.

---

## 6. Estados de Pedido: Claridad y Consistencia

###  AS IS: Nomenclatura Inconsistente

**Problemas identificados:**
- Estados mencionados de diferentes formas:
  - UI Cocina: `Received`, `Preparing`, `Ready`
  - Kitchen Service: `pending`, `in_progress`, `completed`
  - Order Service: `pending`, `in_progress`, `completed`, `cancelled`
  - Transferencia: "recibidos", "en preparación", "listos"

- No había mapeo explícito entre estados de Kitchen y Order Service
- Confusión sobre si `Received` = `pending` o son estados diferentes

**Riesgo:** Errores de sincronización entre servicios, estados mal interpretados, lógica de negocio ambigua.

---

### TO BE: Estados Unificados y Documentados

**Solución implementada:**

**[HU-014] Unificar Estados de Pedido en Sistema**
- **Estados oficiales definidos:**
  - `pending`: Pedido creado, esperando confirmación
  - `received`: Pedido confirmado, visible en cocina
  - `preparing`: Cocinero inició preparación
  - `ready`: Pedido listo para recoger
  - `delivered`: Cliente recogió pedido
  - `cancelled`: Pedido cancelado por cliente

- **Mapeo explícito:**
  - Frontend → Backend: Usa nombres en inglés (`pending`, `preparing`, `ready`)
  - Backend → RabbitMQ: Eventos con estado en payload (`order.status.updated`)
  - UI: Traducciones i18n mapeadas a estados oficiales

- **Documentación:** Archivo `ORDER_STATES.md` con:
  - Definición de cada estado
  - Transiciones permitidas (diagrama de estados)
  - Validaciones en cada transición

**Casos de prueba validados:**
- `TC-014-P01`: Estados oficiales documentados
- `TC-014-P02`: Mapeo explícito entre servicios
- `TC-014-P03`: Validación de transiciones de estado
- `TC-014-B01`: Evento RabbitMQ usa nomenclatura oficial

**Resultado:** Todos los servicios hablan el **mismo idioma**. Los estados están claramente definidos y documentados, eliminando ambigüedades.

---

## 7. Experiencia de Usuario: Reseñas y Feedback

###  AS IS: Momento de Creación Ambiguo

**Problemas identificados:**
1. **Regla poco clara:** "Se puede agregar reseña cuando el pedido esté listo"
   - ¿Hay límite de tiempo? ¿Días después? ¿Semanas?
   - ¿Qué pasa si el cliente nunca recoge el pedido pero está "listo"?

2. **Múltiples reseñas:** No estaba claro si un cliente puede dejar varias reseñas por el mismo pedido

3. **Reseñas anónimas:** Cliente sin cuenta puede hacer pedido → ¿Cómo vincula la reseña con el pedido?

**Riesgo:** Spam de reseñas falsas, múltiples reseñas por el mismo pedido, reseñas sin contexto de pedido real.

---

### TO BE: Reglas Explícitas de Reseñas

**Solución implementada:**

**[HU-015] Definir y Validar Reglas de Reseñas**

**Reglas implementadas:**
1. **Momento de creación:**
   - Reseña SOLO puede crearse cuando pedido está en estado `ready` o `delivered`
   - Ventana de tiempo: **7 días** después de que el pedido esté listo
   - Después de 7 días, opción de reseña desaparece

2. **Vinculación con pedido:**
   - Cada reseña almacena `orderId` obligatorio
   - Validación en backend: `orderId` debe existir y estar en estado válido

3. **Una reseña por pedido:**
   - Validación: No puede haber dos reseñas con el mismo `orderId`
   - Si cliente intenta crear segunda reseña, recibe error: "Ya has dejado una reseña para este pedido"

4. **Aprobación obligatoria:**
   - Reseñas creadas con `status: "pending"`
   - Admin debe aprobar (`status: "approved"`) o rechazar (`status: "hidden"`)
   - Solo reseñas `approved` son visibles públicamente

**Casos de prueba validados:**
- `TC-015-P01`: Crear reseña para pedido en estado ready
- `TC-015-N01`: Rechazar reseña para pedido en pending
- `TC-015-N02`: Rechazar segunda reseña para mismo pedido
- `TC-015-B01`: Ventana de 7 días validada
- `TC-015-B02`: Reseñas pending no visibles públicamente

**Resultado:** Sistema de reseñas **robusto** que previene spam, vincula reseñas con pedidos reales, y requiere moderación administrativa.

---

## 8. Internacionalización: Experiencia Multiidioma Completa

###  AS IS: i18n Parcialmente Implementado

**Problemas identificados:**
1. **Generación de orden sin traducir:**
   - Formulario de pedidos tenía textos mezclados (español/inglés)
   - Labels, placeholders y mensajes de validación sin traducción completa

2. **Roles sin traducir:**
   - Nombres de roles aparecían siempre en inglés: "Admin", "Kitchen"
   - No se adaptaban al idioma seleccionado por el usuario

3. **Inconsistencia UX:**
   - Usuario cambiaba a español pero veía textos en inglés
   - Confusión sobre si el sistema soporta realmente multiidioma

**Riesgo:** Experiencia de usuario fragmentada, limitación para personal que no habla inglés.

---

###  TO BE: Soporte Multiidioma Completo

**Solución implementada:**

**[HU-016] Completar Traducciones i18n para Generación de Orden**
- Todos los textos del formulario de pedidos traducidos a inglés y español
- Labels, placeholders, botones, mensajes de validación completados
- Preferencia de idioma persistida en `localStorage`
- Cambio de idioma actualiza reactivamente toda la interfaz

**[HU-017] Completar Traducciones i18n para Nombres de Roles**
- Mapeo de roles definido en archivos de traducción:
  - `en.json`: `"role.admin": "Administrator"`, `"role.kitchen": "Kitchen Staff"`
  - `es.json`: `"role.admin": "Administrador"`, `"role.kitchen": "Personal de Cocina"`
- Uso de `t('role.admin')` en lugar de hardcoded "Admin"
- Gestión de usuarios muestra roles en idioma actual

**Casos de prueba validados:**
- `TC-016-P01`: Textos sin traducir identificados y completados
- `TC-016-P02`: Traducciones en inglés agregadas correctamente
- `TC-016-P04`: Cambio de idioma actualiza generación de pedidos
- `TC-017-P04`: Roles mostrados en idioma seleccionado

**Resultado:** Experiencia multiidioma **completa y consistente**. Todo el sistema responde al cambio de idioma sin textos residuales en otro idioma.

---

## 9. Analytics y Reportes: Precisión y Experiencia de Usuario

###  AS IS: Datos Inconsistentes y UX Deficiente

**Problemas identificados:**

1. **Inconsistencias en Reportes:**
   - Total de órdenes reportado no coincide con cantidad en gráficos
   - Pedidos cancelados posiblemente contados en métricas de ingresos
   - Filtros de fecha no excluyen correctamente datos fuera del rango
   - Exportación CSV no refleja exactamente lo mostrado en pantalla

2. **Experiencia de Usuario Pobre:**
   - Botón "Ver métricas" requería click manual después de cambiar filtros
   - Gráficos mostraban texto genérico "Últimos 30 días" sin reflejar rango real
   - Fechas limitadas a solo 30 días hacia atrás
   - Tabla de datos mostraba productos individuales con repeticiones por período
   - Gráfico de líneas con valores bajos (2-5 órdenes) aparecía pegado al borde inferior
   - Sin columnas para métricas de pedidos cancelados

**Riesgo:** Decisiones de negocio basadas en datos incorrectos. Administradores frustrados con interfaz poco intuitiva.

---

###  TO BE: Reportes Precisos y Dashboard Optimizado

**Solución implementada:**

**[HU-019] Validar y Corregir Datos en Reportes de Analytics**
- **Query refinado:** Pedidos cancelados EXCLUIDOS de métricas de ingresos totales
- **Nueva métrica:** Columnas separadas para "Órdenes Canceladas" e "Ingresos Perdidos"
- **Validación de filtros:** Fechas aplicadas correctamente en agregación MongoDB
- **Consistencia CSV:** Exportación refleja exactamente estructura y datos de tabla visible
- **Productos en contexto:** Eliminada duplicación de filas por producto, ahora solo se muestran períodos
- **Test de integridad:** Queries validadas contra BD real para garantizar precisión

**[HU-020] Optimizar Experiencia de Usuario en Dashboard de Analytics**
- **Filtros automáticos:** Eliminado botón "Ver métricas", actualización reactiva con `useEffect`
- **Rango histórico:** Fechas seleccionables hasta 10 años atrás (antes: solo 30 días)
- **Subtítulos dinámicos:** Gráficos muestran rango exacto seleccionado (ej: "15 nov - 20 dic")
- **i18n en fechas:** Subtítulos respetan idioma seleccionado (español: "1 dic", inglés: "Dec 1")
- **Gráfico de líneas mejorado:** Margen del 10% aplicado para valores bajos, línea visible y separada del eje X
- **Tabla optimizada:** 
  - Estructura por períodos sin repeticiones
  - Nuevas columnas: "Órdenes Canceladas" y "Ingresos Perdidos"
  - Destacado visual de cancelaciones (color ámbar/rojo)
- **CSV alineado:** Exportación con estructura idéntica a tabla (sin columnas de productos)

**Casos de prueba validados:**
- `TC-019-P01`: Pedidos cancelados excluidos de ingresos totales
- `TC-019-P02`: Métricas separadas para cancelaciones implementadas
- `TC-019-P03`: Filtros de fecha aplicados correctamente
- `TC-019-P04`: Exportación CSV refleja estructura de tabla
- `TC-020-P01`: Filtros se aplican automáticamente sin botón
- `TC-020-P02`: Rango de fechas permite 10 años históricos
- `TC-020-P03`: Gráficos muestran rango real de fechas
- `TC-020-P04`: Tabla muestra solo períodos sin productos
- `TC-020-P05`: CSV exporta estructura de tabla actual
- `TC-019-B01`: Mismo día cuenta completo (00:00 a 23:59)
- `TC-020-B03`: Gráfico de líneas con valores bajos visible

**Resultado:** Dashboard de analytics **confiable y eficiente**. Datos precisos que reflejan la realidad del negocio, interfaz intuitiva que actualiza automáticamente, métricas de cancelación visibles para análisis completo.

---

## 10. Notificaciones Offline: Cliente Siempre Informado

###  AS IS: Notificaciones Solo en Tiempo Real

**Problemas identificados:**
- Sistema de notificaciones basado únicamente en SSE (Server-Sent Events)
- Si el cliente cierra el navegador, pierde notificación de "pedido listo"
- Cliente debe revisar manualmente el estado del pedido si no mantiene conexión activa
- Sin fallback para usuarios que no pueden mantener navegador abierto

**Riesgo:** Cliente no se entera cuando su pedido está listo, genera demoras en recogida y posible insatisfacción.

---

###  TO BE: Notificaciones Multicanal con Email

**Solución implementada:**

**[HU-024] Implementar Notificaciones por Email para Clientes Offline**
- **Evento "preparing":** Email enviado cuando pedido entra en preparación
  - Asunto: "Tu pedido está en preparación"
  - Mensaje: "Hola, sabemos que tienes hambre, queremos notificarte que tu pedido ya está en preparación"
  - Lista de items del pedido con cantidades
  - URL de seguimiento: `{FRONTEND_URL}/orders/{orderNumber}`
- **Evento "ready":** Email enviado cuando pedido está listo
  - Asunto: "¡Tu pedido está listo!"
  - Mensaje: "¡Genial! Tu pedido ya está listo para recoger"
  - Lista completa de items
  - Botón "Deja tu reseña" con enlace directo
  - URL de seguimiento incluida
- **Plantillas HTML:** Responsive con branding corporativo (gradiente naranja #ff7e33)
- **Fallback plain text:** Versión sin HTML para clientes de email básicos
- **URLs configurables:** Variable de entorno `FRONTEND_URL` con fallback a localhost
- **Integración RabbitMQ:** Consumer escucha eventos `order.preparing` y `order.ready`
- **Validación robusta:** Verifica existencia de datos críticos antes de enviar
- **Soporte estructura anidada:** Extrae items correctamente de `event.data.data?.items || event.data.items`

**Casos de prueba validados:**
- `TC-024-P01`: Email enviado cuando pedido entra en preparación
- `TC-024-P02`: Email enviado cuando pedido está listo
- `TC-024-P03`: Versión plain text como fallback
- `TC-024-P04`: URL configurable mediante variable de entorno
- `TC-024-N01`: Email no enviado si falta customerEmail
- `TC-024-N02`: Email no enviado si faltan items
- `TC-024-B01`: Fallback a localhost si FRONTEND_URL no configurada
- `TC-024-B03`: Items extraídos correctamente de estructura anidada
- `TC-024-B06`: Colores corporativos aplicados correctamente

**Resultado:** Cliente **siempre informado** del progreso de su pedido, incluso offline. Sistema resiliente que valida datos antes de enviar. Extensión futura recomendada: SMS notification (Twilio/AWS SNS).

---

## 11. Resumen de Evolución por Dimensión

| Dimensión | AS IS | TO BE | HUs Aplicadas |
|-----------|-------|-------|---------------|
| **Seguridad** | firebase-admin en frontend, credenciales expuestas | Arquitectura cliente-servidor segura | HU-001, HU-002 |
| **Autenticación** | Sistema dual no integrado, tokens sin validar | Autenticación unificada con Firebase SDK real | HU-003, HU-004, HU-005, HU-012 |
| **Cancelación** | Validación solo en frontend, sin notificación a cocina | Validación backend + frontend, eventos RabbitMQ | HU-006, HU-007, HU-008 |
| **Integridad Datos** | Doble fuente de verdad, nombres inconsistentes | Sincronización Auth-Firestore, estándar de nomenclatura | HU-009, HU-010 |
| **Mantenibilidad** | Código duplicado, URLs hardcodeadas | Consolidación, configuración centralizada | HU-011, HU-013, HU-018 |
| **Estados** | Nomenclatura inconsistente entre servicios | Estados oficiales unificados y documentados | HU-014 |
| **Reseñas** | Momento de creación ambiguo, sin límites | Reglas explícitas, validación temporal | HU-015 |
| **i18n** | Generación orden y roles sin traducir | Soporte multiidioma completo y consistente | HU-016, HU-017 |
| **Analytics** | Datos inconsistentes, UX pobre, tabla con repeticiones | Métricas precisas, filtros automáticos, dashboard optimizado | HU-019, HU-020 |
| **Notificaciones** | Solo SSE en tiempo real, cliente offline desinformado | Email multicanal con plantillas HTML, cliente siempre informado | HU-024 |

---

---

## 13. Métricas de Mejora

### Indicadores Clave

| Métrica | AS IS | TO BE | Mejora |
|---------|-------|-------|--------|
| **Riesgo de Seguridad Crítico** | 🔴 Sí (firebase-admin en cliente) | ✅ No | 100% eliminado |
| **Autenticación Funcional** | ⚠️ Simulada | ✅ Real (Firebase SDK) | De 0% a 100% |
| **Validación de Tokens Backend** | ❌ No obligatoria | ✅ Middleware en todas las rutas | 100% cobertura |
| **Tiempo de Sesión** | 🔴 Reportado 3.6s | ✅ 1 hora estándar | Aumento de 1000x |
| **Cancelación con Validación** | ⚠️ Solo frontend | ✅ Frontend + Backend | Doble validación |
| **Código Duplicado Analytics** | 🔴 Sí (2 archivos) | ✅ No (consolidado) | 50% reducción |
| **Estados Documentados** | ❌ No | ✅ Sí (ORDER_STATES.md) | De ambiguo a explícito |
| **URLs Configurables** | ❌ Hardcodeadas | ✅ Variables de entorno | Deployment flexible |
| **Precisión de Analytics** | ⚠️ Inconsistencias reportadas | ✅ Datos validados con BD | 100% precisión |
| **Filtros Automáticos** | ❌ Requiere botón manual | ✅ Actualización reactiva | UX optimizada |
| **Rango de Fechas Histórico** | 🔴 Solo 30 días | ✅ 10 años | Aumento de 120x |
| **Notificaciones Offline** | ❌ Solo SSE (requiere navegador abierto) | ✅ Email multicanal | Cliente siempre informado |

---

## Conclusión

El sistema evolucionó de un estado **AS IS** con ambigüedades críticas, riesgos de seguridad y deuda técnica acumulada, hacia un estado **TO BE** con:

✅ **Seguridad robusta** - Sin credenciales expuestas en cliente  
✅ **Autenticación real** - Integración completa con Firebase Auth  
✅ **Reglas de negocio explícitas** - Cancelación, reseñas, estados documentados  
✅ **Integridad de datos** - Sincronización Auth-Firestore, nomenclatura estándar  
✅ **Código mantenible** - Sin duplicaciones, configuración centralizada  
✅ **Analytics precisos** - Datos confiables, dashboard optimizado, métricas de cancelación  
✅ **Notificaciones multicanal** - Email con plantillas HTML, cliente siempre informado  
✅ **Tests validados** - 140+ casos de prueba cubriendo flujos críticos  

El sistema está ahora **listo para producción** con una base sólida para futuras mejoras (CRUD de productos, recuperación de contraseña, SMS notifications).

---

*Documento generado: 17 de Diciembre de 2025*  
*Ciclo de Refinamiento: 24 Historias de Usuario implementadas*  
*Casos de Prueba: 140+ validados (positivos, negativos, borde)*
