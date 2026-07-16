# SDD — Feature: Configuration

## 1. Resumen

`SocialAppConfig` centraliza contratos de módulos del MotorSocial y provee defaults/estado por módulo.

## 2. Alcance

`../pruebamotorsocial/lib/core/config/social_app_config.dart` + `social_app_config_provider.dart`.

## 3. Modelos

- Campos identidad, tema, navegación, localidad, catálogo, media, actividad, módulos.
- `SocialIdentityContract`, `NavigationContract`, `LocationContract`, `CatalogContract`, `MediaContract`, `ActivityContract`.

## 4. Funciones

- `SocialAppConfig.defaults()`: valores por defecto.
- `moduleStatus(String name)`: devuelve `'stub'` para módulos conocidos o `null` para desconocidos.
- `fromJson(Map)` implícito en `main.dart` para cargar `assets/contracts/motorsocial_contracts.json`.

## 5. Proveedores

- `socialAppConfigProvider` lanza si no se inyecta configuración previa a `runApp`.

## 6. Requisitos

| ID        | Requisito                                        | Evidencia                                   |
| --------- | ------------------------------------------------ | ------------------------------------------- |
| RF-CFG-01 | Permitir configuración centralizada del dominio. | `SocialAppConfig` con contratos por módulo. |
| RF-CFG-02 | Proveer defaults desacoplados de backend.        | `SocialAppConfig.defaults()`.               |
| RF-CFG-03 | Reportar estado de módulos.                      | `moduleStatus`.                             |
| RF-CFG-04 | Exigir inicialización temprana del config.       | `socialAppConfigProvider` lanza si falta.   |
