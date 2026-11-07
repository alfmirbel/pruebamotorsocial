# PrestaVecino (`pruebamotorsocial`)

Red vecinal para prestar y pedir prestadas cosas que se usan poco. Es el **cliente de referencia de MotorSocial**: con él se prueban los 12 módulos del motor de extremo a extremo. Lo que es propio de la vertical (la regla del préstamo, la semilla y el panel de diagnóstico) cabe en unos pocos archivos. **No hay código copiado del motor.**

Caso de prueba completo: `../motorsocial/_documentacion/01_planeacion_y_estrategia/caso_de_prueba_pruebamotorsocial.md`.

## Estructura

```
pubspec.yaml                  motorsocial: path: ../motorsocial
assets/config/prestavecino.json   contrato del motor (marca, menú, roles, verbos, catálogo…)
assets/seed/                  semilla determinista (4 vecinos, 2 colonias, 12 objetos, 13 fotos, 15 actividades)
lib/main.dart                 arranque: modo semilla (por defecto) o integrado
lib/prestavecino/app.dart     composición: providers sustituidos + rutas propias
lib/prestavecino/prestamo.dart  única regla propia: disponible ↔ prestado
lib/prestavecino/objeto_widgets.dart  subtítulo y editor de atributos
lib/seed/seed_loader.dart     carga la semilla en los almacenes en memoria del motor
lib/diagnostico/panel.dart    J-12 (pulsación larga en la versión, en Perfil)
test/journeys/                recorridos J-01…J-12 en modo semilla
integration_test/             los mismos recorridos en un dispositivo
```

## Ejecutar

```powershell
flutter pub get
flutter run -d chrome --wasm                          # modo semilla
flutter run -d windows                                # modo semilla
flutter run -d windows --dart-define=PV_MODO=integrado   # CouchDB, bases test_*
flutter test                                          # J-01…J-12 (modo semilla)
flutter test integration_test -d windows              # J-01…J-12 en Windows
```

Cuentas de la semilla (sólo pruebas): `ana`, `beto`, `carla` y `dani`, con la contraseña `prestavecino-<nombre>-1`. También puedes entrar con `<nombre>@prestavecino.test`.

## Modo integrado

Carga la misma semilla en las bases `test_*` del servidor, desde el motor:

```powershell
cd ..\motorsocial
dart run tool/couchdb/check.dart --prefix test_
dart run tool/couchdb/seed.dart --prefix test_ --reset --fixtures ..\pruebamotorsocial\assets\seed
```

> Las contraseñas de la semilla son públicas. Úsalas sólo en un servidor de pruebas: las cuentas de `_users` son globales en CouchDB.

## Regla del préstamo

| Quién | Acción | Efecto |
|---|---|---|
| Vecino | **Pedir prestado** | Actividad `solicito` para el dueño y primer mensaje de la conversación |
| Dueño | **Prestar** (elige a uno de los solicitantes) | `disponible: false`, `prestadoA` y actividad `presto` |
| Quien lo tiene | **Devolver** | Actividad `devolvio` (no puede editar el objeto: lo impide `validate_doc_update`) |
| Dueño | **Recibido** | `disponible: true` de nuevo |
