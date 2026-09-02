# SDD — Requerimientos del Sistema
## Formato EARS + Gherkin
Fuente: ingeniería de reversa sobre `/mnt/pruebamotorsocial/lib/motorsocial`

---

## 1. Visión general del sistema

- Tipo: App Flutter con gestión de estado Riverpod.
- Alcance por módulos: `identity`, `activity`, `catalog`, `media`, `social_graph`, `design`, `navigation`, `resilience`, `security`, `location`, `core`.
- Datos: interfaces de repositorio con implementaciones in-memory/stub y conexión dual preparada para CouchDB y Qdrant.

---

## 2. Convención EARS usada

FORMATO: **Event-driven / State-driven / Unwanted**

---

## 3. Requerimientos funcionales

### RF-IDENTITY-001 — Inicio de sesión
**Given:** el usuario accede a la pantalla de inicio de sesión.
**When:** ingresa un correo y una contraseña válidos.
**Then:** el sistema ejecuta `signIn(...)`, expone el nuevo estado de identidad y navega a la pantalla principal.

Evidencia: `identity/pages/login_page.dart`, `identity/repositories/auth_repository.dart`.

---

### RF-IDENTITY-002 — Registro de cuenta
**Given:** el usuario está en la pantalla de registro.
**When:** completa `email`, `password` y `displayName`.
**Then:** el sistema ejecuta `register(...)` y deriva al flujo post-registro.

Evidencia: `identity/pages/register_page.dart`.

---

### RF-IDENTITY-003 — Recuperación de contraseña
**Given:** el usuario está en la pantalla de recuperación de cuenta.
**When:** envía su correo electrónico asociado.
**Then:** el sistema invoca `recoverPassword(email)` y confirma la solicitud en UI.

Evidencia: `identity/pages/password_recovery_page.dart`.

---

### RF-IDENTITY-004 — Sesión local
**Given:** el dispositivo tiene una sesión almacenada.
**When:** la app inicia.
**Then:** el sistema restaura `AuthState` sin requerir login nuevamente.

Evidencia: `identity/repositories/local_session_repository.dart`, `identity/repositories/session_repository.dart`.

---

### RF-NAV-001 — Rutas públicas/protegidas
**Given:** existe una ruta de acceso público definida en `AppRouter`.
**When:** el usuario intenta acceder a `login`.
**Then:** el sistema permite el acceso sin verificación.

### RF-NAV-002 — Restricción de acceso autenticado
**Given:** la app protege rutas distintas de `login`.
**When:** el usuario no posee sesión válida.
**Then:** la app redirige a login y bloquea la ruta solicitada.

Evidencia: `navigation/routing/route_guard.dart`, `navigation/routing/app_router.dart`.

---

### RF-NAV-003 — Scaffold social
**Given:** la pantalla principal carga con elementos de navegación.
**When:** el usuario toca una pestaña/ítem.
**Then:** el sistema actualiza el índice activo y navega por `route`.

Evidencia: `navigation/shell/social_scaffold.dart`, `navigation/providers/tab_menu_notifier.dart`.

---

### RF-ACTIVITY-001 — Feed de actividades
**Given:** existe una consulta de feed con parámetros válidos.
**When:** el usuario abre el feed.
**Then:** el sistema consulta `recentFeed(query)` y presenta actividades ordenadas por `createdAt`.

Evidencia: `activity/pages/activity_feed_page.dart`, `activity/providers/feed_notifier.dart`, `activity/repositories/in_memory_activities_repository.dart`.

---

### RF-ACTIVITY-002 — Detalle por actividad
**Given:** el usuario selecciona una actividad con `id`.
**When:** el sistema busca el detalle.
**Then:** el sistema retorna `SocialActivity` por `getById(id)`.

Evidencia: `activity/repositories/in_memory_activities_repository.dart`.

---

### RF-ACTIVITY-003 — Conversación
**Given:** el usuario abre una conversación asociada a una actividad.
**When:** se carga la pantalla y ejecuta acciones de conversación.
**Then:** debe existir un estado de conversación navegable con habilitadores de verbos.

Evidencia: `activity/pages/conversation_page.dart`, `activity/providers/conversation_notifier.dart`.

---

### RF-ACTIVITY-004 — Creación de actividad
**Given:** el usuario envía nueva actividad.
**When:** se completa `verb`, `objectType`, `objectId` y `actorId`.
**Then:** el sistema persiste mediante `create(activity)` y refleja el resultado en feed.

