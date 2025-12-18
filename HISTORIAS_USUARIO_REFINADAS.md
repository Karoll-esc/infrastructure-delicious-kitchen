# Historias de Usuario Refinadas — Delicious Kitchen
## Refinamiento y Perfeccionamiento del Sistema

---

# [HU-001] — Eliminar Dependencia de Seguridad firebase-admin del Frontend

## Descripción

* **Como:** Ingeniero de seguridad del sistema
* **Quiero:** Remover completamente la dependencia `firebase-admin` del código del frontend
* **Para:** Eliminar el riesgo crítico de seguridad que representa exponer credenciales administrativas en el cliente y reducir el tamaño del bundle en aproximadamente 1.5MB

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Paquete firebase-admin eliminado del frontend
    Given el frontend tiene instalado el paquete firebase-admin
    When se elimina la dependencia del proyecto frontend
    Then el paquete firebase-admin no debe estar presente en las dependencias del frontend
    And el tamaño del bundle debe reducirse en aproximadamente 1.5MB

Scenario: No existen referencias a firebase-admin en el código frontend
    Given el paquete firebase-admin ha sido eliminado
    When se verifica el código fuente del frontend
    Then no debe existir ninguna importación de firebase-admin
    And no debe existir ninguna llamada a funcionalidades de firebase-admin
    And la aplicación debe compilar exitosamente

Scenario: Aplicación frontend funciona correctamente sin firebase-admin
    Given firebase-admin ha sido removido del frontend
    When se ejecuta la aplicación en modo desarrollo
    Then la aplicación debe funcionar sin errores
    When se compila la aplicación para producción
    Then el build debe completarse exitosamente
    And la aplicación debe operar normalmente en producción
```

---

# [HU-002] — Migrar Script setAdminClaim al Backend

## Descripción

* **Como:** Desarrollador del sistema
* **Quiero:** Mover el script administrativo `setAdminClaim.cjs` (que requiere firebase-admin) desde el frontend hacia un servicio de backend seguro
* **Para:** Garantizar que las operaciones administrativas de Firebase se ejecuten exclusivamente en el servidor, manteniendo la seguridad y cumpliendo con las mejores prácticas de arquitectura

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Script administrativo reubicado en el backend
    Given el script setAdminClaim existe en el frontend
    When se migra al entorno de backend
    Then el script debe residir en el servidor
    And el script no debe estar accesible desde el frontend
    And la funcionalidad del script debe mantenerse intacta

Scenario: Documentación actualizada para uso desde backend
    Given el script ha sido migrado al backend
    When se consulta la documentación de operaciones administrativas
    Then debe existir documentación clara sobre cómo ejecutar el script desde el servidor
    And debe especificar los parámetros requeridos para su ejecución
    And debe incluir ejemplos de uso para asignación de roles

Scenario: Ejecución exitosa del script desde el servidor
    Given el script está configurado en el backend
    When se ejecuta el script con parámetros válidos desde el servidor
    Then el custom claim debe asignarse correctamente en Firebase Auth
    And el usuario debe tener el rol actualizado
    And debe confirmarse la operación exitosa
```

---

# [HU-003] — Integrar AuthContext del Frontend con Firebase Authentication SDK

## Descripción

* **Como:** Usuario administrador o personal de cocina
* **Quiero:** Que el sistema de autenticación del frontend utilice el SDK real de Firebase Authentication en lugar de un estado local simulado
* **Para:** Tener una sesión segura, confiable y sincronizada entre el frontend y el backend, evitando estados ambiguos donde parezco autenticado en el cliente pero soy rechazado por el servidor

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Autenticación exitosa con credenciales válidas
    Given soy un usuario con credenciales válidas y cuenta activa
    When ingreso mi email y contraseña en la página de login
    And envío el formulario de autenticación
    Then debo ser autenticado mediante Firebase Authentication
    And mi sesión debe quedar almacenada de forma segura
    And debo ser redirigido al dashboard correspondiente a mi rol
    And mi sesión debe persistir al recargar la página

Scenario: Autenticación fallida con credenciales inválidas
    Given soy un usuario que intenta autenticarse
    When ingreso credenciales inválidas en el formulario de login
    And intento iniciar sesión
    Then el sistema debe rechazar la autenticación
    And debo ver un mensaje de error claro indicando credenciales inválidas
    And no debo ser redirigido
    And mi estado debe permanecer como no autenticado

Scenario: Usuario deshabilitado no puede acceder
    Given mi cuenta de usuario ha sido deshabilitada
    When intento iniciar sesión con mis credenciales
    Then el sistema debe rechazar mi autenticación
    And debo ver un mensaje indicando que mi cuenta está deshabilitada
    And no debo poder acceder a ninguna área protegida del sistema

