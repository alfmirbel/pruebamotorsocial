# Guía de Implementación — Capa de Datos MotorSocial

Arquitectura de persistencia para `../pruebamotorsocial` y preparación para producción en `../motorsocial`.

## 1. Motores y roles

| Motor            | Uso principal                                                                  | Por qué                                                        |
| ---------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| CouchDB          | Usuarios, relaciones, grupos, actividades, objetos, media, eventos, sync_state | Documental, replicación, consultas Map-Reduce por IDs y rangos |
| Qdrant           | Búsqueda semántica de perfiles, objetos sociales y atributos libres            | Embeddings, filtrado semántico y vectorial                     |
| Redis (opcional) | Cache de relaciones/grupos, rate-limit, colas de eventos                       | Bajo latency, expiración natural                               |

## 2. Bases de datos en CouchDB

### 2.1 Nomenclatura

Prefijo `motorsocial_` para evitar colisiones. Una base por dominio cuando:

- vida útil/acceso difiere,
- Document IDs pueden repetirse,
- Queremos controlar permisos por dominio.

### 2.2 Bases recomendadas

- `motorsocial_users`
- `motorsocial_relationships`
- `motorsocial_groups`
- `motorsocial_group_members`
- `motorsocial_invitations`
- `motorsocial_activities`
- `motorsocial_objects`
- `motorsocial_media`
- `motorsocial_security_events`
- `motorsocial_sync_state`

### 2.3 Reglas generales de documento

- Usar `_id` autogenerado o un ID estable del dominio (`userId`, `relationshipId`, etc.).
- Mantener `createdAt` en epoch ms para rangos.
- Usar `metadata` para campos opcionales sin alterar el esquema base.
- No mezclar legado de Buscobien: normalizar nombres al modelado actual.

## 3. Vistas e índices por base

### 3.1 motorsocial_users

Design doc: `_design/users`

Vistas:

- `by_email`:
  - map: `function (doc) { if (doc.value && doc.value.email) emit(doc.value.email.toLowerCase(), {id: doc._id, rev: doc._rev, displayName: doc.value.displayName}); }`
- `by_createdAt`:
  - map: `function (doc) { if (doc.value && doc.value.createdAt) emit(doc.value.createdAt, doc._id); }`

Consultas asociadas:

- Obtener usuario por email.
- Usuarios creados en un rango de fechas.

### 3.2 motorsocial_relationships

Design doc: `_design/relationships`

Vistas:

- `by_actor_status`:
  - map: `function (doc) { if (doc.actorId) emit([doc.actorId, doc.status], {id: doc._id, otherId: doc.otherId, direction: doc.direction, createdAt: doc.createdAt}); }`
- `by_other_status`:
  - map: `function (doc) { if (doc.otherId) emit([doc.otherId, doc.status], {id: doc._id, actorId: doc.actorId, direction: doc.direction, createdAt: doc.createdAt}); }`
- `by_direction_createdAt`:
  - map: `function (doc) { if (doc.direction) emit([doc.actorId, doc.direction, doc.createdAt], doc._id); }`

Consultas asociadas:

- Contactos/relaciones por `actorId` y `status`.
- Relaciones entrantes/salientes.
- Relaciones por rango de fecha.

### 3.3 motorsocial_groups

Design doc: `_design/groups`

Vistas:

- `by_owner`:
  - map: `function (doc) { if (doc.ownerId) emit(doc.ownerId, {id: doc._id, name: doc.name, visibility: doc.visibility, joinable: doc.joinable}); }`
- `by_visibility_joinable`:
  - map: `function (doc) { emit([doc.visibility || 'public', String(doc.joinable)], doc._id); }`
- `by_createdAt`:
  - map: `function (doc) { if (doc.createdAt) emit(doc.createdAt, doc._id); }`

Consultas asociadas:

- Grupos de un usuario por `ownerId`.
- Grupos públicos y abiertos a unión.
- Grupos por fecha de creación.

### 3.4 motorsocial_group_members

Design doc: `_design/group_members`

Vistas:

- `by_group_user`:
  - map: `function (doc) { if (doc.groupId && doc.userId) emit([doc.groupId, doc.userId], {role: doc.role, joinedAt: doc.joinedAt}); }`
- `by_user`:
  - map: `function (doc) { if (doc.userId) emit(doc.userId, {groupId: doc.groupId, role: doc.role, joinedAt: doc.joinedAt}); }`
- `by_group_role`:
  - map: `function (doc) { if (doc.groupId) emit([doc.groupId, doc.role], doc.userId); }`

Consultas asociadas:

- Miembros de un grupo.
- Grupos a los que pertenece un usuario.
- Roles por grupo.

### 3.5 motorsocial_invitations

Design doc: `_design/invitations`

Vistas:

