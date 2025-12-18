# Casos de Prueba (Test Cases)
## Proyecto: Delicious Kitchen - Refinamiento y Perfeccionamiento

---

## HU-001: Eliminar Dependencia de Seguridad firebase-admin del Frontend

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-001-P01 | Desinstalar firebase-admin del frontend | 1. Verificar que firebase-admin existe en package.json<br>2. Ejecutar `npm uninstall firebase-admin` en directorio frontend<br>3. Verificar cambios en package.json<br>4. Verificar que node_modules no contiene firebase-admin | Comando: `npm uninstall firebase-admin` | - firebase-admin removido de package.json<br>- Carpeta firebase-admin no existe en node_modules |
| TC-001-P02 | Build exitoso sin firebase-admin | 1. Remover firebase-admin del proyecto<br>2. Ejecutar `npm run build`<br>3. Verificar que build se completa sin errores | Comando: `npm run build` | - Build completo exitosamente<br>- Sin warnings de firebase-admin<br>- Aplicación funciona en dev y prod |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-001-N01 | Detectar referencias residuales de firebase-admin | 1. Desinstalar firebase-admin<br>2. Buscar referencias en código: `grep -r "firebase-admin" frontend/src`<br>3. Verificar imports y requires | Pattern búsqueda: "firebase-admin" | - Sin imports de firebase-admin<br>- Sin requires de firebase-admin<br>- Sin llamadas a métodos de firebase-admin |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-001-B01 | Verificar reducción de bundle size | 1. Obtener tamaño bundle antes de remover<br>2. Remover firebase-admin<br>3. Ejecutar build<br>4. Medir tamaño nuevo bundle<br>5. Calcular diferencia | Herramienta: webpack-bundle-analyzer | Reducción de ≥30MB en bundle.js |

---

## HU-002: Migrar Script setAdminClaim al Backend

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-002-P01 | Mover script al backend exitosamente | 1. Verificar que setAdminClaim.cjs existe en frontend<br>2. Crear directorio backend/scripts<br>3. Mover archivo<br>4. Verificar ubicaciones | Archivo: setAdminClaim.cjs | - Archivo existe en backend/scripts/<br>- Archivo NO existe en frontend |
| TC-002-P02 | Ejecutar script desde backend | 1. Ubicar script en backend/scripts/<br>2. Ejecutar: `node setAdminClaim.cjs userId123 role admin`<br>3. Verificar custom claim en Firebase | userId: "test-user-001"<br>claim: "role"<br>value: "admin" | - Custom claim asignado correctamente<br>- Usuario tiene rol actualizado<br>- Mensaje de confirmación en consola |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-002-N01 | Error al ejecutar sin parámetros | 1. Ejecutar script sin argumentos: `node setAdminClaim.cjs`<br>2. Verificar mensaje de error | Sin parámetros | Error indicando parámetros requeridos |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-002-B01 | Documentación completa del script | 1. Verificar existencia de backend/scripts/README.md<br>2. Revisar contenido de documentación | N/A | - Instrucciones de ejecución claras<br>- Parámetros documentados<br>- Ejemplos de uso incluidos |

---

## HU-003: Integrar AuthContext del Frontend con Firebase Authentication SDK

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-003-P01 | Login exitoso con credenciales válidas | 1. Navegar a /login<br>2. Ingresar email válido<br>3. Ingresar contraseña correcta<br>4. Clic en "Iniciar sesión"<br>5. Verificar redirección | Email: admin@test.com<br>Password: TestAdmin123! | - Autenticado con Firebase SDK<br>- Token almacenado en localStorage<br>- Redirigido a dashboard según rol<br>- Sesión persiste al recargar |
| TC-003-P02 | Persistencia de sesión al recargar | 1. Autenticarse exitosamente<br>2. Presionar F5<br>3. Verificar que permanece autenticado | N/A | - Sesión activa detectada<br>- Permanece en misma vista<br>- Info de usuario cargada |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-003-N01 | Login fallido con contraseña incorrecta | 1. Navegar a /login<br>2. Ingresar email válido<br>3. Ingresar contraseña incorrecta<br>4. Clic en "Iniciar sesión" | Email: admin@test.com<br>Password: WrongPass123 | - Firebase rechaza autenticación<br>- Mensaje: "Credenciales inválidas. Verifica tu email y contraseña"<br>- No redirigido<br>- Estado: no autenticado |
| TC-003-N02 | Usuario deshabilitado intenta acceder | 1. Navegar a /login<br>2. Ingresar credenciales de usuario deshabilitado<br>3. Clic en "Iniciar sesión" | Email: disabled@test.com<br>Password: TestDisabled123! | - Firebase rechaza autenticación<br>- Mensaje: "Tu cuenta ha sido deshabilitada. Contacta al administrador"<br>- Sin acceso a rutas protegidas |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-003-B01 | Email con formato válido pero inexistente | 1. Ingresar email con formato correcto que no existe<br>2. Intentar login | Email: noexiste@test.com<br>Password: Any123! | Firebase retorna error de credenciales inválidas |

---

