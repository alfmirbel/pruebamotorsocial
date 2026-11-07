# AGENTS.md — pruebamotorsocial (PrestaVecino)

Thin client of the MotorSocial engine (`../motorsocial`). Product: **PrestaVecino** (neighbour item lending). This is a staging/test app: never expose sensitive data.

## Rules

1. **Never copy engine code here.** Configure it (`assets/config/prestavecino.json`), override providers (`lib/prestavecino/app.dart`) or add routes (`PrestaVecino.routes`). If something requires changing or copying the engine, it is an engine gap: record it as a ⬜ requirement in the engine's module sheet (`../motorsocial/_documentacion/04_arquitectura_y_diseno/modulos/`).
2. The only vertical business rule is the loan state (`lib/prestavecino/prestamo.dart`).
3. Import the engine only through `package:motorsocial/motorsocial.dart`.
4. Seed data lives in `assets/seed/` and is shared by seed mode (in-memory) and the integrated mode (`../motorsocial/tool/couchdb/seed.dart --fixtures`). Keep IDs stable: tests assert on them.
5. Every journey J-01…J-12 is a widget test in `test/journeys/` (seed mode). Keep them green.
6. `defines.json` is git-ignored and must never be committed (it holds admin credentials used only by the engine's `tool/couchdb/`).
7. UI rules: same as the engine (`../motorsocial/AGENTS.md`): no inline colours, icons only via `SocialIcons`, M3 widgets, `if (!mounted) return;` after every `await` in `State` code.

## Commands

```powershell
flutter pub get
flutter analyze
dart format --set-exit-if-changed lib test integration_test
flutter test
flutter run -d windows [--dart-define=PV_MODO=integrado]
```
