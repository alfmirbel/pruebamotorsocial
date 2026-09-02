# SDD — Feature: App Providers

## 1. Resumen
Estado global mínimo de la aplicación mediante `StateProvider`.

## 2. Proveedores
- `sessionProvider`: mapa `{userId, token}`.
- `chatMessagesProvider`: lista de mensajes.
- `socialFeedProvider`: lista social.
- `socialAppConfigProvider` (core): config requerida con fallo si falta.

## 3. Datos
- Todos exponen valores default/vacíos.

## 4. Requisitos
| ID | Requisito | Evidencia |
|-----|-----------|-----------|
| RF-PROV-01 | Sostener estado reactivo de sesión, chat y feed. | `sessionProvider`, `chatMessagesProvider`, `socialFeedProvider`. |
| RF-PROV-02 | Forzar inicialización de configuración. | `socialAppConfigProvider` falla si no inyectada. |