Evidencia: `activity/repositories/in_memory_activities_repository.dart`.

---

### RF-CATALOG-001 — Búsqueda de objetos sociales
**Given:** el usuario ingresa una query en catálogo.
**When:** ejecuta búsqueda.
**Then:** el sistema retorna hasta `limit` resultados con `search(query, limit)`.

Evidencia: `catalog/repositories/catalog_repository.dart`, `catalog/pages/catalog_list_page.dart`.

---

### RF-CATALOG-002 — Detalle de objeto
**Given:** el usuario selecciona un objeto por `id`.
**When:** abre detalle.
**Then:** el sistema expone el objeto completo y estados de detalle.

Evidencia: `catalog/providers/object_detail_notifier.dart`, `catalog/data_models/social_object.dart`.

---

### RF-CATALOG-003 — Exportación
**Given:** el usuario accede a exportar objeto.
**When:** selecciona formato de exportación.
**Then:** el sistema habilita exportación vía `export_notifier`.

Evidencia: `catalog/providers/export_notifier.dart`.

---

### RF-MEDIA-001 — Biblioteca de medios
**Given:** el usuario accede a la biblioteca.
**When:** consulta medios por propietario.
**Then:** el sistema entrega `byOwner(ownerId)` y renderiza `mediaIds`.

Evidencia: `media/repositories/media_repository.dart`, `media/providers/media_library_notifier.dart`, `media/pages/media_library_page.dart`.

---

### RF-MEDIA-002 — Subida/creación de asset
**Given:** el usuario envía un asset con metadatos válidos.
**When:** ejecuta upload.
**Then:** el sistema aplica `upload(asset)` y retorna el asset persistido.

Evidencia: `media/data_models/social_media_asset.dart`.

---

### RF-MEDIA-003 — Presentación multimedia
**Given:** existe una secuencia con IDs de asset.
**When:** el usuario abre slideshow.
**Then:** el sistema presenta vistas deslizantes por asset.

Evidencia: `media/pages/media_slideshow_page.dart`, `media/widgets/media_slider.dart`.

---

### RF-MEDIA-004 — Selector de media
**Given:** el usuario selecciona activos multimedia.
**When:** abre el selector.
**Then:** el sistema habilita selección de assets disponibles.

Evidencia: `media/pages/media_selector_page.dart`, `media/pages/media_asset_builder.dart`.

---

### RF-SOCIAL-001 — Relaciones sociales
**Given:** el usuario consulta relaciones por `actorId` o `otherId`.
**When:** ejecuta búsqueda.
**Then:** el sistema retorna `SocialRelationship` con filtro opcional por estado.

Evidencia: `social_graph/repositories/relationships_repository.dart`, `social_graph/data_models/social_relationship.dart`.

---

### RF-SOCIAL-002 — Grupos
**Given:** el usuario explora grupos.
**When:** consulta `discoverable(visibility, joinable)`.
**Then:** el sistema retorna `SocialGroup` filtrados.

Evidencia: `social_graph/repositories/groups_repository.dart`, `social_graph/pages/group_pages.dart`.

---

### RF-SOCIAL-003 — Invitaciones pendientes
**Given:** un usuario es receptor.
**When:** consulta invitaciones pendientes.
**Then:** el sistema retorna `SocialInvitation` en estado `pending`.

Evidencia: `social_graph/repositories/invitations_repository.dart`, `social_graph/data_models/invitation.dart`.

---

### RF-SOCIAL-004 — Contactos y navegación social
**Given:** el usuario abre contactos/grupos/invitaciones.
**When:** navega por tabs del dominio.
**Then:** el sistema muestra vistas separadas, con navegación local y feedback por empty states.

Evidencia: `social_graph/pages/contacts_page.dart`, `social_graph/pages/group_pages.dart`, `social_graph/widgets/social_tiles.dart`.

---

### RF-THEME-001 — Configuración de tema
**Given:** el usuario abre configuración de tema.
**When:** cambia tokens visuales.
**Then:** el sistema guarda `ThemeTokenSet` y aplica actualizaciones en UI.

Evidencia: `design/pages/theme_settings_page.dart`, `design/repositories/theme_repository.dart`, `design/tokens/social_theme_data.dart`.

---