## HU-004: Validar Tokens de Firebase en Cada Request del Backend

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-004-P01 | Request con token válido procesado | 1. Autenticarse y obtener token<br>2. Hacer GET a /api/orders<br>3. Incluir header Authorization<br>4. Verificar respuesta | Header: Authorization: Bearer <valid_token> | - Token validado exitosamente<br>- Petición procesada<br>- HTTP 200<br>- Datos retornados |
| TC-004-P02 | Validación de custom claims (roles) | 1. Autenticarse con usuario role=kitchen<br>2. Hacer request a endpoint de kitchen<br>3. Hacer request a endpoint admin<br>4. Verificar respuestas | Token con claim: {role: "kitchen"} | - Acceso permitido a endpoints kitchen<br>- HTTP 403 en endpoints admin |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-004-N01 | Request sin token rechazado | 1. Hacer request a /api/users<br>2. No incluir header Authorization<br>3. Verificar respuesta | Sin header Authorization | - HTTP 401 Unauthorized<br>- Body: {"error": "Token de autenticación requerido"} |
| TC-004-N02 | Request con token expirado | 1. Obtener token válido<br>2. Esperar expiración (o modificar exp)<br>3. Hacer request con token expirado | Token expirado | - Firebase rechaza token<br>- HTTP 401<br>- Body: {"error": "Token inválido o expirado"}<br>- Frontend redirige a login |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-004-B01 | Token manipulado (alterado) | 1. Obtener token válido<br>2. Modificar payload del token<br>3. Enviar request con token alterado | Token JWT modificado | - Firebase detecta manipulación<br>- HTTP 401<br>- Token rechazado |

---

## HU-005: Implementar Logout Seguro y Limpieza de Sesión

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-005-P01 | Logout exitoso desde interfaz | 1. Autenticarse en el sistema<br>2. Navegar a dashboard<br>3. Clic en "Cerrar sesión"<br>4. Verificar estado | N/A | - Desconectado de Firebase (signOut())<br>- Token eliminado de localStorage<br>- AuthContext = null<br>- Redirigido a /login |
| TC-005-P02 | Sincronización logout entre pestañas | 1. Autenticarse en pestaña A<br>2. Abrir pestaña B con misma sesión<br>3. Cerrar sesión en pestaña A<br>4. Verificar pestaña B | N/A | - Pestaña B detecta cambio<br>- Pestaña B actualiza a no autenticado<br>- Ambas redirigen a login |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-005-N01 | Bloqueo de rutas protegidas post-logout | 1. Cerrar sesión correctamente<br>2. Intentar acceder a /dashboard escribiendo URL | URL: /dashboard | - Sistema detecta sin token<br>- Redirige a /login<br>- Mensaje: "Debes iniciar sesión para acceder" |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-005-B01 | Logout con token ya expirado | 1. Esperar que token expire<br>2. Intentar logout | Token expirado | Logout procede normalmente, limpia estado local |

---

## HU-006: Validar Cancelación de Pedidos Solo en Estados Permitidos (Backend)

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-006-P01 | Cancelar pedido en estado pending | 1. Crear pedido con status=pending<br>2. POST a /api/orders/ORD-12345/cancel<br>3. Verificar respuesta y BD | orderId: ORD-12345<br>status: pending | - Estado cambia a "cancelled"<br>- cancelledAt actualizado<br>- HTTP 200<br>- Body: {"message": "Pedido cancelado exitosamente"} |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-006-N01 | Rechazar cancelación de pedido preparing | 1. Crear pedido con status=preparing<br>2. POST a /api/orders/ORD-67890/cancel<br>3. Verificar respuesta | orderId: ORD-67890<br>status: preparing | - Estado NO cambia<br>- HTTP 400<br>- Body: {"error": "No se puede cancelar un pedido en preparación"} |
| TC-006-N02 | Rechazar cancelación de pedido ya cancelled | 1. Crear pedido con status=cancelled<br>2. POST a /api/orders/ORD-99999/cancel | orderId: ORD-99999<br>status: cancelled | - HTTP 400<br>- Body: {"error": "El pedido ya está cancelado"} |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-006-B01 | Race condition: cancelación vs inicio preparación | 1. Crear pedido status=received<br>2. Enviar simultáneamente:<br>  - POST /api/kitchen/ORD-11111/start<br>  - POST /api/orders/ORD-11111/cancel<br>3. Verificar resultados | orderId: ORD-11111<br>status: received<br>Peticiones simultáneas | - Solo UNA operación exitosa<br>- Primera en obtener lock prevalece<br>- Segunda retorna HTTP 409 Conflict<br>- Body: {"error": "El estado del pedido cambió durante la operación"} |

---

## HU-007: Deshabilitar Botón de Cancelación en Frontend Según Estado

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-007-P01 | Mostrar botón para pedido pending | 1. Crear pedido con status=pending<br>2. Navegar a página de seguimiento<br>3. Verificar UI | orderId: ORD-001<br>status: pending | - Botón "Cancelar Pedido" visible<br>- Botón habilitado (clickeable)<br>- Estilos normales |
| TC-007-P02 | Confirmación antes de cancelar | 1. Ver botón habilitado<br>2. Clic en "Cancelar Pedido"<br>3. Verificar modal | status: pending | - Modal de confirmación aparece<br>- Mensaje: "¿Estás seguro de que deseas cancelar este pedido?"<br>- Botones: "Sí, cancelar" y "No, mantener pedido" |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-007-N01 | Ocultar botón para pedido preparing | 1. Crear pedido con status=preparing<br>2. Navegar a seguimiento<br>3. Verificar UI | orderId: ORD-002<br>status: preparing | - Botón "Cancelar Pedido" NO visible<br>- Mensaje: "Tu pedido ya está en preparación"<br>- Estado: "En Preparación ⏳" |
| TC-007-N02 | Ocultar botón para pedido ready | 1. Pedido con status=ready<br>2. Ver página seguimiento | orderId: ORD-003<br>status: ready | - Sin opción de cancelación<br>- Mensaje: "¡Tu pedido está listo! Puedes pasar a recogerlo"<br>- Estado: "Listo ✅" |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-007-B01 | Cambio de estado mientras usuario en página | 1. Usuario viendo pedido pending con botón visible<br>2. Backend cambia estado a preparing<br>3. Verificar UI se actualiza | Estado cambia de pending a preparing | Botón desaparece reactivamente sin recargar |