- `by_receiver_status`:
  - map: `function (doc) { if (doc.receiverId) emit([doc.receiverId, doc.status], {id: doc._id, senderId: doc.senderId, type: doc.type, objectId: doc.objectId, createdAt: doc.createdAt}); }`
- `by_sender`:
  - map: `function (doc) { if (doc.senderId) emit([doc.senderId, doc.createdAt], {id: doc._id, status: doc.status, type: doc.type}); }`
- `by_object`:
  - map: `function (doc) { if (doc.objectId) emit([doc.objectId, doc.createdAt], doc._id); }`

Consultas asociadas:

- Invitaciones pendientes por `receiverId`.
- Historial de invitaciones enviadas.
- Invitaciones asociadas a un objeto.

### 3.6 motorsocial_activities

Design doc: `_design/activities`

Vistas:

- `by_actor_createdAt`:
  - map: `function (doc) { if (doc.actorId) emit([doc.actorId, doc.createdAt], {id: doc._id, verb: doc.verb, objectType: doc.objectType, objectId: doc.objectId, targetId: doc.targetId}); }`
- `by_verb_createdAt`:
  - map: `function (doc) { if (doc.verb) emit([doc.verb, doc.createdAt], {id: doc._id, actorId: doc.actorId, objectType: doc.objectType}); }`
- `by_object_createdAt`:
  - map: `function (doc) { if (doc.objectId) emit([doc.objectType, doc.objectId, doc.createdAt], doc._id); }`
- `by_target_createdAt`:
  - map: `function (doc) { if (doc.targetId) emit([doc.targetId, doc.createdAt], {id: doc._id, verb: doc.verb, actorId: doc.actorId}); }`

Consultas asociadas:

- Feed de actividades de un actor/grupo.
- Actividades por `verb` y rango de fecha.
- Actividades sobre un objeto social.

Nota: considera un TTL por `expiresAt` y/o proceso de limpieza.

### 3.7 motorsocial_objects

Design doc: `_design/objects`

Vistas:

- `by_creator_type_status`:
  - map: `function (doc) { emit([doc.creatorId, doc.type, doc.status], {id: doc._id, attributes: doc.attributes, labels: doc.labels, location: doc.location, mediaIds: doc.mediaIds, createdAt: doc.createdAt}); }`
- `by_type_status_createdAt`:
  - map: `function (doc) { emit([doc.type, doc.status, doc.createdAt], {id: doc._id, creatorId: doc.creatorId}); }`
- `by_labels`:
  - map: `function (doc) { if (doc.labels) for (let k in doc.labels) emit([k, doc.labels[k]], doc._id); }`
- `by_location`:
  - map: `function (doc) { if (doc.location) emit([doc.location.country, doc.location.city, doc.createdAt], doc._id); }`

Consultas asociadas:

- Objetos por creador, tipo y estado.
- Búsqueda por atributos semánticos (se complementa con Qdrant).

### 3.8 motorsocial_media

Design doc: `_design/media`

Vistas:

- `by_owner_createdAt`:
  - map: `function (doc) { if (doc.ownerId) emit([doc.ownerId, doc.createdAt], doc._id); }`
- `by_asset_type`:
  - map: `function (doc) { if (doc.assetType) emit(doc.assetType, doc._id); }`

Consultas asociadas:

- Biblioteca de media por propietario.
- Media por tipo.

### 3.9 motorsocial_security_events

Design doc: `_design/security_events`

Vistas:

- `by_user_createdAt`:
  - map: `function (doc) { if (doc.userId) emit([doc.userId, doc.createdAt], {id: doc._id, eventType: doc.eventType}); }`
- `by_type_createdAt`:
  - map: `function (doc) { emit([doc.eventType, doc.createdAt], doc._id); }`

Consultas asociadas:

- Eventos por usuario y rango.
- Eventos por tipo.

### 3.10 motorsocial_sync_state

Design doc: `_design/sync_state`

Vistas:

- `by_platform_lastSync`:
  - map: `function (doc) { if (doc.platform) emit([doc.platform, doc.lastSyncAt], {id: doc._id, status: doc.status}); }`

Consultas asociadas:

- Estado por plataforma.

## 4. Qdrant — colecciones recomendadas

### 4.1 Colecciones

- `motorsocial_users`: embeddings de `displayName`, `bio` y etiquetas de perfil.
- `motorsocial_objects`: embeddings de `attributes`, `labels`, `description` (si aplica).
- `motorsocial_activities`: embeddings de `verb` + `payload` para búsqueda semántica del feed.

### 4.2 Estructura mínima por punto

- ID: igual al ID CouchDB del documento, cuando sea posible, para joining.
- Vector: embeddings generados desde atributos semánticos relevantes.
- Payload: `creatorId`, `type`, `status`, `visibility`, `location`, `labels`, `createdAt`.

### 4.3 Índices/filtrado

- Usar índices de payload Qdrant para `creatorId`, `type`, `status`, `labels.*`, `location.country`, `location.city`.
- Recuperación típica: filtrar por `type/status/creatorId`, rankear por similitud de vector, paginar top-K.