Scenario: Sesión persistente después de recargar navegador
    Given estoy autenticado exitosamente en el sistema
    And tengo una sesión activa válida
    When recargo la página del navegador
    Then el sistema debe reconocer mi sesión automáticamente
    And debo permanecer en la misma vista
    And mi información de usuario debe cargarse correctamente
```

---

# [HU-004] — Validar Tokens de Firebase en Cada Request del Backend

## Descripción

* **Como:** Arquitecto de seguridad del sistema
* **Quiero:** Que el API Gateway valide obligatoriamente el token JWT de Firebase en cada petición HTTP que reciba del frontend
* **Para:** Garantizar que solo usuarios autenticados y con tokens válidos puedan acceder a los endpoints protegidos, sincronizando la seguridad entre frontend y backend

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Petición con token válido es procesada
    Given estoy autenticado con un token válido de Firebase
    When realizo una petición a un endpoint protegido
    Then mi token debe ser validado exitosamente por el backend
    And la petición debe procesarse normalmente
    And debo recibir la respuesta exitosa esperada

Scenario: Petición sin token es rechazada
    Given no estoy autenticado en el sistema
    When intento realizar una petición a un endpoint protegido
    Then el backend debe rechazar la petición inmediatamente
    And debo recibir un error de autenticación requerida
    And la petición no debe procesarse

Scenario: Petición con token expirado o inválido es rechazada
    Given tengo un token que ha expirado o es inválido
    When envío una petición a un endpoint protegido
    Then el backend debe detectar que el token no es válido
    And debe rechazar la petición con error de autenticación
    And el frontend debe detectar el error y redirigirme al login

Scenario: Roles de usuario validados mediante custom claims
    Given estoy autenticado con un token que contiene mi rol
    When el backend valida mi petición
    Then debe extraer correctamente mi rol del token
    And debe permitir acceso solo a endpoints autorizados para mi rol
    And debe denegar acceso a endpoints no autorizados para mi rol
```

---

# [HU-005] — Implementar Logout Seguro y Limpieza de Sesión

## Descripción

* **Como:** Usuario autenticado del sistema
* **Quiero:** Poder cerrar sesión de forma segura y completa
* **Para:** Asegurar que mi token sea invalidado, mi estado de autenticación se limpie completamente y no pueda accederse a rutas protegidas después del logout

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Cierre de sesión exitoso
    Given estoy autenticado y navegando en el sistema
    When cierro sesión
    Then mi sesión debe ser terminada completamente
    And mi token de autenticación debe ser invalidado
    And mi estado de autenticación debe limpiarse
    And debo ser redirigido a la página de login

Scenario: Acceso a rutas protegidas bloqueado después de logout
    Given he cerrado sesión exitosamente
    When intento acceder a una ruta protegida
    Then el sistema debe detectar que no tengo sesión activa
    And debo ser redirigido al login
    And debo ver un mensaje indicando que debo autenticarme

Scenario: Sincronización de logout entre pestañas del navegador
    Given estoy autenticado en múltiples pestañas simultáneamente
    When cierro sesión en una pestaña
    Then todas las demás pestañas deben detectar el cierre de sesión
    And todas las pestañas deben actualizar su estado a no autenticado
    And todas deben redirigir al login
```

---

# [HU-006] — Validar Cancelación de Pedidos Solo en Estados Permitidos (Backend)

## Descripción

* **Como:** Desarrollador del Order Service
* **Quiero:** Implementar validación robusta en el backend que verifique el estado del pedido antes de permitir su cancelación
* **Para:** Prevenir que se cancelen pedidos que ya están en preparación, evitando pérdida de recursos y garantizando el cumplimiento de las reglas de negocio

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Cancelación exitosa de pedido en estado permitido
    Given existe un pedido en estado "pending"
    When se solicita cancelar el pedido
    Then el backend debe verificar que el estado actual permite cancelación
    And debe cambiar el estado del pedido a "cancelled"
    And debe registrar la fecha y hora de cancelación
    And debe confirmar la cancelación exitosa

Scenario: Cancelación rechazada para pedido en preparación
    Given existe un pedido en estado "preparing"
    When se intenta cancelar el pedido
    Then el backend debe verificar que el estado no permite cancelación
    And debe rechazar la operación de cancelación
    And el estado del pedido no debe modificarse
    And debe retornar un error indicando que no se puede cancelar en preparación

Scenario: Manejo de conflictos en cambio de estado simultáneo
    Given existe un pedido en estado "received"
    When ocurren dos operaciones simultáneas: inicio de preparación y cancelación
    Then solo una operación debe completarse exitosamente
    And la operación que se procese primero debe prevalecer
    And la operación posterior debe ser rechazada con error de conflicto

Scenario: Rechazo de cancelación duplicada
    Given existe un pedido que ya está en estado "cancelled"
    When se intenta cancelar el pedido nuevamente
    Then el backend debe detectar que ya está cancelado
    And debe rechazar la operación
    And debe indicar que el pedido ya fue cancelado previamente
```