---

## HU-008: Notificar a Cocina Cuando un Pedido es Cancelado

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-008-P01 | Pedido cancelado desaparece de panel cocina | 1. Pedido ORD-12345 visible en panel cocina (status=received)<br>2. Cliente cancela desde frontend<br>3. Verificar panel cocina | orderId: ORD-12345<br>status: received | - Order Service publica "order.cancelled" en RabbitMQ<br>- Kitchen Service consume evento<br>- Pedido desaparece de panel<br>- Sin rastro visual |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-008-N01 | Evento no publicado si cancelación falla | 1. Intentar cancelar pedido en preparing<br>2. Verificar RabbitMQ | orderId con status=preparing | - Cancelación rechazada<br>- Evento "order.cancelled" NO publicado |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-008-B01 | Historial de pedidos cancelados accesible | 1. Login como admin<br>2. Navegar a historial<br>3. Filtrar por status=cancelled | role: admin | - Pedidos cancelled visibles<br>- Fecha/hora de cancelación mostrada<br>- Filtro funcional |

---

## HU-009: Unificar Fuente de Verdad para Datos de Usuario

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-009-P01 | Crear usuario sincronizado en Auth y Firestore | 1. Admin crea nuevo usuario<br>2. Verificar Firebase Auth<br>3. Verificar Firestore collection "users" | email: test@example.com<br>password: Test123!<br>name: Test User<br>role: kitchen | - Usuario en Firebase Auth con UID<br>- Documento en Firestore con mismo UID<br>- Campos: {name, email, role, createdAt, active: true}<br>- Ambos creados (transacción atómica) |
| TC-009-P02 | Actualizar rol sincronizadamente | 1. Usuario existe en ambos sistemas (UID: abc123)<br>2. Admin actualiza rol a "kitchen"<br>3. Verificar ambos sistemas | uid: abc123<br>newRole: kitchen | - Custom claim "role" en Firebase Auth = kitchen<br>- Campo "role" en Firestore = kitchen<br>- Ambas actualizaciones completas |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-009-N01 | Rollback si falla creación en Firestore | 1. Simular fallo en creación Firestore<br>2. Intentar crear usuario<br>3. Verificar Firebase Auth | email: fail@test.com | - Usuario NO creado en Firebase Auth<br>- Transacción revertida<br>- Datos consistentes |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-009-B01 | Detectar inconsistencias existentes | 1. Crear usuario solo en Auth (manual)<br>2. Crear documento solo en Firestore (manual)<br>3. Ejecutar script auditoría | N/A | - Lista usuarios en Auth sin Firestore<br>- Lista documentos Firestore sin Auth<br>- Reporte de inconsistencias generado |
| TC-009-B02 | Desactivar usuario sincronizadamente | 1. Usuario activo (UID: xyz789)<br>2. Admin desactiva usuario<br>3. Verificar ambos sistemas | uid: xyz789 | - Firebase Auth: disabled = true<br>- Firestore: active = false<br>- Usuario no puede autenticarse<br>- Cambios atómicos |

---

## HU-010: Estandarizar y Verificar Nombres de Bases de Datos y Colecciones

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-010-P01 | Auditar nombres de colecciones | 1. Ejecutar script búsqueda de conexiones BD<br>2. Analizar resultados | Pattern: conexión a MongoDB/Firestore | - Lista nombres de BDs usados<br>- Lista nombres de colecciones<br>- Variaciones identificadas (ej: orders vs Orders vs ORDERS) |
| TC-010-P02 | Corregir nombres inconsistentes | 1. Identificar "Batabase" y "ORDERS"<br>2. Actualizar a "database" y "orders"<br>3. Compilar código | Incorrecto: Batabase, ORDERS<br>Correcto: database, orders | - Única forma de referencia<br>- Variantes eliminadas<br>- Código compila sin errores |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-010-N01 | Error de conexión con nombre incorrecto | 1. Intentar conectar a "Orders" (mayúscula)<br>2. Verificar error | collection: "Orders" (incorrecto) | - Error de conexión o colección vacía<br>- Logs indican problema |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-010-B01 | Verificar conexiones post-estandarización | 1. Estandarizar todos los nombres<br>2. Ejecutar tests de integración<br>3. Verificar conexiones | N/A | - Todas conexiones exitosas<br>- Datos obtenidos correctamente<br>- Sin errores "colección no encontrada" |
| TC-010-B02 | Documentar estándar de nomenclatura | 1. Crear DB_NAMING_CONVENTIONS.md<br>2. Documentar: lowercase, snake_case | N/A | - Archivo creado<br>- Reglas claras (lowercase, snake_case)<br>- Ejemplos incluidos |

---

