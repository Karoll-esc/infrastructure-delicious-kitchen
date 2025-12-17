# Reporte de Hallazgos "As Is"
## Dimensionamiento y Gestión de Ambigüedades - Proyecto Delicious Kitchen

---

## 1. Ambigüedades Funcionales Identificadas

### 1.1 🔴 Sistema de Autenticación Dual No Integrado

**Ambigüedad:** Existen dos sistemas de autenticación que no están conectados entre sí.

| Componente | Sistema | Estado |
|------------|---------|--------|
| Frontend AuthContext | Simulado (estado local) | ❌ No funcional |
| Firebase Auth | Configurado pero no integrado | ⚠️ Parcial |
| Backend API Gateway | Valida tokens Firebase | ✅ Funcional |

**Preguntas sin resolver:**
- ¿El frontend REALMENTE valida tokens con Firebase o solo simula el login?
- ¿Qué pasa si el token expira en el frontend pero el backend lo rechaza?
- ¿Los custom claims de Firebase (roles) se están leyendo correctamente?

**Impacto:** Un usuario podría "parecer" logueado en el frontend pero ser rechazado por el backend, o viceversa.

---

### 1.2 🔴 Flujo de Cancelación de Pedidos Incompleto

**Ambigüedad:** La regla dice "cancelar solo antes de preparación", pero hay inconsistencias.

**Lo que dice la regla de negocio:**
> "El pedido puede cancelarse SOLO si no ha iniciado la preparación"

**Lo que encontramos en el código/transferencia:**
- El botón de cancelar existe en el frontend
- Se mencionó que "debe" desaparecer cuando inicia preparación
- No está claro si esta validación ocurre en frontend, backend, o ambos

**Preguntas sin resolver:**
- ¿Qué estados exactos permiten cancelación? (`pending` solamente, o también `received`?)
- ¿La validación está en el frontend (UI) o en el backend (API)?
- ¿Qué pasa si hay race condition? (usuario cancela mientras cocina inicia preparación)
- ¿Se notifica a cocina cuando un pedido es cancelado?

**Impacto:** Posible cancelación de pedidos ya en preparación, pérdida de recursos.

---

### 1.3 🟡 Sistema de Reseñas: Momento de Creación

**Ambigüedad:** ¿Cuándo exactamente puede el cliente dejar una reseña?

**Lo que dice la transferencia:**
> "Se puede agregar una reseña cuando ya el pedido esté listo"

**Contradicción identificada:**
- Gerardo mencionó: "más que todo es por tiempo de recogida... a no ser que la persona coma y después lo haga"
- ¿El cliente puede dejar reseña días después? ¿Hay límite de tiempo?
- ¿Qué pasa si el cliente nunca recoge el pedido pero está "listo"?

**Preguntas sin resolver:**
- ¿Existe ventana de tiempo para dejar reseña?
- ¿Se puede dejar múltiples reseñas por pedido?
- ¿Qué pasa con reseñas de pedidos cancelados?

---

### 1.4 🟡 Gestión de Usuarios: "Eliminar" vs "Desactivar"

**Ambigüedad:** La UI muestra icono de "papelera" pero no elimina.

**Lo que dice la transferencia:**
> "El caso de eliminar no lo elimina completamente... los deja ahí como inactivos"

**Confusión UX:**
- El icono de papelera sugiere eliminación permanente
- La acción real es desactivación
- El tooltip dice "desactivar usuario" (correcto) pero el icono es engañoso

**Preguntas sin resolver:**
- ¿Existe forma de eliminar permanentemente un usuario?
- ¿Qué pasa con los pedidos/reseñas asociados a un usuario desactivado?
- ¿Un usuario desactivado puede ser reactivado?

---

### 1.5 🟡 Estados de Pedido en Cocina vs Order Service

**Ambigüedad:** Posible inconsistencia en nomenclatura de estados.

**Estados mencionados en diferentes contextos:**

| Fuente | Estados |
|--------|---------|
| UI Cocina | Received, Preparing, Ready |
| Kitchen Service | pending, in_progress, completed |
| Order Service | pending, in_progress, completed, cancelled |
| Transferencia | "recibidos", "en preparación", "listos" |

**Preguntas sin resolver:**
- ¿"Received" = "pending"? ¿O son estados diferentes?
- ¿Hay mapeo explícito entre estados de Kitchen y Order?
- ¿El evento `kitchen.order.status.updated` usa qué nomenclatura?