---

# [HU-007] — Deshabilitar Botón de Cancelación en Frontend Según Estado

## Descripción

* **Como:** Cliente que realizó un pedido
* **Quiero:** Ver claramente si puedo o no cancelar mi pedido según su estado actual
* **Para:** Evitar confusión y frustración al intentar cancelar un pedido que ya está en preparación, recibiendo feedback visual inmediato

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Opción de cancelación visible para pedido pendiente
    Given tengo un pedido en estado "pending"
    When accedo a la página de seguimiento de mi pedido
    Then debo ver la opción para cancelar el pedido
    And la opción debe estar habilitada y disponible para uso

Scenario: Opción de cancelación oculta para pedido en preparación
    Given tengo un pedido en estado "preparing"
    When accedo a la página de seguimiento
    Then la opción de cancelar no debe estar visible
    And debo ver un mensaje informativo indicando que el pedido está en preparación
    And debo ver el estado actual del pedido claramente

Scenario: Opción de cancelación no disponible para pedido listo
    Given tengo un pedido en estado "ready"
    When visualizo el seguimiento del pedido
    Then no debe aparecer ninguna opción de cancelación
    And debo ver un mensaje indicando que el pedido está listo para recoger
    And debo ver el estado "Listo" claramente

Scenario: Confirmación requerida antes de cancelar
    Given veo la opción de cancelar mi pedido habilitada
    When intento cancelar el pedido
    Then debo ver una solicitud de confirmación
    And debo poder confirmar o rechazar la cancelación
    When confirmo la cancelación
    Then debe enviarse la solicitud de cancelación al sistema
```

---

# [HU-008] — Notificar a Cocina Cuando un Pedido es Cancelado

## Descripción

* **Como:** Personal de cocina
* **Quiero:** Ser notificado inmediatamente cuando un cliente cancela un pedido que estaba visible en mi panel
* **Para:** Evitar preparar pedidos cancelados y poder enfocarme en los pedidos activos

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Pedido cancelado se remueve del panel de cocina
    Given estoy visualizando el panel de cocina
    And hay un pedido visible en estado "received"
    When el cliente cancela ese pedido
    Then el pedido debe desaparecer inmediatamente de mi panel
    And no debe quedar rastro visual del pedido cancelado en la lista activa

Scenario: Notificación visual de cancelación
    Given estoy trabajando activamente en el panel de cocina
    When un pedido visible es cancelado
    Then puedo recibir una notificación visual temporal de la cancelación
    And la notificación debe indicar qué pedido fue cancelado
    And el pedido debe removerse de la lista de pedidos activos

Scenario: Acceso a historial de pedidos cancelados
    Given soy un usuario con permisos administrativos
    When accedo a la sección de historial de pedidos
    Then debo poder visualizar los pedidos cancelados
    And debo poder filtrar específicamente por pedidos cancelados
    And debo ver la información de cuándo fue cancelado cada pedido
```

---

# [HU-009] — Unificar Fuente de Verdad para Datos de Usuario

## Descripción

* **Como:** Arquitecto de datos del sistema
* **Quiero:** Definir e implementar una única fuente de verdad autoritativa para los datos de usuario, sincronizando Firebase Auth y Firestore
* **Para:** Eliminar inconsistencias donde un usuario existe en Firebase Auth pero no en Firestore (o viceversa), garantizando la integridad de los datos

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Creación sincronizada de usuario en ambos sistemas
    Given un administrador crea un nuevo usuario
    When se completa el proceso de creación
    Then el usuario debe existir en Firebase Auth
    And el usuario debe existir en Firestore con la misma identificación
    And ambos registros deben contener información consistente
    And si alguna operación falla, ambos sistemas deben revertir los cambios

Scenario: Actualización sincronizada de rol de usuario
    Given existe un usuario registrado en ambos sistemas
    When un administrador actualiza el rol del usuario
    Then el rol debe actualizarse en Firebase Auth
    And el rol debe actualizarse en Firestore
    And ambas actualizaciones deben completarse antes de confirmar éxito

Scenario: Detección de inconsistencias entre sistemas
    Given tengo acceso al sistema de gestión de usuarios
    When ejecuto una auditoría de sincronización
    Then debo obtener un listado de usuarios que existen en Firebase Auth pero no en Firestore
    And debo obtener un listado de registros en Firestore sin usuario correspondiente en Firebase Auth
    And debo recibir un reporte completo de las inconsistencias detectadas

