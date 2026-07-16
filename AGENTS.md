# AGENTS.md — pruebamotorsocial

App Flutter de prueba para el **Motor de Red Social** `motorsocial`.
Repos: `../motorsocial` (motor) y `../pruebamotorsocial` (app prueba).

## Build & run

```bash
cd ../pruebamotorsocial
flutter analyze
flutter test
flutter run -d chrome
```

## Dependencias clave

- `motorsocial` via path `../motorsocial`
- `flutter_riverpod` para estado
- `connectivity_plus`, `shared_preferences`, `http`, `fpdart`

## Arquitectura actual

- `lib/main.dart`: carga `assets/contracts/motorsocial_contracts.json` y crea el bridge.
- `lib/core/app_shell.dart`: shell principal con `ProviderScope`, tema M3 y tabs por `IndexedStack`.
- `lib/core/motorsocial_bridge/bridge.dart`: adaptador del motor a la app prueba.
- `lib/core/database/database_module.dart`: implementaciones en memoria del motor para prueba.

## Workflow en Fase 3

- Modificar primero `pruebamotorsocial` para garantizar que el motor se compone correctamente.
- Las pruebas vivas de cada feature se harán aquí integrando contratos y providers.
- No mezclar secretos ni backends antiguos en este repo.

## Tests

```bash
flutter test
```

- Un test de humo mínimo en `test/widget_test.dart`.
- Se agregarán pruebas unitarias/de integración por feature en `../pruebamotorsocial/test/`.

## Notas

- Si tocás contratos JSON, mantener coherencia con `SocialAppConfig`.
- Esta app es de staging/prueba; no exponer datos sensibles.
- **Password**: (en .env como COUCHDB_PASSWORD — nunca en este archivo)