### RF-DESIGN-001 — Modo adaptativo
**Given:** la app renderiza pantallas en dispositivo adaptable.
**When:** cambia tamaño/tipo de pantalla.
**Then:** el sistema preserva contenido y reacomoda layout.

Evidencia: `design/widgets/adaptive_layout.dart`, `design/providers/theme_notifier.dart`.

---

### RF-RES-001 — Alerta de conectividad
**Given:** el usuario pierde conexión.
**When:** se detecta cambio de red.
**Then:** el sistema actualiza `ConnectionStatus` y expone estado reactivo.

Evidencia: `resilience/providers/connection_notifier.dart`, `resilience/repositories/connectivity_repository.dart`.

---

### RF-RES-002 — Sincronización offline
**Given:** el usuario vuelve del estado offline.
**When:** la sincronización se habilita.
**Then:** el sistema expone `Syn` y procesa acciones pendientes.

Evidencia: `resilience/repositories/sync_repository.dart`, `resilience/providers/sync_notifier.dart`.

---

### RF-SEC-001 — Registro de eventos de seguridad
**Given:** ocurre un evento relevante de seguridad.
**When:** se captura `deviceInfo` o evento de rate limit.
**Then:** el sistema almacena `SecurityEvent` y permite consulta por usuario/rango.

Evidencia: `security/repositories/security_repository.dart`, `security/data_models/security_event.dart`.

---

### RF-SEC-002 — Rate limit
**Given:** un actor alcanza umbral configurado.
**When:** sobrepasa límites.
**Then:** el sistema expone `RateLimitState` y aplica bloqueo temporal.

Evidencia: `security/data_models/rate_limit_state.dart`, `security/providers/security_notifier.dart`.

---

### RF-LOC-001 — Selección de localidad
**Given:** el usuario requiere establecer ubicación.
**When:** abre selector.
**Then:** el sistema resuelve localidad a partir de código postal y/o GPS.

Evidencia: `location/pages/locality_picker_page.dart`, `location/repositories/postal_code_repository.dart`, `location/repositories/geolocation_repository.dart`.

---

### RF-LOC-002 — Motor de ubicación
**Given:** existen datos de ubicación válidos.
**When:** se inicializa `LocationEngine`.
**Then:** el sistema expone proveedor/estado listo para consumo.

Evidencia: `location/engine/location_engine.dart`, `location/providers/location_notifier.dart`.

---

### RF-CORE-001 — Configuración inicial
**Given:** la app se inicia sin config previa cargada en sesión.
**When:** ejecuta `SocialAppConfig.defaults()`.
**Then:** se provee `CouchDbConfig`, `QdrantConfig` y parámetros base para ejecución offline/online.

Evidencia: `core/config/social_app_config.dart`, `lib/main.dart`.

---

### RF-CORE-002 — Base de datos preparada
**Given:** datos requieren persistencia real.
**When:** se cambia wiring por implementación concreta de repositorio.
**Then:** el sistema provee acceso a CouchDB y/o Qdrant.

Evidencia: `core/database/couchdb_repository.dart`, `core/database/qdrant_repository.dart`.

---

## 4. Reglas de negocio

| ID | Regla | Evidencia |
|---|---|---|
| RN-001 | El feed ordena actividades por `createdAt` descendente. | `activity/repositories/in_memory_activities_repository.dart` |
| RN-002 | Invitaciones inician con estado `pending` por defecto. | `social_graph/data_models/invitation.dart` |
| RN-003 | `login` es ruta pública y gateway de acceso al resto. | `navigation/routing/route_guard.dart` |
| RN-004 | La app expone tema claro/oscuro con semilla Material3. | `lib/main.dart` |
| RN-005 | Proveedores exponen estado reactivo por feature con providers. | múltiples `providers/*notifier.dart` |
| RN-006 | Toda API nueva debe mantener impl in-memory por defecto. | skill `motorsocial-dart-repository-patterns` |
| RN-007 | Los assets tienen `ownerId` y soportan upload/biblioteca. | `media/data_models/social_media_asset.dart`, `media/repositories/media_repository.dart` |

---

## 5. Reglas de sistema

- `development`/`staging`: repos in-memory activos.
- Producción: reemplazo por `CouchDbRepository` y `QdrantRepository`.
- `RouteGuard.canAccess`: proteger todas las rutas excepto login.
- Toda página acepta `SocialAppConfig` desde `ProviderScope` y `Provider` overrides en `main.dart`.

---

## 6. Requerimientos no funcionales