Scenario: Desactivación sincronizada de usuario
    Given existe un usuario activo en el sistema
    When un administrador desactiva al usuario
    Then el usuario debe quedar deshabilitado en Firebase Auth
    And el usuario debe marcarse como inactivo en Firestore
    And el usuario no debe poder autenticarse en el sistema
    And ambos cambios deben aplicarse de forma atómica
```

---

# [HU-010] — Estandarizar y Verificar Nombres de Bases de Datos y Colecciones

## Descripción

* **Como:** Administrador de bases de datos
* **Quiero:** Auditar, estandarizar y corregir todos los nombres de bases de datos y colecciones para asegurar consistencia en mayúsculas/minúsculas
* **Para:** Prevenir errores silenciosos donde el código intenta conectarse a una colección con nombre incorrecto, obteniendo datos vacíos o fallando sin avisos claros

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Identificación de nombres inconsistentes
    Given existen múltiples servicios conectándose a bases de datos
    When se auditan los nombres utilizados en el sistema
    Then debo obtener un listado completo de todos los nombres de bases de datos
    And debo obtener un listado de todos los nombres de colecciones
    And debo identificar variaciones de mayúsculas/minúsculas para el mismo concepto

Scenario: Estándar de nomenclatura documentado
    Given se han identificado variaciones en nombres
    When se define el estándar de nomenclatura
    Then todos los nombres deben seguir convenciones consistentes de mayúsculas/minúsculas
    And las convenciones para nombres compuestos deben estar definidas
    And el estándar debe estar documentado y accesible para el equipo

Scenario: Nombres corregidos en todo el código
    Given existe un listado de nombres que requieren corrección
    When se aplican las correcciones en el código
    Then cada base de datos y colección debe tener un único nombre estandarizado
    And todas las variantes incorrectas deben ser eliminadas
    And el sistema debe compilar sin errores después de los cambios

Scenario: Conexiones exitosas después de estandarización
    Given todos los nombres han sido estandarizados
    When se ejecutan las pruebas de conexión de cada servicio
    Then todas las conexiones a bases de datos deben ser exitosas
    And los datos deben obtenerse correctamente
    And no debe haber errores de colecciones no encontradas
```

---

# [HU-011] — Consolidar Servicios de Analytics Duplicados

## Descripción

* **Como:** Desarrollador responsable de mantenimiento
* **Quiero:** Consolidar la lógica duplicada de analytics que existe en dos archivos (`api.js` y `analyticsService.js`) en una única implementación
* **Para:** Reducir la complejidad del código, facilitar el mantenimiento futuro y garantizar consistencia en todas las llamadas de analytics

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Funcionalidad duplicada identificada
    Given existen múltiples archivos con lógica de analytics
    When se analiza el código de analytics
    Then debo identificar todas las funciones que están duplicadas
    And debo verificar que las implementaciones duplicadas son equivalentes

Scenario: Lógica consolidada en implementación única
    Given se han identificado las duplicaciones de analytics
    When se consolida la funcionalidad
    Then debe existir una única implementación de cada función de analytics
    And toda la lógica necesaria debe estar centralizada
    And la implementación debe estar bien estructurada y documentada

Scenario: Referencias actualizadas en todo el código
    Given la lógica ha sido consolidada
    When se revisa el código que usa funciones de analytics
    Then todas las referencias deben apuntar a la implementación consolidada
    And no deben existir referencias a implementaciones duplicadas eliminadas
    And el sistema debe compilar sin warnings de dependencias no utilizadas

Scenario: Funcionalidad de analytics opera correctamente
    Given se ha consolidado el código de analytics
    When se ejecutan las funciones de analytics
    Then todas las métricas deben calcularse correctamente
    And el dashboard de analytics debe mostrar información precisa
    And el comportamiento debe ser idéntico a las versiones anteriores
```

---

# [HU-012] — Ajustar Tiempo de Expiración del Token de Sesión

## Descripción

* **Como:** Usuario del sistema administrativo
* **Quiero:** Que mi sesión tenga un tiempo de expiración razonable (mínimo 1 hora)
* **Para:** No tener que volver a iniciar sesión constantemente cada pocos segundos, permitiéndome trabajar de forma productiva

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Configuración de tiempo de expiración verificada
    Given el sistema de autenticación está configurado
    When se revisa la configuración del tiempo de expiración de tokens
    Then debe documentarse el tiempo de expiración actual
    And debe identificarse si corresponde al token estándar o personalizado

Scenario: Tiempo de expiración configurado a mínimo una hora
    Given se ha identificado que el tiempo de expiración es muy corto
    When se actualiza la configuración del sistema de autenticación
    Then el tiempo de vida del token debe ser de al menos una hora
    And la configuración debe aplicarse en todos los ambientes
    And debe quedar documentada en la configuración del proyecto

Scenario: Sesión se mantiene durante el tiempo configurado
    Given un usuario inicia sesión con la nueva configuración
    When el usuario trabaja en el sistema
    Then la sesión debe mantenerse activa durante al menos una hora
    And el usuario no debe ser desconectado antes de que expire el token
    When el token finalmente expira después de una hora
    Then el sistema debe detectar la expiración
    And debe redirigir al usuario al login con mensaje claro de sesión expirada

Scenario: Renovación automática de token antes de expiración
    Given un usuario tiene una sesión activa
    When el token está próximo a expirar
    Then el sistema puede intentar renovar automáticamente el token
    And si la renovación es exitosa, el usuario debe continuar sin interrupción
    And si la renovación falla, debe redirigir al login
```

