import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorsocial/motorsocial.dart';
import 'package:pruebamotorsocial/diagnostico/panel.dart';

import 'harness.dart';

void main() {
  testWidgets('J-09 sin conexión', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    await pv.como(tester, 'beto');

    // Modo avión: aviso y contador de pendientes (RES-002, RES-005, ACT-010).
    pv.connectivity.goOffline();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('connection-banner')), findsOneWidget);
    pv.clock.advance(const Duration(minutes: 1));
    await pv.container.read(feedProvider.notifier).post('Publicado sin red');
    await pv.container
        .read(commentsProvider('object:carpa').notifier)
        .add('Comentario sin red');
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión · 2 pendientes'), findsOneWidget);
    final db = TestDbs.activities(pv.container);
    expect(
      pv.semilla.store
          .dump(db)
          .where((a) => a['payload']?['text'] == 'Publicado sin red'),
      isEmpty,
    );

    // Al reconectar se envían y el contador vuelve a 0 (RES-004).
    pv.connectivity.goOnline();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('connection-banner')), findsNothing);
    expect(pv.container.read(syncStateProvider).pendingCount, 0);
    expect(
      pv.semilla.store
          .dump(db)
          .where((a) => a['payload']?['text'] == 'Publicado sin red'),
      hasLength(1),
    );

    // Abrir la app sin red con la sesión guardada (IDN-011).
    pv.semilla.store.offline = true;
    pv.semilla.auth.offline = true;
    await pv.start(tester);
    expect(pv.container.read(authProvider).value!.offline, isTrue);
    expect(find.text('Hola, Beto'), findsOneWidget);
    pv.semilla.store.offline = false;
    pv.semilla.auth.offline = false;
  });

  testWidgets('J-10 marca e interfaz', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    await pv.como(tester, 'ana');

    // Tema de PrestaVecino (DSN-006): semilla verde.
    final context = tester.element(find.byType(HomePage));
    // En dispositivo el modo sigue al sistema: se compara con el brillo activo.
    final expected = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      brightness: Theme.of(context).brightness,
    );
    expect(Theme.of(context).colorScheme.primary, expected.primary);

    // Barra de 4 pestañas (NAV-005).
    final bar = tester.widget<NavigationBar>(
      find.byKey(const Key('navigation-bar')),
    );
    expect(bar.destinations, hasLength(4));
    for (final label in ['Inicio', 'Explorar', 'Actividad', 'Perfil']) {
      expect(
        find.descendant(
          of: find.byKey(const Key('navigation-bar')),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }

    // Modo oscuro forzado y persistido (DSN-004, DSN-005).
    await pv.ir(tester, AppRoutes.themeSettings);
    await pv.tap(tester, find.text('Oscuro'));
    await pv.start(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    // Tableta: NavigationRail (DSN-007).
    await pv.start(tester, size: const Size(1100, 800));
    expect(find.byKey(const Key('navigation-rail')), findsOneWidget);
  });

  test('J-10 el cliente no usa colores en línea ni iconos fuera de rango', () {
    if (!Directory('lib').existsSync()) return; // en dispositivo no hay fuentes
    final offenders = <String>[];
    for (final f in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      final src = f.readAsStringSync();
      if (RegExp(r'\bColor\(0x|\bColors\.|\bIcons\.').hasMatch(src)) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty);
  });

  testWidgets('J-11 seguridad', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);

    // 3 fallos bloquean el formulario y registran el evento (SEC-002, SEC-005).
    for (var i = 0; i < 3; i++) {
      await pv.escribir(
        tester,
        find.byKey(const Key('login-identifier')),
        'ana@prestavecino.test',
      );
      await pv.escribir(
        tester,
        find.byKey(const Key('login-secret')),
        'incorrecta-$i',
      );
      await pv.tap(tester, find.byKey(const Key('login-submit')));
    }
    expect(find.textContaining('Formulario bloqueado'), findsOneWidget);
    final field = tester.widget<TextField>(
      find.byKey(const Key('login-identifier')),
    );
    expect(field.enabled, isFalse);
    final eventos = pv.semilla.store
        .dump(TestDbs.security(pv.container))
        .map((e) => e['eventType']);
    expect(eventos.where((e) => e == 'login_failed'), hasLength(3));
    expect(eventos, contains('account_locked'));

    // Un 401 a mitad de uso devuelve al login sin cerrar la app (SEC-003).
    pv.clock.advance(const Duration(minutes: 6));
    await pv.start(tester);
    await pv.como(tester, 'ana');
    await pv.tap(tester, find.text('Explorar').last);
    pv.container.read(sessionEventsProvider).emit(SessionEvent.unauthorized);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-identifier')), findsOneWidget);
    expect(pv.container.read(authProvider).value!.expired, isTrue);
  });

  testWidgets('J-12 diagnóstico y restaurar semilla', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    await pv.como(tester, 'beto');

    // Cambio en los datos: Beto borra el proyector.
    final repo = pv.container.read(catalogRepositoryProvider);
    await repo.delete((await repo.get('object:proyector'))!);
    expect(await repo.get('object:proyector'), isNull);

    // Panel oculto: pulsación larga en la versión (CORE-001, RES-006).
    await pv.tap(tester, find.text('Perfil').last);
    await tester.ensureVisible(find.byKey(const Key('pv-version')));
    await tester.longPress(find.byKey(const Key('pv-version')));
    await tester.pumpAndSettle();
    expect(find.byType(DiagnosticoPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('diag-modo')),
        matching: find.text('semilla'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('diag-tema')),
        matching: find.text('prestavecino'),
      ),
      findsOneWidget,
    );
    // La configuración no lleva credenciales de CouchDB (CORE-009).
    expect(
      find.descendant(
        of: find.byKey(const Key('diag-credenciales')),
        matching: find.text('sí'),
      ),
      findsOneWidget,
    );
    expect(configSinCredenciales(pv.container.read(appConfigProvider)), isTrue);

    await pv.tap(tester, find.byKey(const Key('diag-restaurar')));
    expect(await repo.get('object:proyector'), isNotNull);
  });
}