## HU-011: Consolidar Servicios de Analytics Duplicados

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-011-P01 | Identificar funciones duplicadas | 1. Analizar api.js<br>2. Analizar analyticsService.js<br>3. Comparar funciones | Archivos: api.js, analyticsService.js | - Lista de funciones duplicadas<br>- Verificación de equivalencia (getOrderStats, getRevenueData) |
| TC-011-P02 | Consolidar en analyticsService.js | 1. Mover lógica única de api.js<br>2. Eliminar duplicados de api.js<br>3. Estructurar analyticsService.js | N/A | - analyticsService.js contiene todas las funciones<br>- api.js sin funciones analytics<br>- Código documentado |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-011-N01 | Error de compilación por imports obsoletos | 1. Consolidar código<br>2. No actualizar imports<br>3. Intentar compilar | Imports apuntando a api.js | - Errores de compilación<br>- Funciones no encontradas |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-011-B01 | Verificar funcionalidad intacta post-consolidación | 1. Consolidar código<br>2. Ejecutar suite tests analytics<br>3. Verificar dashboard | N/A | - Todos tests pasan<br>- Dashboard muestra métricas correctamente<br>- Comportamiento idéntico a versiones anteriores |
| TC-011-B02 | Actualizar referencias en código | 1. Buscar imports de analytics<br>2. Actualizar a analyticsService.js<br>3. Compilar | N/A | - Imports actualizados<br>- Cero referencias a api.js para analytics<br>- Sin warnings de imports no usados |

---

## HU-012: Ajustar Tiempo de Expiración del Token de Sesión

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-012-P01 | Configurar token a 1 hora mínimo | 1. Acceder config Firebase Auth<br>2. Actualizar tiempo expiración a 3600s<br>3. Documentar cambio | Nuevo valor: 3600 segundos (1 hora) | - Token ID con tiempo vida 1 hora<br>- Documentado en config proyecto<br>- Aplicado en dev y prod |
| TC-012-P02 | Verificar nueva duración del token | 1. Usuario inicia sesión<br>2. Obtener token<br>3. Verificar expiry time<br>4. Trabajar 55 minutos<br>5. Verificar sesión activa | N/A | - Token con expiry 3600s<br>- Usuario trabaja 1h sin desconexión<br>- Al expirar (>1h), redirige a login con mensaje: "Tu sesión ha expirado. Por favor, inicia sesión nuevamente" |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-012-N01 | Token expira después de 1 hora | 1. Iniciar sesión<br>2. Esperar >1 hora<br>3. Intentar hacer request | Token con >3600s antigüedad | - Sistema detecta expiración<br>- Redirige a login<br>- Mensaje de sesión expirada |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-012-B01 | Refresh token automático antes de expiración | 1. Usuario autenticado<br>2. Esperar hasta 5 min antes de expirar<br>3. Verificar renovación | Tiempo restante: 5 minutos | - Sistema intenta renovar token automáticamente<br>- Si exitoso: usuario continúa sin interrupción<br>- Si falla: redirige a login |
| TC-012-B02 | Verificar configuración actual del token | 1. Acceder config Firebase Auth<br>2. Revisar tiempo expiración actual<br>3. Documentar | N/A | - Valor actual documentado (3.6s o 1h)<br>- Identificado si es token custom o estándar |

---

## HU-013: Sistema de Encuestas de Proceso (Surveys)

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-013-P01 | Cliente envía encuesta exitosamente | 1. Pedido ORD-777 en estado "preparing"<br>2. Cliente completa encuesta<br>3. POST a /api/surveys<br>4. Verificar creación | orderNumber: ORD-777<br>status: preparing<br>waitTimeRating: 4<br>staffAttentionRating: 5 | - Sistema valida ratings 1-5<br>- Encuesta guardada vinculada a ORD-777<br>- HTTP 201<br>- Body: {"message": "¡Gracias por tu opinión!"} |
| TC-013-P02 | Encuesta válida para pedido en estado ready | 1. Pedido ORD-888 en estado "ready"<br>2. Cliente completa encuesta<br>3. POST a /api/surveys | orderNumber: ORD-888<br>status: ready<br>waitTimeRating: 3<br>staffAttentionRating: 4 | - Sistema acepta estado "ready"<br>- Encuesta creada exitosamente<br>- HTTP 201<br>- Mensaje: "¡Gracias por tu opinión!" |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-013-N01 | Sistema previene encuestas duplicadas | 1. Pedido ORD-999 ya tiene encuesta<br>2. Cliente intenta enviar otra encuesta para mismo pedido<br>3. POST a /api/surveys | orderNumber: ORD-999<br>(ya tiene encuesta) | - Sistema detecta duplicado<br>- HTTP 409<br>- Body: {"error": "Ya enviaste tu opinión"} |
| TC-013-N02 | Encuesta con ratings fuera de rango rechazada | 1. Cliente completa encuesta con rating inválido<br>2. POST a /api/surveys<br>3. Verificar rechazo | orderNumber: ORD-111<br>waitTimeRating: 0<br>staffAttentionRating: 6 | - Sistema valida rango 1-5<br>- HTTP 400<br>- Body: {"error": "Ratings deben estar entre 1 y 5"} |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-013-B01 | Encuesta con ratings en límite inferior válido | 1. Cliente envía todos ratings = 1<br>2. POST a /api/surveys | orderNumber: ORD-222<br>waitTimeRating: 1<br>staffAttentionRating: 1 | - Sistema acepta rating 1<br>- Encuesta creada<br>- HTTP 201 |
| TC-013-B02 | Encuesta con ratings en límite superior válido | 1. Cliente envía todos ratings = 5<br>2. POST a /api/surveys | orderNumber: ORD-333<br>waitTimeRating: 5<br>staffAttentionRating: 5 | - Sistema acepta rating 5<br>- Encuesta creada<br>- HTTP 201 |

---