---

# [HU-013] — Sistema de Encuestas de Proceso (Surveys)

## Descripción

* **Como:** Cliente del restaurante Delicious Kitchen
* **Quiero:** Poder evaluar el proceso de atención mientras espero mi pedido
* **Para:** Dar feedback sobre tiempos de espera y atención del personal

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Cliente envía encuesta exitosamente
    Given un pedido en estado "preparing" o "ready"
    When el cliente completa ratings válidos (1-5)
    Then el sistema guarda la encuesta vinculada al orderNumber
    And muestra "¡Gracias por tu opinión!"

Scenario: Sistema previene encuestas duplicadas
    Given ya existe encuesta para un orderNumber
    When se intenta enviar otra para el mismo pedido
    Then rechaza con error 409 "Ya enviaste tu opinión"

Scenario: Encuesta con datos inválidos es rechazada
    Given ratings fuera de rango (0 o 6)
    When el cliente intenta enviar
    Then rechaza con error 400 "Ratings deben estar entre 1 y 5"
```

---

# [HU-014] — Sistema de Reseñas Públicas (Reviews)

## Descripción

* **Como:**  Cliente del restaurante Delicious Kitchen
* **Quiero:** Poder dejar una reseña sobre la comida en cualquier momento
* **Para:** Compartir mi experiencia gastronómica después de consumir

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Cliente crea reseña sin orderNumber
    Given un cliente accede a /reviews/new
    When completa foodRating y tasteRating (requeridos)
    Then crea reseña con orderNumber = "N/A"
    And asigna status = "pending"

Scenario: Reseña con orderNumber válido se enriquece
    Given el cliente proporciona orderNumber existente
    When el sistema encuentra el pedido
    Then agrega metadata (items, total, fecha)

Scenario: Reseña con orderNumber inválido se acepta
    Given orderNumber que no existe en BD
    When el sistema no lo encuentra
    Then crea la reseña sin metadata
    And NO rechaza la solicitud

Scenario: Cliente puede dejar múltiples reseñas
    Given el cliente ya dejó una reseña antes
    When crea otra reseña nueva
    Then el sistema la acepta sin validar duplicados
```

---

# [HU-015] — Estandarizar Nomenclatura de Estados de Pedido Entre Servicios

## Descripción

* **Como:** Arquitecto de sistemas
* **Quiero:** Definir, documentar e implementar una nomenclatura unificada y consistente para los estados de pedidos en todos los servicios (UI, Order Service, Kitchen Service)
* **Para:** Eliminar ambigüedades en el mapeo de estados, asegurar que los eventos de actualización de estado se manejen correctamente y facilitar el seguimiento coherente de pedidos

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Estados oficiales del sistema documentados
    Given se requiere unificar la nomenclatura de estados
    When se definen los estados oficiales
    Then debe existir documentación completa de todos los estados de pedido
    And debe especificarse claramente el significado de cada estado
    And deben definirse las transiciones permitidas entre estados

Scenario: Mapeo de estados entre servicios establecido
    Given diferentes servicios usan distintas nomenclaturas
    When se crea el mapeo de equivalencias
    Then debe documentarse la correspondencia entre estados en cada servicio
    And debe especificarse cómo cada servicio representa el mismo concepto
    And deben eliminarse nombres ambiguos sin mapeo claro

Scenario: Eventos de cambio de estado estandarizados
    Given los servicios publican eventos de actualización de estado
    When un pedido cambia de estado
    Then los eventos deben usar nombres de estado consistentes
    And el formato de eventos debe ser uniforme en todos los servicios
    And todos los servicios deben interpretar los estados de la misma manera

Scenario: Código actualizado con nomenclatura estandarizada
    Given se han definido los estados oficiales
    When se implementa la estandarización en el código
    Then todos los valores de estado deben usar la nomenclatura oficial
    And debe existir una definición centralizada de estados
    And todas las referencias deben usar esta definición central
