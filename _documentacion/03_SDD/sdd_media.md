# SDD - Media
# Especificación Driven Design basada en ingeniería reversa de `/mnt/pruebamotorsocial/lib/motorsocial/media`

## 1. Requerimientos Ubicuarios

1. El sistema deberá representar activos multimedia mediante contratos tipados.
2. El sistema deberá soportar galerías, selectores y presentaciones.
3. El sistema deberá abstraer el origen y formato de los medios.

## 2. Requerimientos Controlados por Eventos

1. Cuando el usuario abra la biblioteca, el sistema deberá cargar `mediaIds` desde `mediaLibraryProvider`.
2. Cuando se seleccione un medio, el sistema deberá exponer el asset seleccionado.
3. Cuando se inicie una presentación, el sistema deberá avanzar automáticamente entre medios.
4. Cuando el usuario ordene el álbum, el sistema deberá aplicar el criterio de ordenamiento.

## 3. Requerimientos Controlados por Estados

1. Mientras la biblioteca esté vacía, el sistema deberá mostrar una lista vacía.
2. Mientras la presentación esté activa, el sistema debera exponer el índice actual.
3. Mientras se cargue un medio, el sistema deberá exponer un estado de carga.

## 4. Requerimientos de Comportamiento No Deseado

1. Si el medio no existe o falla la carga, entonces el sistema deberá exponer un estado de error sin cerrar la UI.

## 5. Requerimientos de Funciones Opcionales

1. Donde el sistema incluya el módulo `media`, el sistema deberá exponer `MediaEngine`, contratos y providers.
2. Donde el sistema incluya slider, el sistema debera proveer navegación táctil entre medios.
3. Donde el sistema incluya selector, el sistema deberá permitir elegir uno o varios assets.