## HU-014: Sistema de Reseñas Públicas (Reviews)

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-014-P01 | Cliente crea reseña sin orderNumber | 1. Cliente accede a /reviews/new<br>2. Completa campos requeridos<br>3. POST sin orderNumber<br>4. Verificar creación | foodRating: 5<br>tasteRating: 4<br>comment: "Delicioso"<br>orderNumber: (omitido) | - Reseña creada con orderNumber = "N/A"<br>- status = "pending"<br>- Sin metadata de pedido<br>- HTTP 201 |
| TC-014-P02 | Reseña con orderNumber válido se enriquece | 1. Cliente proporciona orderNumber existente<br>2. POST a /reviews/new<br>3. Sistema busca pedido<br>4. Verificar metadata | orderNumber: ORD-777<br>foodRating: 5<br>tasteRating: 5<br>(pedido existe en BD) | - Sistema encuentra pedido<br>- Agrega metadata: items, total, orderDate<br>- Reseña creada enriquecida<br>- HTTP 201 |
| TC-014-P03 | Cliente puede dejar múltiples reseñas | 1. Cliente ya tiene reseña previa<br>2. Crea nueva reseña<br>3. POST a /reviews/new | Cliente con reseña existente<br>Nueva reseña diferente | - Sistema NO valida duplicados<br>- Segunda reseña aceptada<br>- Ambas reseñas existen<br>- HTTP 201 |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-014-N01 | Rechazar reseña sin campos requeridos | 1. Cliente omite foodRating<br>2. POST a /reviews/new<br>3. Verificar validación | tasteRating: 4<br>foodRating: (omitido) | - Sistema detecta campo faltante<br>- HTTP 400<br>- Body: {"error": "foodRating y tasteRating son requeridos"} |
| TC-014-N02 | Rechazar reseña con ratings inválidos | 1. Cliente envía ratings fuera de rango<br>2. POST a /reviews/new | foodRating: 6<br>tasteRating: 0 | - Sistema valida rango 1-5<br>- HTTP 400<br>- Body: {"error": "Ratings deben estar entre 1 y 5"} |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-014-B01 | Reseña con orderNumber inválido se acepta | 1. Cliente proporciona orderNumber que NO existe<br>2. POST a /reviews/new<br>3. Sistema no encuentra pedido<br>4. Verificar creación | orderNumber: ORD-NOEXISTE<br>foodRating: 4<br>tasteRating: 3 | - Sistema no encuentra pedido<br>- Reseña creada SIN metadata<br>- orderNumber conservado<br>- NO rechaza solicitud<br>- HTTP 201 |
| TC-014-B02 | Reseña solo con campos requeridos | 1. Cliente envía solo foodRating y tasteRating<br>2. Sin comment ni orderNumber<br>3. POST a /reviews/new | foodRating: 3<br>tasteRating: 4 | - Reseña creada con mínimos campos<br>- orderNumber = "N/A"<br>- comment = null/vacío<br>- HTTP 201 |

---

## HU-015: Estandarizar Nomenclatura de Estados de Pedido Entre Servicios

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-015-P01 | Definir estados oficiales del sistema | 1. Documentar estados oficiales<br>2. Crear ORDER_STATES.md<br>3. Definir transiciones | N/A | - Archivo ORDER_STATES.md creado<br>- Estados: [pending, received, preparing, ready, completed, cancelled]<br>- Significado de cada estado definido<br>- Transiciones permitidas especificadas |
| TC-015-P02 | Crear constantes centralizadas | 1. Crear constants/orderStates.ts<br>2. Definir export const ORDER_STATES<br>3. Actualizar referencias | N/A | - Archivo creado<br>- Constantes definidas<br>- Referencias usan constantes |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-015-N01 | Detectar nombres ambiguos sin mapeo | 1. Buscar términos como "in_progress"<br>2. Verificar mapeo | Término: "in_progress" | - Término identificado<br>- No está en mapeo oficial<br>- Requiere eliminación o mapeo claro |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-015-B01 | Mapear estados entre servicios | 1. Documentar equivalencias UI ↔ Order ↔ Kitchen<br>2. Verificar eventos RabbitMQ | N/A | - Tabla de mapeo clara:<br>  UI: "Recibido" = Order: "received" = Kitchen: "received" = Event: "order.received"<br>- Documentación completa |
| TC-015-B02 | Verificar consistencia en eventos RabbitMQ | 1. Cambiar pedido de received a preparing<br>2. Verificar evento publicado | oldStatus: received<br>newStatus: preparing | - Evento: "order.status.updated"<br>- Payload: {orderId, oldStatus: "received", newStatus: "preparing"}<br>- Nombres consistentes |

---

## HU-016: Completar Traducciones i18n para Generación de Orden

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-016-P01 | Auditar textos sin traducir | 1. Revisar módulo creación pedidos<br>2. Buscar strings hardcodeados<br>3. Crear lista de keys faltantes | N/A | - Lista de textos sin i18next<br>- Keys sugeridas identificadas<br>- Ej: "Selecciona productos" → order.selectProducts |
| TC-016-P02 | Agregar traducciones en inglés | 1. Actualizar locales/en/translation.json<br>2. Agregar sección "order"<br>3. Incluir todas las keys | Keys: selectProducts, addToOrder, confirmOrder, deliveryAddress | - Archivo actualizado<br>- Traducciones naturales en inglés<br>- JSON válido |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-016-N01 | Detectar textos sin traducir después de implementación | 1. Cambiar idioma a inglés<br>2. Buscar textos en español | Idioma: inglés | - Todos textos en inglés<br>- Sin textos en español remanentes |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-016-B01 | Verificar cambio de idioma en tiempo real | 1. Estar en generación de pedidos<br>2. Sistema en español<br>3. Cambiar a inglés<br>4. Verificar actualización | Idioma inicial: español<br>Cambio a: inglés | - Textos cambian inmediatamente a inglés<br>- Sin textos en español<br>- Preferencia persiste al recargar |
| TC-016-B02 | Agregar traducciones en español | 1. Actualizar locales/es/translation.json<br>2. Incluir mismas keys | N/A | - Versiones en español incluidas<br>- Consistencia con tono del sistema |