```

---

# [HU-016] — Completar Traducciones i18n para Generación de Orden

## Descripción

* **Como:** Usuario del sistema que prefiere usar inglés
* **Quiero:** Que la sección de generación de pedidos esté completamente traducida
* **Para:** Tener una experiencia consistente en mi idioma preferido sin encontrar textos en español cuando espero ver inglés

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Textos sin traducir identificados
    Given existe la funcionalidad de generación de pedidos
    When se auditan los textos en la interfaz
    Then deben identificarse todos los textos que no tienen traducción
    And debe crearse un listado de elementos que requieren internacionalización

Scenario: Traducciones agregadas para inglés
    Given se han identificado textos sin traducir
    When se completan las traducciones al inglés
    Then todos los textos de generación de pedidos deben tener versión en inglés
    And las traducciones deben ser naturales y precisas
    And deben seguir el mismo tono del resto del sistema

Scenario: Traducciones agregadas para español
    Given se requiere soporte multiidioma
    When se completan las traducciones al español
    Then todos los textos deben tener su versión en español
    And deben mantener consistencia con la terminología existente

Scenario: Cambio de idioma funciona correctamente en generación de pedidos
    Given estoy en la sección de generación de pedidos
    When cambio el idioma del sistema
    Then todos los textos de la sección deben actualizarse al nuevo idioma
    And no debe quedar ningún texto sin traducir
    And la preferencia de idioma debe mantenerse al recargar
```

---

# [HU-017] — Completar Traducciones i18n para Nombres de Roles

## Descripción

* **Como:** Administrador que gestiona usuarios en el sistema
* **Quiero:** Que los nombres de roles se muestren traducidos según el idioma seleccionado
* **Para:** Que el personal que no habla español pueda entender claramente los roles en su idioma nativo

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Traducciones de roles definidas
    Given el sistema maneja múltiples roles de usuario
    When se configuran las traducciones
    Then cada rol debe tener su traducción correspondiente en cada idioma soportado

Scenario: Traducciones en inglés para roles configuradas
    Given se requiere soporte en inglés
    When se configuran las traducciones de roles
    Then cada rol debe tener su nombre en inglés definido
    And las traducciones deben ser claras y profesionales

Scenario: Traducciones en español para roles configuradas
    Given se requiere soporte en español
    When se configuran las traducciones de roles
    Then cada rol debe tener su nombre en español definido
    And deben mantener consistencia con el resto del sistema

Scenario: Roles mostrados en idioma seleccionado
    Given estoy en la gestión de usuarios como administrador
    When visualizo los roles de los usuarios
    Then los nombres de roles deben mostrarse en el idioma actual del sistema
    And al cambiar el idioma, los nombres deben actualizarse inmediatamente
```

---

# [HU-018] — Centralizar URLs de Backend en Variables de Entorno

## Descripción

* **Como:** Ingeniero de DevOps
* **Quiero:** Que todas las URLs específicas del entorno (API Gateway, SSE de notificaciones) estén configuradas mediante variables de entorno
* **Para:** Facilitar el despliegue de la aplicación en diferentes ambientes (desarrollo, staging, producción) sin tener que modificar el código fuente

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: URLs específicas del entorno identificadas
    Given el sistema se conecta a servicios backend
    When se revisa la configuración de URLs
    Then deben identificarse todas las URLs que dependen del entorno
    And debe crearse un listado de URLs que requieren configuración externa

Scenario: Plantilla de variables de entorno creada
    Given se han identificado las URLs configurables
    When se crea la documentación de configuración
    Then debe existir una plantilla con todas las variables necesarias
    And debe incluir valores de ejemplo para cada variable
    And debe documentarse el propósito de cada variable

Scenario: URLs configuradas mediante variables de entorno
    Given existe la definición de variables de entorno
    When se implementa la configuración en el código
    Then las URLs deben obtenerse de variables de entorno
    And no deben existir URLs fijas en el código fuente
    And el sistema debe compilar correctamente

Scenario: Sistema funciona en múltiples ambientes
    Given las URLs están configuradas mediante variables de entorno
    When se despliega en ambiente de desarrollo
    Then debe conectarse a las URLs de desarrollo
    When se despliega en ambiente de producción
    Then debe conectarse a las URLs de producción
    And la aplicación debe funcionar correctamente en ambos ambientes
```

---

---

# [HU-019] — Validar y Corregir Datos en Reportes de Analytics

## Descripción

* **Como:** Administrador que toma decisiones de negocio basadas en métricas
* **Quiero:** Que los reportes de analytics muestren datos precisos y consistentes con la base de datos real
* **Para:** Tomar decisiones informadas sin discrepancias entre reportes y datos reales, especialmente considerando pedidos cancelados y filtros de fecha

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Auditoría de queries de analytics identifica inconsistencias
    Given existen reportes de analytics con posibles discrepancias
    When se ejecuta auditoría de queries
    Then debe identificarse si pedidos cancelados están siendo incluidos incorrectamente
    And debe verificarse si filtros de fecha funcionan correctamente
    And debe crearse reporte de inconsistencias encontradas