## 5. Queries habituales y mapeo a motor

### 5.1 Feed de actividades

- Entrada: `actorId`, `verb?`, `since`, `until`, `limit`, `offset`.
- CouchDB: vista `by_actor_createdAt` o `by_verb_createdAt` con `startkey/endkey`.
- Mejora: cachear períodos calientes en Redis por usuario/grupo.

### 5.2 Relaciones sociales

- Entrada: `actorId`, `status`, `direction?`.
- CouchDB: vista `by_actor_status` o `by_other_status`.
- Cache: claves `relationships:{actorId}` en Redis con TTL corto.

### 5.3 Grupos y miembros

- Entrada: `ownerId`, `visibility`, `joinable?`.
- CouchDB: vistas `by_owner`, `by_visibility_joinable`, `by_user`.
- Consulta de miembros: `by_user` para listar pertenencias, `by_group_user` para detalle.

### 5.4 Invitaciones

- Entrada: `receiverId`, `status=pending`.
- CouchDB: vista `by_receiver_status` con `key=[receiverId, 'pending']`.

### 5.5 Búsqueda de objetos sociales

- Entrada: `type`, `status`, `creatorId?`, `query semántica?`.
- CouchDB: `by_type_status_createdAt` para filtrado exacto.
- Qdrant: filtrado vectorial por semántica, filtrar por `creatorId/type/status/labels/location`.

### 5.6 Biblioteca de media

- Entrada: `ownerId`, rango `createdAt`.
- CouchDB: vista `by_owner_createdAt`.

## 6. Implementación en Dart para pruebas

### 6.1 Estructura sugerida

- `lib/core/database/database_module.dart`: wiring de repos.
- `lib/core/database/couchdb/`: cliente HTTP mínimo, generación de design docs, helpers de query.
- `lib/core/database/qdrant/`: cliente HTTP/gRPC, upsert/delete por ID, búsqueda filtrada.
- `lib/core/database/repositories/`: interfaces por dominio (`users`, `relationships`, `groups`, `activities`, `objects`, `media`, `invitations`, `security_events`, `sync_state`).
- `lib/core/database/migrations/`: scripts JSON/YAML por dominio.

### 6.2 Contratos de repositorio

```dart
abstract class UsersRepository {
  Future<SocialUser?> findByEmail(String email);
  Future<void> save(SocialUser user);
}

abstract class RelationshipsRepository {
  Future<List<SocialRelationship>> byActor(String actorId, {String? status});
  Future<List<SocialRelationship>> byOther(String otherId, {String? status});
}

abstract class GroupsRepository {
  Future<List<SocialGroup>> discoverable({String? visibility, bool? joinable});
}

abstract class GroupMembersRepository {
  Future<List<GroupMember>> byGroup(String groupId);
  Future<void> add(GroupMember member);
}

abstract class InvitationsRepository {
  Future<List<Invitation>> pendingFor(String receiverId);
}

abstract class ActivitiesRepository {
  Future<List<SocialActivity>> recentFeed(ActivityQuery query);
}

abstract class ObjectsRepository {
  Future<List<SocialObject>> search(SocialObjectQuery query);
}

abstract class MediaRepository {
  Future<List<SocialMediaAsset>> byOwner(String ownerId, {int? since});
}
```

### 6.3 Migraciones iniciales

- Aplicar design docs desde JSON versionado.
- Validar existencia de vistas y crear diseño base antes de escribir.
- En pruebas, limpiar DBs/colecciones al reiniciar suite.

## 7. Validación y pruebas

### 7.1 Validaciones

- Schema JSON por documento base en `../pruebamotorsocial`.
- Tests de inserción/consulta por cada vista/índice.
- Prueba de búsqueda semántica con Qdrant embebido o mock.

### 7.2 Pruebas aisladas

- In-memory para dominio puro.
- CouchDB/Qdrant test containers o instancias locales para integración.
- Fixtures desde archivos JSON bajo `test/fixtures/db/`.

## 8. Checklist de entrega en `../pruebamotorsocial`

- [ ] Documento `docs/database-implementation-guide.md`.
- [ ] JSON de design docs: `lib/core/database/couchdb_design_docs.json`.
- [ ] JSON de colecciones Qdrant: `lib/core/database/qdrant_collections.json`.
- [ ] Interfaces de repositorios en `lib/core/database/repositories/`.
- [ ] Implementación inicial de `CouchDbRepository` y `QdrantRepository`.
- [ ] Tests de contratos y fixtures.

## 9. Próximo paso

Si querés, con esta guía genero ahora mismo:

1. `lib/core/database/repositories/...` interfaces.
2. `lib/core/database/couchdb_design_docs.json`.
3. `lib/core/database/qdrant_collections.json`.
4. Un `CouchDbRepository` mínimo funcional con client HTTP.