---

## HU-017: Completar Traducciones i18n para Nombres de Roles

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-017-P01 | Agregar traducciones de roles en inglés | 1. Editar locales/en/translation.json<br>2. Crear sección "roles"<br>3. Agregar keys para admin, kitchen, editor | Roles: admin, kitchen, editor | - Sección roles creada<br>- Traducciones: admin→Administrator, kitchen→Kitchen Staff, editor→Editor |
| TC-017-P02 | Agregar traducciones de roles en español | 1. Editar locales/es/translation.json<br>2. Crear sección "roles"<br>3. Agregar keys | Roles: admin, kitchen, editor | - Traducciones: admin→Administrador, kitchen→Personal de Cocina, editor→Editor |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-017-N01 | Verificar roles sin traducir | 1. No implementar traducciones<br>2. Cambiar idioma<br>3. Ver gestión usuarios | Idioma: inglés<br>Sin traducciones | - Roles se muestran en valor BD (admin, kitchen) sin traducir |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-017-B01 | Aplicar traducciones en interfaz gestión usuarios | 1. Login como admin<br>2. Ir a gestión usuarios<br>3. Ver columna "Rol"<br>4. Cambiar idioma | Valores BD: admin, kitchen, editor | - Roles traducidos según idioma<br>- Cambio de idioma actualiza inmediatamente<br>- admin: Administrador/Administrator |

---

## HU-018: Centralizar URLs de Backend en Variables de Entorno

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-018-P01 | Identificar URLs hardcodeadas | 1. Buscar en código: "http://" o "https://"<br>2. Crear lista de URLs | Pattern: http://localhost:3000/api | - Lista URLs hardcodeadas<br>- Variables sugeridas: VITE_API_GATEWAY_URL, VITE_SSE_NOTIFICATIONS_URL |
| TC-018-P02 | Crear archivo .env.example | 1. Crear .env.example en frontend<br>2. Agregar variables con valores ejemplo | Variables: VITE_API_GATEWAY_URL, VITE_SSE_NOTIFICATIONS_URL | - Archivo creado<br>- Todas variables incluidas<br>- Valores de ejemplo presentes |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-018-N01 | Error de compilación sin variable de entorno | 1. No definir variable en .env<br>2. Intentar compilar<br>3. Código usa import.meta.env.VITE_API_GATEWAY_URL | Variable no definida | - Error o warning de compilación<br>- Variable undefined |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-018-B01 | Verificar funcionamiento en diferentes entornos | 1. Configurar .env.development<br>2. Ejecutar en dev<br>3. Configurar .env.production<br>4. Compilar para prod | Dev: http://localhost:3000<br>Prod: https://api.production.com | - App conecta a URLs de desarrollo en dev<br>- Bundle incluye URLs de producción en prod<br>- Funciona correctamente en ambos |
| TC-018-B02 | Reemplazar URLs hardcodeadas con variables | 1. Actualizar código para usar import.meta.env<br>2. Compilar | N/A | - URLs leídas desde variables de entorno<br>- Sin URLs hardcodeadas en código<br>- Compilación exitosa |

---

---

## HU-019: Validar y Corregir Datos en Reportes de Analytics

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-022-P01 | Auditoría identifica inconsistencias | 1. Ejecutar script de auditoría de analytics<br>2. Comparar reportes con BD | Script: auditAnalyticsQueries.js | - Reporte generado<br>- Inconsistencias identificadas<br>- Pedidos cancelados incorrectamente incluidos detectados<br>- Sugerencias de corrección |
| TC-022-P02 | Total de órdenes coincide con BD | 1. Ver reporte "Total de Órdenes: 150"<br>2. Ejecutar query MongoDB con mismo filtro<br>3. Comparar resultados | Filtro: Último mes<br>Estados: completed, delivered | - Conteo reporte: 150<br>- Conteo BD: 150<br>- Coinciden exactamente<br>- Pedidos cancelados excluidos |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-022-N01 | Detectar inclusión incorrecta de cancelados | 1. Ver "Total de Órdenes Completadas: 200"<br>2. Query BD incluye status=cancelled<br>3. Comparar | Query incorrecta incluye: cancelled | - Auditoría detecta discrepancia<br>- Identifica que cancelados están siendo contados<br>- Alerta generada |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-022-B01 | Validación automática de consistencia | 1. Sistema genera reportes automáticos<br>2. Validación ejecuta cada métrica<br>3. Detecta discrepancia >1% | Reporte: 100 órdenes<br>BD real: 95 órdenes<br>Discrepancia: 5% | - Alerta enviada a administrador<br>- Registrado en logs<br>- Email notificación con detalles |
| TC-022-B02 | Exportación CSV datos exactos | 1. Ver reporte con 100 pedidos<br>2. Exportar a CSV<br>3. Contar filas en CSV<br>4. Validar cada fila con BD | Reporte: 100 pedidos completados | - CSV contiene 100 filas + encabezados<br>- Cada fila corresponde a pedido en BD<br>- Valores (fecha, monto, estado) coinciden exactamente |

---

