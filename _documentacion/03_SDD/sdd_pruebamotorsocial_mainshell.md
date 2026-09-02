# SDD — Feature: MainShell / App

## 1. Resumen

`MainShell` controla la navegación principal autenticada, protegiendo el acceso con la sesión y alternando pantalla por índice en un `IndexedStack`.

## 2. Alcance

Código en `../pruebamotorsocial/lib/core/app_shell.dart` y dependencias de `features`.

## 3. Comportamiento

- Si `session['userId']` es nulo/vacío, redirige a `LoginPage`.
- Stack indexado de páginas principales: Home, Feed, Chat, Catalog, Account, Profile.
- `_PagesState` gestiona índice con clamp `[0..5]`.
- Bottom nav declarada pero no funcional (`SizedBox.shrink`), placeholder para índices reactivos en `app_providers`.
- Feed y Chat son placeholders explícitos pendientes de conexión con `ActivityContract` / `SocialGraphEngine`.

## 4. Rutas / Screens

- `LoginPage`
- `HomePage`
- `_FeedPlaceholder`
- `_ChatPlaceholder`
- `CatalogPage`
- `AccountPage`
- `ProfilePage`

## 5. Datos

- Recibe `SocialAppConfig` y `Map<String, String?> session`.

## 6. Requisitos derivados

| ID        | Requisito                                                | Evidencia                                              |
| --------- | -------------------------------------------------------- | ------------------------------------------------------ | --- | ------------------------------- |
| RF-MSH-01 | Mostrar login cuando no haya sesión autenticada.         | `userId == null                                        |     | userId.isEmpty`=>`LoginPage()`. |
| RF-MSH-02 | Proveer navegación por tabs principales.                 | `IndexedStack` con 6 páginas, `_BottomNav`, `_onTap`.  |
| RF-MSH-03 | Aislar casos de uso no conectados mediante placeholders. | `_FeedPlaceholder`, `_ChatPlaceholder`, `AccountPage`. |

## 7. Notas / Deuda técnica

- `_BottomNav` sin interacción real; comentario apunta a `app_providers` para el índice compartido.
- `session` se recibe por constructor y también se lee por `sessionProvider`; potencial inconsistencia.
