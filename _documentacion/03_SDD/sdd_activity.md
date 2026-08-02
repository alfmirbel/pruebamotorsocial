# SDD - Activity
# Especificación Driven Design basada en ingeniería reversa de `/mnt/pruebamotorsocial/lib/motorsocial/activity`

## 1. Requerimientos Ubicuarios

1. El sistema deberá exponer contratos de actividad social y modelos de feed.
2. El sistema deberá soportar reacciones, conversaciones y notificaciones de actividad.
3. El sistema deberá ofrecer vistas de feed y detalle de conversación.

## 2. Requerimientos Controlados por Eventos

1. Cuando el usuario abra la actividad, el sistema deberá inicializar `ActivityEngine`.
2. Cuando se publique una actividad, el sistema deberá insertar un nuevo elemento en el feed.
3. Cuando el usuario reaccione a una actividad, el sistema deberá actualizar el contador de reacciones.
4. Cuando se abra una conversación, el sistema deberá exponer el hilo mediante `conversation_notifier`.

## 3. Requerimientos Controlados por Estados

1. Mientras el feed esté cargando, el sistema deberá exponer un estado intermedio.
2. Mientras existan actividades nuevas, el sistema debera refrescar la vista de feed.
3. Mientras la conversación esté activa, el sistema deberá mantener el foco en el hilo seleccionado.

## 4. Requerimientos de Comportamiento No Deseado

1. Si la respuesta del repositorio falla, entonces el sistema deberá exponer un error controlado en el widget.
2. Si no existen actividades, entonces el sistema deberá mostrar un estado vacío.

## 5. Requerimientos de Funciones Opcionales

1. Donde el sistema incluya el módulo `activity`, el sistema deberá exponer `ActivityEngine` y contratos de feed.
2. Donde el sistema incluya reacciones, el sistema deberá proveer `reaction_notifier`.
3. Donde el sistema incluya conversaciones, el sistema deberá proveer `conversation_notifier`.
