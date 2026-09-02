# SDD — Feature: Chat

## 1. Resumen
Pantalla placeholder de chat/grupos.

## 2. Datos
- Lee `databaseModule` desde `motorSocialBridgeProvider`.
- Muestra texto indicando conexión a `SocialGraphContract` y referencia `groups`.

## 3. Requisitos
| ID | Requisito | Evidencia |
|-----|-----------|-----------|
| RF-CHAT-01 | Mostrar página de chat/grupos conectada al módulo social. | `ChatPage` referencia `SocialGraphContract` y `databaseModule.groups`. |