## HU-020: Optimizar Experiencia de Usuario en Dashboard de Analytics

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-023-P01 | Filtros se aplican automáticamente sin botón | 1. Acceder a dashboard analytics<br>2. Cambiar "Desde" de "1 dic" a "15 nov"<br>3. Observar actualización | Fecha desde: 15 nov<br>Fecha hasta: 17 dic | - Dashboard actualiza automáticamente<br>- Sin botón "Ver métricas"<br>- Datos actualizados en <2 segundos<br>- useEffect detecta cambio en filtros |
| TC-023-P02 | Rango de fechas permite 10 años históricos | 1. Hacer clic en input "Desde"<br>2. Intentar seleccionar enero 2015<br>3. Verificar habilitación | Fecha: 01/01/2015 | - Fecha 2015 seleccionable<br>- Input tiene min={hoy - 10 años}<br>- Sistema permite consulta histórica |
| TC-023-P03 | Gráficos muestran rango real de fechas | 1. Seleccionar rango "15 nov - 20 dic"<br>2. Verificar subtítulos de LineChart y BarChart | from: 15 nov<br>to: 20 dic | - Subtítulo muestra: "15 nov - 20 dic"<br>- NO muestra "Últimos 30 días"<br>- Función getDateRangeLabel() retorna rango exacto |
| TC-023-P04 | Tabla muestra solo períodos sin productos | 1. Agrupar por "semana"<br>2. Verificar estructura de tabla | groupBy: week<br>3 semanas con datos | - Columnas: Período, Órdenes Completadas, Órdenes Canceladas, Ingresos Totales, Ingresos Perdidos<br>- 3 filas (una por semana)<br>- Sin columnas productId, productName, quantity<br>- Sin repeticiones |
| TC-023-P05 | CSV exporta estructura de tabla actual | 1. Visualizar tabla con 5 períodos<br>2. Clic "Exportar CSV"<br>3. Abrir archivo | 5 períodos visibles | - CSV tiene 5 filas + encabezado<br>- Columnas: period;totalOrders;totalCancelled;totalRevenue;lostRevenue<br>- Sin columnas de productos<br>- Valores coinciden con tabla |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-023-N01 | Bloquear fechas futuras | 1. Clic en input "Desde"<br>2. Intentar seleccionar fecha futura | Fecha: 25/12/2025 (futura) | - Fecha futura deshabilitada<br>- Input tiene max={hoy}<br>- Calendario no permite selección futura |
| TC-023-N02 | Rechazar rango mayor a 10 años | 1. Seleccionar "Desde" 01/01/2010<br>2. Seleccionar "Hasta" 17/12/2025<br>3. Intentar consultar | Rango: 15 años | - Backend rechaza query<br>- HTTP 400<br>- Error: "El rango de fechas excede el máximo permitido (10 años)" |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-023-B01 | Subtítulo respeta idioma seleccionado | 1. Sistema en español<br>2. Seleccionar rango "1 dic - 15 dic"<br>3. Verificar subtítulo<br>4. Cambiar a inglés<br>5. Verificar actualización | Rango: 1 dic - 15 dic<br>Idiomas: es, en | - Español: "1 dic - 15 dic"<br>- Inglés: "Dec 1 - Dec 15"<br>- Función usa i18n.language para locale |
| TC-023-B02 | Mismo día muestra formato corto | 1. Seleccionar "Desde" y "Hasta" con misma fecha<br>2. Verificar subtítulo | from: 17/12/2025<br>to: 17/12/2025 | - Subtítulo muestra: "17 dic"<br>- No muestra "17 dic - 17 dic"<br>- Lógica: if (from === to) |
| TC-023-B03 | Gráfico de líneas con valores bajos visible | 1. Crear órdenes: 2, 3, 2, 5 por período<br>2. Visualizar LineChart<br>3. Verificar línea verde | Valores: [2, 3, 2, 5] | - Línea verde visible y separada del eje X<br>- No pegada al borde inferior<br>- Margen 10% aplicado en normalización<br>- Padding 20px en cálculo de puntos SVG |
| TC-023-B04 | Métricas canceladas destacadas visualmente | 1. Período con 3 cancelaciones y $72.000 perdidos<br>2. Verificar tabla | totalCancelled: 3<br>lostRevenue: 72000 | - Valor "3" en color ámbar (text-amber-600)<br>- Valor "$72.000" en color rojo (text-red-600)<br>- Font-weight: medium aplicado<br>- Períodos con 0 en color normal |
| TC-023-B05 | Tabla sin productos individuales | 1. Verificar getTableData()<br>2. Confirmar estructura retornada | N/A | - Retorna array de períodos<br>- NO hace producto cartesiano con productsSold<br>- Cada período aparece 1 sola vez<br>- Productos solo en BarChart |

---

## HU-021: Implementar Notificaciones por Email para Clientes Offline

