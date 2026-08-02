# SDD - Security
# Especificación Driven Design basada en ingeniería reversa de `/mnt/pruebamotorsocial/lib/motorsocial/security`

## 1. Requerimientos Ubicuarios

1. El sistema deberá recolectar eventos de seguridad tipados.
2. El sistema deberá exponer información de dispositivo y rate-limit.
3. El sistema deberá proveer un motor de seguridad inicializable.

## 2. Requerimientos Controlados por Eventos

1. Cuando se detecte un evento inseguro, el sistema deberá registrar un `SecurityEvent`.
2. Cuando se supere el límite de solicitudes, el sistema deberá actualizar `rateLimitState`.
3. Cuando `SecurityEngine` se inicialice, el sistema deberá asociar el repositorio de seguridad.

## 3. Requerimientos Controlados por Estados

1. Mientras no haya eventos registrados, el sistema deberá exponer una colección vacía.
2. Mientras el rate-limit esté activo, el sistema deberá exponer el estado de bloqueo.

## 4. Requerimientos de Comportamiento No Deseado

1. Si no se puede registrar el evento, entonces el sistema deberá continuar sin bloquear el flujo principal.
2. Si el repositorio de seguridad no responde, entonces el sistema deberá degradar a almacenamiento local.

## 5. Requerimientos de Funciones Opcionales

1. Donde el sistema incluya el módulo `security`, el sistema deberá exponer `SecurityEngine`, contratos y repositorios.
2. Donde el sistema incluya `security_notifier`, el sistema deberá proveer estado reactivo de seguridad.
3. Donde el sistema incluya `device_info`, el sistema deberá exponer metadatos del dispositivo.
