# SDD — Feature: Database

## 1. Resumen

Define adaptadores de persistencia en memoria, HTTP contra CouchDB y Qdrant, módulo de Wiring y design docs.

## 2. Alcance

`../pruebamotorsocial/lib/core/database`.

## 3. Repositorios

Implementaciones in-memory para:

- `ActivitiesRepository`
- `GroupsRepository`
- `GroupMembersRepository`
- `InvitationsRepository`
- `MediaRepository`
- `ObjectsRepository`
- `RelationshipsRepository`
- `SecurityEventsRepository`
- `SyncStateRepository`
- `UsersRepository`

## 4. HTTP Data Stores

- `CouchDbRepository`: CRUD básico, ping, ensureDatabase, vistas `_design/motorsocial_guide`.
- `QdrantRepository`: upsert de puntos en colecciones.
- `CouchDbDesignDocs.json` define vistas `by_owner_createdAt` y `by_asset_type` para `domains`.
- `QdrantCollections.json` define colecciones `motorsocial_users`, `motorsocial_objects`, `motorsocial_activities` con payload indexes.

## 5. Módulo

- `DatabaseModule` expone repositorios in-memory como constantes.
- `InMemoryDatabaseModule` placeholder obsoleto sin uso.

## 6. Requisitos

| ID       | Requisito                                            | Evidencia                                             |
| -------- | ---------------------------------------------------- | ----------------------------------------------------- |
| RF-DB-01 | Soportar modo pruebas sin servicios externos.        | `InMemory*Repository` retornan listas vacías/default. |
| RF-DB-02 | Proveer cliente HTTP mínimo para document databases. | `CouchDbRepository`.                                  |
| RF-DB-03 | Proveer repo vectorial para embeddings.              | `QdrantRepository`.                                   |
| RF-DB-04 | Definir vistas e índices de colecciones.             | JSONs de design docs y collections.                   |
