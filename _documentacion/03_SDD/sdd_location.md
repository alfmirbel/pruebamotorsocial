# SDD - Location
# Especificación Driven Design basada en ingeniería reversa de `/mnt/pruebamotorsocial/lib/motorsocial/location`

## 1. Requerimientos Ubicuarios

1. El sistema deberá exponer contratos de localidad y geolocalización.
2. El sistema deberá soportar selección de localidad desde UI dedicada.
3. El sistema deberá mantener estado de carga y error por defecto vacío.

## 2. Requerimientos Controlados por Eventos

1. Cuando el usuario abra el selector de localidad, el sistema deberá inicializar `LocationEngine`.
2. Cuando se confirme una localidad, el sistema deberá actualizar `locality` en `LocationState`.
3. Cuando el repositorio de geolocalización retorne datos, el sistema deberá mapearlos al contrato.

## 3. Requerimientos Controlados por Estados

1. Mientras la carga esté en curso, `isLoading` deberá ser `true`.
2. Mientras no exista error, `error` deberá ser nulo.
3. Mientras no se seleccione localidad, `locality` deberá ser cadena vacía.

## 4. Requerimientos de Comportamiento No Deseado

1. Si la geolocalización falla, entonces el sistema deberá preservar la localidad previa y exponer el mensaje de error.
2. Si los permisos de ubicación están denegados, entonces el sistema deberá mostrar un estado de error controlado.

## 5. Requerimientos de Funciones Opcionales

1. Donde el sistema incluya el módulo `location`, el sistema deberá exponer `LocationEngine`, `LocationState` y contratos.
2. Donde el sistema incluya `locality_picker_page`, el sistema deberá proveer una UI de selección.
3. Donde el sistema incluya repositorios específicos, el sistema deberá separar geolocalización de códigos postales.