---

## 2. Reglas de Negocio Contradictorias

### 2.1 🔴 Autenticación: ¿Requerida o No?

**Contradicción:**

| Contexto | Regla |
|----------|-------|
| Cliente (pedidos) | NO requiere registro/login |
| Admin/Kitchen | SÍ requiere login con Firebase |
| Reseñas | ¿? Cliente sin cuenta puede dejar reseña |

**El problema:**
- Un cliente anónimo puede hacer pedido y dejar reseña
- ¿Cómo se vincula la reseña con el pedido si no hay usuario?
- ¿Cómo se previene spam de reseñas falsas?

**Posible inconsistencia:** El sistema permite reseñas anónimas que podrían ser abusadas.

---

### 2.2 🟡 Token de Sesión: Tiempo Contradictorio

**Lo que mencionó Andrés:**
> "El tiempo del token es muy corto, son 3.6 segundos"

**Contradicción técnica:**
- Firebase Auth tokens típicamente duran 1 hora
- 3.6 segundos es extremadamente corto (¿error de configuración?)
- ¿Es el token de Firebase o un token custom?

**Impacto:** Si realmente son 3.6 segundos, el sistema sería prácticamente inutilizable.

---

### 2.3 🟡 Notificaciones: ¿SSE o Eventos RabbitMQ?

**Contradicción arquitectónica:**

| Documento | Mecanismo |
|-----------|-----------|
| BUSINESS_CONTEXT | RabbitMQ → Notification Service → Cliente |
| Frontend Audit | SSE (Server-Sent Events) con useNotifications hook |
| Transferencia | "llega la notificación a la persona" (no especifica cómo) |

**Preguntas sin resolver:**
- ¿El Notification Service envía emails/SMS O mantiene conexión SSE?
- ¿Hay dos sistemas de notificación paralelos?
- ¿Qué pasa si el cliente cierra el navegador? ¿Se pierde la notificación?

---

## 3. Deuda Técnica Oculta

### 3.1 🔴 Firebase Admin en Frontend (CRÍTICO)

**Hallazgo:** El paquete `firebase-admin` está en las dependencias del frontend.

**Por qué es grave:**
- `firebase-admin` es una librería de SERVIDOR
- Contiene credenciales de administrador
- Aumenta el bundle en ~1.5MB
- **RIESGO DE SEGURIDAD:** Expone capacidades administrativas en el cliente

**Origen probable:** El archivo `setAdminClaim.cjs` mencionado en la transferencia.

**Acción requerida:** Mover a un script de backend separado.

---

### 3.2 🔴 Doble Fuente de Verdad para Usuarios

**Hallazgo:** Los usuarios existen en DOS lugares:

1. **Firebase Auth** - Autenticación (email, password, disabled)
2. **Firebase Firestore** - Datos adicionales (nombre, rol)

**Riesgo de inconsistencia:**
- ¿Qué pasa si un usuario existe en Auth pero no en Firestore?
- ¿La desactivación sincroniza ambos?
- ¿Los roles se leen de Firestore o de custom claims de Auth?

---

### 3.3 🔴 Nombres de Base de Datos Inconsistentes

**Hallazgo de la transferencia:**
> "La base de datos tenía dos nombres diferentes, una estaba con mayúscula y la otra con minúscula"

**Ejemplos mencionados:**
- `Batabase` vs `batabase` vs `DATABASE`

**Riesgo:** Podría causar errores silenciosos donde el código conecta a una colección vacía.

**Estado:** "Lo arreglamos" pero "habría que hacerle una verificación".

---

### 3.4 🟡 Código Duplicado en Servicios de Analytics

**Hallazgo:** Existen DOS archivos que hacen lo mismo:
- `api.js` → tiene funciones de analytics
- `analyticsService.js` → wrapper que llama a `api.js`

**Impacto:**
- Mantenimiento doble
- Confusión sobre cuál usar
- Posibles inconsistencias si se actualiza uno y no el otro

---

### 3.5 🟡 URLs Hardcodeadas

**Hallazgo de la transferencia:**
> "Aquí tenemos la URL quemada del backend"

**Ubicaciones identificadas:**
- Frontend: URL del API Gateway
- Frontend: URL de notificaciones SSE

**Riesgo:** Dificulta deployment a diferentes ambientes (dev, staging, prod).

---

### 3.6 🟡 Productos del Menú Hardcodeados