Scenario: Total de órdenes coincide con base de datos
    Given existe un reporte que muestra "Total de Órdenes: 150"
    When se consulta directamente MongoDB con el mismo filtro de fecha
    Then el conteo de la BD debe coincidir exactamente con el reporte
    And los pedidos cancelados deben ser excluidos del conteo
    Or claramente marcados como categoría separada

Scenario: Pedidos cancelados claramente separados en reportes
    Given existen pedidos con estado "cancelled"
    When visualizo el dashboard de analytics
    Then debe haber una sección separada para "Pedidos Cancelados"
    And el "Total de Órdenes Completadas" no debe incluir cancelados
    And debe mostrarse claramente: "Completados: X | Cancelados: Y"

Scenario: Filtros de fecha funcionan correctamente
    Given estoy en el dashboard de analytics
    When selecciono rango: "Del 1 al 15 de diciembre"
    And hago clic en "Aplicar filtro"
    Then solo deben mostrarse pedidos con fecha dentro del rango
    And el conteo debe corresponder exactamente a pedidos en ese período
    When comparo con query SQL/MongoDB directa
    Then los resultados deben ser idénticos

Scenario: Exportación CSV refleja datos exactos
    Given visualizo un reporte con 100 pedidos completados
    When hago clic en "Exportar a CSV"
    And abro el archivo descargado
    Then el CSV debe contener exactamente 100 filas (más encabezados)
    And cada fila debe corresponder a un pedido en la BD
    And los valores (fecha, monto, estado) deben coincidir exactamente

Scenario: Validación automática de consistencia de reportes
    Given se generan reportes periódicamente
    When se ejecuta el sistema de validación automática
    Then debe compararse cada métrica con query directa a BD
    And si hay discrepancia mayor al 1%
    Then debe enviarse alerta al administrador
    And debe registrarse en logs para auditoría
```

---

# [HU-020] — Optimizar Experiencia de Usuario en Dashboard de Analytics

## Descripción

* **Como:** Administrador que analiza métricas de negocio diariamente
* **Quiero:** Que el dashboard de analytics tenga una interfaz intuitiva, reactiva y con información clara sobre los datos mostrados
* **Para:** Analizar métricas de forma eficiente sin confusiones, con actualizaciones automáticas y visualizaciones que reflejen exactamente el período consultado

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Filtros se aplican automáticamente sin botón manual
    Given estoy en el dashboard de analytics
    When cambio la fecha "Desde" de "1 dic" a "15 nov"
    Or cambio la fecha "Hasta" de "17 dic" a "20 dic"
    Or cambio "Agrupar por" de "mes" a "semana"
    Then el dashboard debe actualizarse automáticamente
    And no debe existir botón "Ver métricas" o "Consultar"
    And los datos deben reflejarse en menos de 2 segundos

Scenario: Rango de fechas permite consultas históricas de 10 años
    Given estoy seleccionando fechas en los filtros
    When intento seleccionar fecha "Desde" del año 2020
    Then el sistema debe permitir la selección
    And debe poder consultar datos desde hace 10 años
    When intento seleccionar fecha futura
    Then el sistema debe bloquear la selección
    And la fecha máxima debe ser hoy

Scenario: Gráficos muestran rango de fechas real seleccionado
    Given he seleccionado rango "15 nov - 20 dic"
    When visualizo los gráficos de líneas y barras
    Then el subtítulo debe mostrar "15 nov - 20 dic"
    And NO debe mostrar texto genérico como "Últimos 30 días"
    When selecciono un solo día "17 dic"
    Then el subtítulo debe mostrar "17 dic"

Scenario: Subtítulos de gráficos respetan idioma seleccionado
    Given tengo el sistema en español
    And he seleccionado rango "1 dic - 15 dic"
    When visualizo los gráficos
    Then el subtítulo debe mostrar "1 dic - 15 dic"
    When cambio el idioma a inglés
    Then el subtítulo debe actualizarse a "Dec 1 - Dec 15"

Scenario: Tabla muestra resumen por período sin repeticiones
    Given estoy consultando datos agrupados por "semana"
    When visualizo la tabla de datos
    Then debe mostrar columnas: Período, Órdenes Completadas, Órdenes Canceladas, Ingresos Totales, Ingresos Perdidos
    And cada período debe aparecer una sola vez
    And NO debe mostrar productos individuales en la tabla
    And los productos deben visualizarse solo en el gráfico de barras

Scenario: Tabla incluye métricas de órdenes canceladas
    Given existen pedidos cancelados en el período consultado
    When visualizo la tabla de datos
    Then debe existir columna "Órdenes Canceladas" con conteo
    And debe existir columna "Ingresos Perdidos" con monto
    And los valores de cancelados deben destacarse visualmente (color ámbar/rojo)
    And los períodos sin cancelaciones deben mostrar 0

Scenario: Exportación CSV refleja estructura de tabla actual
    Given estoy visualizando la tabla con 5 períodos
    When hago clic en "Exportar CSV"
    And abro el archivo descargado
    Then el CSV debe contener exactamente 5 filas de datos (+ encabezado)
    And las columnas deben ser: period, totalOrders, totalCancelled, totalRevenue, lostRevenue
    And NO debe incluir columnas de productos (productId, productName, quantity)
    And los valores deben coincidir exactamente con la tabla visible

Scenario: Gráfico de líneas muestra correctamente valores bajos
    Given existen períodos con pocas órdenes (ej: 2, 3, 5 órdenes)
    When visualizo el gráfico de líneas "Órdenes por período"
    Then la línea verde debe ser visible y separada del eje X
    And NO debe aparecer pegada al borde inferior
    And debe aplicarse margen del 10% en la escala vertical
    And los valores deben ser legibles en todos los puntos
```

