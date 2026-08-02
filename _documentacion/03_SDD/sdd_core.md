# SDD - Core
# Especificación Driven Design basada en ingeniería reversa de `/mnt/pruebamotorsocial/lib/core`

## 1. Requerimientos Ubicuarios

1. El sistema deberá inicializar el enlace de widgets Flutter antes de ejecutar cualquier lógica de aplicación.
2. El sistema deberá exponer una configuración predeterminada de aplicación cuando no se provea configuración externa.
3. El sistema deberá mantener el estado de sesión accesible desde el árbol de providers de Riverpod.
4. El sistema deberá permitir reemplazar dependencias mediante overrides en `ProviderScope`.
5. El sistema deberá ofrecer un módulo de persistencia local cuando el remoto no esté disponible.

## 2. Requerimientos Controlados por Eventos

1. Cuando la aplicación se inicie, el sistema deberá construir `SocialAppConfig.defaults()`.
2. Cuando se cree el `ProviderScope`, el sistema deberá inyectar `motorSocialBridgeProvider` con el bridge creado a partir de la configuración.
3. Cuando el usuario no tenga `userId`, el sistema deberá mostrar `LoginPage`.
4. Cuando el usuario tenga `userId` válido, el sistema deberá presentar `MainShell` con barra de navegación inferior.
5. Cuando se seleccione una pestaña inferior, el sistema deberá actualizar el índice activo del `IndexedStack`.

## 3. Requerimientos Controlados por Estados

1. Mientras el sistema esté en estado `_loading`, el sistema deberá deshabilitar el botón de login y mostrar `CircularProgressIndicator`.
2. Mientras el usuario no esté autenticado, el sistema deberá ocultar la barra de navegación inferior.
3. Mientras exista sesión activa, el sistema deberá conservar el índice de navegación seleccionado.
4. Mientras la aplicación esté en tema oscuro, el sistema deberá aplicar `Brightness.dark` a `colorScheme`.

## 4. Requerimientos de Comportamiento No Deseado

1. Si `WidgetsFlutterBinding.ensureInitialized()` falla, entonces el sistema deberá propagar la excepción y no iniciar la aplicación.
2. Si `DatabaseModule.local()` no puede inicializarse, entonces el sistema deberá continuar en modo stub.
3. Si el `userId` es nulo o vacío, entonces el sistema deberá evitar mostrar `MainShell`.
4. Si el índice de navegación está fuera de rango, entonces el sistema deberá clampizar el valor entre 0 y 5.

## 5. Requerimientos de Funciones Opcionales

1. Donde el sistema incluya el módulo `motorsocial_bridge`, el sistema deberá exponer `motorSocialBridgeProvider` para consumo de features.
2. Donde el sistema incluya `social_app_config`, el sistema deberá permitir factorías `defaults()` y `fromJson()`.
3. Donde el sistema incluya `database_module`, el sistema deberá ofrecer `DatabaseModule.local()` y/o implementaciones en memoria.