**Hallazgo crítico de negocio:**
> "No hay manera de crear nuevos menús, nuevos productos... Estos productos están quemados"

**Impacto:**
- El restaurante NO puede agregar/modificar productos sin cambiar código
- Precios fijos en el código
- Imágenes fijas

**¿Por qué no se detectó antes?** Probablemente porque el foco estuvo en pedidos y cocina, no en administración de catálogo.

---

### 3.7 🟡 Funcionalidad "Recuperar Contraseña" Fantasma

**Hallazgo:**
> "Este de recuperar contraseña no está funcionando... se agregó ahí pero no estaba en el alcance"

**Riesgo UX:** El botón existe, el usuario espera funcionalidad, pero no hace nada.

---

### 3.8 🟢 i18n Incompleto

**Hallazgo:**
> "Hay unas partecitas que hacen falta... la generación de una orden y el de los roles"

**Secciones sin traducir:**
- Generación de orden
- Nombres de roles
- Posiblemente mensajes de error

---

### 3.9 🟢 Tests Unitarios Incompletos

**Hallazgo de la transferencia:**
> "El de orden no me acuerdo si tiene test unitarios realmente"

**Estado de tests:**
- API Gateway: ✅
- Kitchen Service: ✅
- Notification Service: ✅
- Order Service: ❓ (no confirmado)
- Frontend: "hace falta muy pocos"

---

## 4. Matriz de Riesgo y Priorización

| ID | Hallazgo | Tipo | Severidad | Esfuerzo | Prioridad |
|----|----------|------|-----------|----------|-----------|
| 3.1 | firebase-admin en frontend | Seguridad | 🔴 Crítica | Bajo | **P0** |
| 1.1 | Auth dual no integrado | Ambigüedad | 🔴 Alta | Alto | **P1** |
| 1.2 | Cancelación incompleta | Ambigüedad | 🔴 Alta | Medio | **P1** |
| 3.2 | Doble fuente usuarios | Deuda | 🔴 Alta | Alto | **P1** |
| 3.3 | Nombres BD inconsistentes | Deuda | 🔴 Alta | Bajo | **P1** |
| 2.2 | Token 3.6 segundos | Contradicción | 🟡 Media | Bajo | **P2** |
| 3.6 | Productos hardcodeados | Deuda | 🟡 Media | Alto | **P2** |
| 1.3 | Momento de reseñas | Ambigüedad | 🟡 Media | Medio | **P2** |
| 2.3 | SSE vs RabbitMQ | Contradicción | 🟡 Media | Medio | **P2** |
| 3.4 | Código duplicado | Deuda | 🟢 Baja | Bajo | **P3** |
| 3.7 | Recuperar contraseña | Deuda | 🟢 Baja | Medio | **P3** |
| 3.8 | i18n incompleto | Deuda | 🟢 Baja | Bajo | **P3** |

---

## 5. Preguntas para Validar con el Negocio

Antes de refactorizar, se recomienda aclarar:

1. **Cancelación:** ¿En qué estados exactos se permite cancelar? ¿Qué mensaje ve el cliente si intenta cancelar tarde?

2. **Reseñas:** ¿Hay límite de tiempo para dejar reseña? ¿Se pueden editar? ¿Una reseña por pedido o múltiples?

3. **Usuarios:** ¿Se necesita eliminar usuarios permanentemente alguna vez? ¿O siempre desactivar?

4. **Notificaciones:** ¿Qué pasa si el cliente no tiene el navegador abierto? ¿Se envía email/SMS como backup?

5. **Productos:** ¿Es requerido un CRUD de productos para esta fase o se mantienen hardcodeados?

6. **Token:** Confirmar el tiempo real de expiración del token y si 3.6s fue un error de comunicación.

---

## 6. Recomendaciones Inmediatas

### Para Sprint 1 (Críticos):

```bash
# 1. Remover firebase-admin del frontend
cd frontend
npm uninstall firebase-admin

# 2. Verificar nombres de BD
grep -r "atabase" --include="*.ts" --include="*.js" .

# 3. Verificar tiempo de token
# Revisar configuración de Firebase Auth
```

### Para Sprint 2 (Importantes):

1. Integrar AuthContext con Firebase Auth real
2. Implementar validación de cancelación en backend (no solo frontend)
3. Definir y documentar estados de pedido oficiales
4. Consolidar servicios de analytics duplicados