### Casos Positivos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-024-P01 | Email enviado cuando pedido entra en preparación | 1. Crear pedido con email: cliente@test.com, items: [Pizza x2]<br>2. Kitchen Service cambia estado a preparing<br>3. Verificar RabbitMQ recibe evento<br>4. Verificar email enviado | orderNumber: ORD-12345<br>customerEmail: cliente@test.com<br>customerName: Juan Pérez<br>items: [{name: "Pizza", quantity: 2}]<br>status: preparing | - Evento "order.preparing" publicado en RabbitMQ<br>- Email recibido con asunto: "Tu pedido está en preparación"<br>- Cuerpo contiene: "tu pedido ya está en preparación"<br>- Lista de items: "Pizza x 2"<br>- URL: {FRONTEND_URL}/orders/ORD-12345<br>- Plantilla HTML con branding naranja (#ff7e33) |
| TC-024-P02 | Email enviado cuando pedido está listo | 1. Crear pedido en estado preparing<br>2. Kitchen Service cambia a ready<br>3. Verificar email recibido | orderNumber: ORD-67890<br>customerEmail: maria@test.com<br>items: [{name: "Hamburguesa", quantity: 1}, {name: "Papas", quantity: 1}] | - Evento "order.ready" publicado<br>- Email con asunto: "¡Tu pedido está listo!"<br>- Mensaje: "Tu pedido ya está listo para recoger"<br>- Lista completa de items<br>- Botón "Deja tu reseña" con enlace<br>- URL de seguimiento incluida |
| TC-024-P03 | Versión plain text como fallback | 1. Enviar email de notificación<br>2. Inspeccionar MIME parts<br>3. Verificar existencia de text/plain | N/A | - Email multipart/alternative<br>- text/html con plantilla completa<br>- text/plain con contenido equivalente sin HTML<br>- Ambas versiones legibles |
| TC-024-P04 | URL configurable mediante variable de entorno | 1. Configurar FRONTEND_URL=https://delicious.com<br>2. Reiniciar notification-service<br>3. Enviar pedido a preparing<br>4. Verificar email | FRONTEND_URL=https://delicious.com<br>orderNumber: ORD-111 | - URL en email: https://delicious.com/orders/ORD-111<br>- NO usa localhost<br>- process.env.FRONTEND_URL leída correctamente |

### Casos Negativos

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-024-N01 | Email no enviado si falta customerEmail | 1. Crear pedido sin email<br>2. Cambiar a preparing<br>3. Verificar logs | orderNumber: ORD-999<br>customerEmail: null<br>items: [Pizza x1] | - Email NO enviado<br>- Log: "⚠️ Orden ORD-999 en preparación pero faltan datos para email"<br>- Log: "customerEmail: false"<br>- Sistema continúa sin error fatal |
| TC-024-N02 | Email no enviado si falta items | 1. Crear pedido con email válido<br>2. Evento sin array items<br>3. Verificar comportamiento | orderNumber: ORD-888<br>customerEmail: test@mail.com<br>items: undefined | - Email NO enviado<br>- Log: "items: false"<br>- Consumidor detecta datos faltantes<br>- Sin crash del servicio |
| TC-024-N03 | Evento no publicado si pedido no cambia de estado | 1. Crear pedido en preparing<br>2. Intentar cambiar a preparing nuevamente<br>3. Verificar RabbitMQ | Estado actual: preparing<br>Estado solicitado: preparing | - Sin evento publicado<br>- Operación de cambio de estado rechazada<br>- Sin emails duplicados |

### Casos Borde

| ID | Descripción | Pasos | Datos de Entrada | Resultado Esperado |
|----|-------------|-------|------------------|-------------------|
| TC-024-B01 | Fallback a localhost si FRONTEND_URL no configurada | 1. Eliminar variable FRONTEND_URL del .env<br>2. Reiniciar notification-service<br>3. Enviar email | FRONTEND_URL: undefined<br>orderNumber: ORD-222 | - URL en email: http://localhost:5173/orders/ORD-222<br>- Valor por defecto aplicado<br>- Sistema funciona sin errores |
| TC-024-B02 | Plantilla responsive en móvil y desktop | 1. Enviar email de prueba<br>2. Abrir en Gmail mobile<br>3. Abrir en Outlook desktop<br>4. Verificar renderizado | N/A | - Móvil: Diseño adaptado, textos legibles, botones táctiles<br>- Desktop: Layout centrado, imágenes cargadas<br>- Sin elementos desbordados<br>- Meta viewport correcto |
| TC-024-B03 | Items extraídos correctamente de estructura anidada | 1. Kitchen Service envía evento con estructura: {data: {items: [...]}}<br>2. Consumer extrae items<br>3. Verificar email | Estructura evento:<br>{orderNumber: "X", data: {items: [Pizza x1]}} | - Items extraídos correctamente<br>- Código: `event.data.data?.items \|\| event.data.items`<br>- Email muestra lista de items<br>- Soporta ambas estructuras (anidada y plana) |
| TC-024-B04 | Manejo de caracteres especiales en nombres | 1. Crear pedido con item: "Café Frappé"<br>2. Enviar email<br>3. Verificar encoding | items: [{name: "Café Frappé", quantity: 1}] | - Caracteres especiales (é) renderizados correctamente<br>- Encoding UTF-8 en email<br>- Sin caracteres corruptos o "?" |
| TC-024-B05 | Email enviado incluso si falla conexión RabbitMQ momentánea | 1. Simular desconexión RabbitMQ<br>2. Kitchen Service cambia estado a ready<br>3. RabbitMQ se recupera<br>4. Verificar comportamiento | Estado: ready<br>RabbitMQ down → up | - Evento encolado para retry<br>- Email enviado cuando RabbitMQ se recupera<br>- Sistema resiliente ante fallos temporales<br>- No se pierden notificaciones |
| TC-024-B06 | Colores corporativos aplicados correctamente | 1. Enviar email de preparing o ready<br>2. Inspeccionar HTML del email<br>3. Verificar estilos | N/A | - Gradiente naranja: linear-gradient(135deg, #ff7e33 0%, #ff5722 100%)<br>- Botones con color #ff7e33<br>- NO usa colores morados antiguos (#667eea)<br>- Branding consistente con frontend |

