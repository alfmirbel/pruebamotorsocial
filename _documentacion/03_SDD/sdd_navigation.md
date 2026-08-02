# SDD - Navigation
# Especificación Driven Design basada en ingeniería reversa de `/mnt/pruebamotorsocial/lib/motorsocial/navigation`

## 1. Requerimientos Ubicuarios

1. El sistema deberá centralizar la navegación y rutas de la aplicación.
2. El sistema deberá proveer un scaffold social con barra de navegación inferior.
3. El sistema deberá exponer contratos de navegación tipados.

## 2. Requerimientos Controlados por Eventos

1. Cuando se seleccione un destino en `SocialScaffold`, el sistema deberá actualizar el índice activo.
2. Cuando el índice cambie, el sistema deberá navegar con `pushReplacementNamed` si aplica.
3. Cuando se evalúe una ruta desconocida, el sistema deberá mostrar `_NotFoundPage`.
4. Cuando `AppRouter.routeFor()` reciba un nombre, el sistema deberá retornar la ruta mapeada.

## 3. Requerimientos Controlados por Estados

1. Mientras el usuario esté autenticado, el sistema deberá mostrar la barra de navegación inferior.
2. Mientras el usuario no esté autenticado, el sistema deberá ocultar la barra inferior.

## 4. Requerimientos de Comportamiento No Deseado

1. Si la ruta solicitada no existe, entonces el sistema deberá mostrar la página de no encontrado.
2. Si el índice ingresado está fuera del rango de tabs, entonces el sistema deberá ignorar el cambio.

## 5. Requerimientos de Funciones Opcionales

1. Donde el sistema incluya el módulo `navigation`, el sistema deberá exponer `AppRouter`, `SocialScaffold` y contratos.
2. Donde el sistema incluya `route_guard`, el sistema deberá restringir acceso a rutas protegidas.
3. Donde el sistema incluya `tab_menu_notifier`, el sistema deberá persistir el tab seleccionado.