| ID | Criterio | Evidencia de diseño |
|---|---|---|
| RNF-001 | Inicialización sin estado redundante. | `main.dart` con `ProviderScope` y default providers. |
| RNF-002 | UI reactiva por dominio. | Providers por feature en `activity`, `catalog`, `media`, etc. |
| RNF-003 | Adaptabilidad visual. | `adaptive_layout.dart` y `ThemeData` desde seed. |
| RNF-004 | Trabajo offline con sync preparada. | `resilience` y `sync_repository`. |
| RNF-005 | Seguridad observable. | `security` events, device info, rate-limit model. |
| RNF-006 | Routing cerrado + scaffold mínimo. | `app_router.dart`, `social_scaffold.dart`, `route_guard.dart`. |

---

## 7. Matriz de trazabilidad feature → evidencia primaria

| Feature | Contrato | Páginas | Providers | Repo | Modelos |
|---|---|---|---|---|---|
| activity | `activity_contract.dart` | `activity_feed_page.dart`, `conversation_page.dart` | `feed_notifier.dart`, `conversation_notifier.dart` | `activity_repository.dart`, `in_memory_activities_repository.dart` | `SocialActivity`, `ActivityQuery` |
| catalog | `catalog_contract.dart` | `catalog_list_page.dart` | `catalog_notifier.dart`, `object_detail_notifier.dart` | `catalog_repository.dart` | `SocialObject`, `SocialObjectQuery` |
| core | `social_app_config.dart` | — | `app_providers.dart` | `couchdb_repository.dart`, `qdrant_repository.dart` | `CouchDbConfig`, `QdrantConfig` |
| design | `theme_state.dart` | `theme_settings_page.dart` | `theme_notifier.dart` | `theme_repository.dart` | `ThemeTokenSet`, `SocialThemeData` |
| identity | `social_identity_contract.dart`, `identity_models.dart` | `login_page.dart`, `register_page.dart`, `password_recovery_page.dart` | `auth_notifier.dart`, `session_notifier.dart` | `auth_repository.dart`, `local_session_repository.dart`, `session_repository.dart`, `users_repository.dart` | `AuthState`, `SessionData`, `SocialUser`, `RoleProfile` |
| location | `location_contract.dart` | `locality_picker_page.dart` | `location_notifier.dart` | `geolocation_repository.dart`, `postal_code_repository.dart` | `LocationState` |
| media | `media_contract.dart`, `social_media_asset.dart` | `media_library_page.dart`, `media_selector_page.dart`, `media_asset_builder.dart`, `media_slideshow_page.dart` | `media_library_notifier.dart`, `album_order_notifier.dart` | `media_repository.dart` | `SocialMediaAsset` |
| navigation | `navigation_contract.dart`, `menu_item.dart` | — | `tab_menu_notifier.dart` | — | `SocialMenuItem`, `TabMenuState` |
| resilience | `connection_status.dart`, `resilience` contract local | — | `connection_notifier.dart`, `platform_notifier.dart`, `sync_notifier.dart` | `connectivity_repository.dart`, `platform_repository.dart`, `sync_repository.dart` | `InMemorySyncRepository` state |
| security | `security_event.dart` | — | `security_notifier.dart` | `security_repository.dart` | `SecurityEvent`, `RateLimitState`, `DeviceInfo` |
| social_graph | `social_invitation.dart`, `social_group.dart`, `social_relationship.dart` | `contacts_page.dart`, `group_pages.dart`, `invitations_page.dart` | `group_notifier.dart`, `invitation_notifier.dart`, `social_query.dart` | `groups_repository.dart`, `invitations_repository.dart`, `relationships_repository.dart`, `social_graph_repository.dart` | `SocialGroup`, `Invitation`, `SocialRelationship` |

---

## 8. Supuestos para trazabilidad futura

1. Existen stubs placeholders en páginas/widgets que representan contratos pendientes de wiring real.
2. `ActivityContract` actual no modela `enabledVerbs` en `ActivityQuery`; habrá extenderlo a versión productiva.
3. El término `ActivityContract` detectado en documento previo se interpreta como conjunto de contratos por dominio, no como único documento monolítico.

---

## 9. Verificación sin modificar código
- Archivo generado: `/mnt/pruebamotorsocial/_documentacion/ears_gherkin_system_requirements.md`.
- No se tocó código fuente.
- Se preservó ruta exacta dentro del directorio `_documentacion`.
