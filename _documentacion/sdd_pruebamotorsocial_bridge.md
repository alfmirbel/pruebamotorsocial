# SDD — Feature: MotorSocial Bridge

## 1. Resumen
`MotorSocialBridge` es la composición principal de motores y repositorios usada por la app; centraliza configuraciones y expone `moduleStatus`.

## 2. Componentes
- `createMotorSocialBridge`: ensambla `CatalogEngine`, `SocialIdentityEngine`, `DesignEngine` y `activityRepository`.
- Repositorios locales por defecto cuando no se reciben externos: catálogo, auth, theme.
- `MotorSocialBridgeNotifier`: constructor por defecto con instancias mínimas.
- `motorSocialBridgeProvider`: provider compartido del bridge.
- `socialAppConfigProvider`: derivado del bridge.

## 3. Datos
- Construye config con campos para identity, navigation, location, catalog, media, activity.

## 4. Requisitos
| ID | Requisito | Evidencia |
|-----|-----------|-----------|
| RF-BRG-01 | Ensamblar motores de dominio en un único punto. | `MotorSocialBridge` con catalog, identity, design. |
| RF-BRG-02 | Configurar repos in-memory cuando no haya proveedor. | `_InMemoryCatalogRepository`, `_InMemoryAuthRepository`, `_InMemoryThemeRepository`. |
| RF-BRG-03 | Exponer config activa como provider. | `socialAppConfigProvider = Provider`. |

## 5. Observaciones
- En `main.dart` se retoma bridge override con `DatabaseModule` y tema fijo `_InMemoryThemeRepository`; hay duplicación de defaults.
- No incluye módulos media/location/security en el bridge principal.