---

# [HU-021] — Implementar Notificaciones por Email para Clientes Offline

## Descripción

* **Como:** Cliente de Delicious Kitchen que realizó un pedido
* **Quiero:** Recibir notificaciones por correo electrónico cuando mi pedido cambie de estado (en preparación y listo para recoger)
* **Para:** Estar informado del progreso de mi pedido incluso si cierro el navegador o pierdo la conexión, sin tener que revisar manualmente el estado constantemente

## Criterios de Aceptación (Gherkin)

```gherkin
Scenario: Email enviado cuando pedido entra en preparación
    Given existe un pedido en estado "received" 
    And el pedido tiene email del cliente registrado
    When el personal de cocina inicia la preparación del pedido
    And el estado cambia a "preparing"
    Then el sistema debe publicar evento "order.preparing" en RabbitMQ
    And el Notification Service debe consumir el evento
    And debe enviar un email al cliente con:
      - Asunto: "Tu pedido está en preparación"
      - Mensaje: "Hola, sabemos que tienes hambre, queremos notificarte que tu pedido ya está en preparación"
      - Lista de items del pedido (nombre y cantidad)
      - URL de seguimiento del pedido
    And el email debe usar la plantilla HTML con branding del restaurante

Scenario: Email enviado cuando pedido está listo para recoger
    Given existe un pedido en estado "preparing"
    And el pedido tiene email del cliente registrado
    When el personal de cocina marca el pedido como listo
    And el estado cambia a "ready"
    Then el sistema debe publicar evento "order.ready" en RabbitMQ
    And el Notification Service debe consumir el evento
    And debe enviar un email al cliente con:
      - Asunto: "¡Tu pedido está listo!"
      - Mensaje: "¡Genial! Tu pedido ya está listo para recoger"
      - Lista completa de items del pedido
      - URL de seguimiento del pedido
      - Enlace para dejar una reseña
    And el email debe usar la plantilla HTML con colores corporativos (#ff7e33)

Scenario: Email no enviado si faltan datos requeridos
    Given existe un pedido que cambia a estado "preparing" o "ready"
    When el evento llega al Notification Service
    And faltan datos críticos (customerEmail, orderNumber o items)
    Then el sistema NO debe enviar email
    And debe registrar en logs: "⚠️ Orden XXX en [estado] pero faltan datos para email"
    And debe continuar procesando normalmente sin errores fatales

Scenario: Emails contienen información personalizada del pedido
    Given un pedido tiene items: [Pizza Margarita x2, Hamburguesa Clásica x1]
    When se envía email de notificación
    Then el email debe mostrar:
      - "Pizza Margarita x 2"
      - "Hamburguesa Clásica x 1"
    And debe incluir URL: {FRONTEND_URL}/orders/{orderNumber}
    And la URL debe ser configurable mediante variable de entorno

Scenario: Plantilla HTML responsive para diferentes dispositivos
    Given se envía un email de notificación
    When el cliente lo abre en dispositivo móvil o desktop
    Then la plantilla debe adaptarse correctamente
    And debe incluir versión plain text como fallback
    And debe usar gradiente de marca: linear-gradient(135deg, #ff7e33 0%, #ff5722 100%)

Scenario: Fallback de configuración de URL frontend
    Given la variable de entorno FRONTEND_URL no está configurada
    When el sistema genera URLs en emails
    Then debe usar valor por defecto: "http://localhost:5173"
    And debe seguir funcionando sin errores
    And debe registrarse en logs que está usando configuración por defecto
```