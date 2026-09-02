# Modelos de datos por feature
Fuente: ingeniería de reversa sobre `/mnt/pruebamotorsocial/lib/motorsocial`

---

## 1. `identity`

### `SocialUser`
- `id`: String
- `displayName`: String
- `photoUrl`: String
- **Propósito:** representación mínima de usuario para UI y listados.

Evidencia: `identity/data_models/social_user.dart`.

---

### `SessionData`
- `key`: String
- `token`: String
- `expiresAt`: DateTime
- `payload`: Map<String, dynamic>
- **Propósito:** sesión persistida localmente para restaurar autenticación sin re-login.

Evidencia: `identity/data_models/session_data.dart`.

---

### `AuthState`
- `isUserDataLoaded`: bool
- `errorCode`: String?
- `errorMessage`: String?
- `isAuthenticated`: bool
- `userId`: String?
- `accessToken`: String?
- **Propósito:** estado global expuesto por proveedor de autenticación.

Evidencia: `identity/data_models/auth_state.dart`.

---

### `RoleProfile`
- `key`: String
- `name`: String
- `permissions`: List<String>
- **Propósito:** perfil de rol y control de acceso expresable desde config/auth.

Evidencia: `identity/data_models/role_profile.dart`.

---

## 2. `activity`

### `ActivityQuery`
- `actorId`: String?
- `limit`: int, default 20
- **Propósito:** parámetro de consulta para feed o listado de actividades.

Evidencia: `activity/data_models/activity_contract.dart`.

---

### `SocialActivity`
- `id`: String
- `actorId`: String
- `actorName`: String
- `verb`: String
- `objectType`: String
- `objectId`: String
- `payload`: Map<String, dynamic>
- `createdAt`: int
- **Propósito:** evento de actividad con actor, acción, objeto y contexto adicional.

Evidencia: `activity/data_models/activity_contract.dart`.

---

## 3. `catalog`

### `SocialObject`
- `id`: String
- `type`: String
- `title`: String?
- `attributes`: Map<String, dynamic>
- `ownerId`: String?
- `createdAt`: DateTime
- `updatedAt`: DateTime
- **Propósito:** entidad genérica del catálogo con metadatos dinámicos por tipo.

Evidencia: `catalog/data_models/social_object.dart`.

---

### `SocialObjectPage`
- `items`: List<SocialObject>
- `total`: int
- `offset`: int
- `hasMore`: bool
- **Propósito:** respuesta paginada de búsqueda/listado.

Evidencia: `catalog/data_models/social_object.dart`.

---

### `SocialObjectQuery`
- `preferredType`: String?
- `skip`: int, default 0
- `limit`: int, default 20
- `filter`: Map<String, dynamic>
- `sort`: List<String>
- **Propósito:** criterios de búsqueda y paginación.

Evidencia: `catalog/data_models/catalog_query.dart`.

---

### `CatalogContract`
- `providerName`: String
- `supportedTypes`: List<String>
- `defaultPageSize`: int
- `enableSearch`: bool
- `enablePdfExport`: bool
- `primaryCtaLabel`: String
- **Propósito:** contrato de configuración por proveedor de catálogo.

Evidencia: `catalog/data_models/catalog_contract.dart`.

---

## 4. `media`

### `SocialMediaAsset`
- `id`: String
- `ownerId`: String
- `assetType`: String
- `url`: String
- `createdAt`: DateTime
- **Propósito:** asset multimedia asociado a un propietario y listo para biblioteca/selector.

Evidencia: `media/data_models/social_media_asset.dart`.

---

## 5. `social_graph`

### `SocialRelationship`
- `id`: String
- `actorId`: String
- `targetId`: String
- `type`: String, default `contact`
- `createdAt`: DateTime
- **Propósito:** relación dirigida entre actores del sistema.

Evidencia: `social_graph/data_models/social_relationship.dart`.

---

### `SocialGroup`
- `id`: String
- `name`: String
- `memberIds`: List<String>, default []
- `isPublic`: bool, default true
- **Propósito:** grupo social con membresía y visibilidad.

Evidencia: `social_graph/data_models/social_group.dart`.

---

### `SocialInvitation`
- `id`: String
- `senderId`: String
- `receiverId`: String
- `status`: String
- `createdAt`: DateTime
- **Propósito:** invitación pendiente entre usuarios.

Evidencia: `social_graph/data_models/social_invitation.dart`.

---

## 6. `location`

### `LocationContract`
- `enableGeolocation`: bool, default true
- `enablePostalCode`: bool, default true
- `defaultLocalityLimit`: int, default 20
- **Propósito:** feature flags y límites por defecto del módulo.

Evidencia: `location/data_models/location_contract.dart`.

---

### `SocialPlace`
- `id`: String
- `name`: String
- `latitude`: double?
- `longitude`: double?
- `postalCode`: String?
- **Propósito:** lugar/localidad con coordenadas opcionales y código postal.

Evidencia: `location/data_models/location_contract.dart`.

---

### `PostalCodeLookupResult`
- `postalCode`: String
- `localities`: List<LocalityEntry>
- **Propósito:** resultado de búsqueda por código postal.

Evidencia: `location/data_models/location_contract.dart`.

---

### `LocalityEntry`
- `name`: String
- `state`: String
- `country`: String
- **Propósito:** entrada mínima de localidad dentro de lookup postal.

Evidencia: `location/data_models/location_contract.dart`.

---

## 7. `design`

### `DesignToken`
- `key`: String
- `category`: String
- `value`: String
- **Propósito:** token visual configurable por categoría.

Evidencia: `design/data_models/design_token.dart`.

---

### `ThemeState`
- `themeId`: String, default `light_default`
- `isLoading`: bool
- `error`: String?
- **Propósito:** estado del selector/configurador de tema.

Evidencia: `design/data_models/theme_state.dart`.

---

## 8. `navigation`

### `SocialMenuItem`
- `title`: String
- `route`: String
- `enabled`: bool, default true
- **Propósito:** item de navegación para tabs, drawer o bottom bar.

Evidencia: `navigation/data_models/menu_item.dart`.

---

## 9. `resilience`

### `ConnectionStatus`
- `isOnline`: bool
- `connectivityType`: String?
- **Propósito:** estado observable de red.

Evidencia: `resilience/data_models/connection_status.dart`.

---

### `SyncState`
- `isSyncing`: bool
- `lastSyncedAt`: DateTime?
- `error`: String?
- **Propósito:** estado del proceso de sincronización offline/online.

Evidencia: `resilience/data_models/connection_status.dart`.

---

## 10. `security`

### `SecurityEvent`
- `id`: String
- `type`: String
- `actorId`: String?
- `payload`: Map<String, dynamic>
- `createdAt`: DateTime
- **Propósito:** evento de seguridad trazable por usuario/tipo.

Evidencia: `security/data_models/security_event.dart`.

---

### `RateLimitState`
- `remaining`: int
- `resetAt`: DateTime?
- **Propósito:** control de umbral de peticiones por actor.

Evidencia: `security/data_models/rate_limit_state.dart`.

---

### `DeviceInfo`
- `id`: String
- `model`: String?
- `osVersion`: String?
- **Propósito:** metadatos básicos del dispositivo para eventos de seguridad.

Evidencia: `security/data_models/device_info.dart`.
