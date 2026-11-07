import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorsocial/motorsocial.dart';
import 'package:pruebamotorsocial/prestavecino/app.dart';

/// Hora de referencia: dos días después de la última actividad semilla.
const int ahora = 1767225600000 + 48 * 3600000;

/// Entorno de un recorrido en modo semilla. Las sustituciones se conservan
/// para simular reinicios de la app con los mismos datos y almacenamiento.
class Pv {
  final InMemoryKeyValueStore keyValue = InMemoryKeyValueStore();
  final MemoryTokenStorage tokens = MemoryTokenStorage();
  final FakeConnectivityRepository connectivity = FakeConnectivityRepository();
  final FakeMediaPicker picker = FakeMediaPicker();
  final FakeGeolocationRepository geo = FakeGeolocationRepository(
    permission: LocationPermissionStatus.denied,
    onRequest: LocationPermissionStatus.denied,
  );
  final FixedClock clock = FixedClock(ahora);
  late List<Override> overrides;
  late ProviderContainer container;

  SemillaActiva get semilla => container.read(semillaActivaProvider)!;

  Future<void> init(WidgetTester tester) async {
    overrides = (await tester.runAsync(
      () => PrestaVecino.overrides(
        modo: ModoDatos.semilla,
        bundle: rootBundle,
        extra: [
          keyValueStoreProvider.overrideWithValue(keyValue),
          tokenStorageProvider.overrideWithValue(tokens),
          connectivityRepositoryProvider.overrideWithValue(connectivity),
          mediaPickerProvider.overrideWithValue(picker),
          geolocationRepositoryProvider.overrideWithValue(geo),
          clockProvider.overrideWithValue(clock),
          syncBackoffProvider.overrideWithValue((_) => Duration.zero),
        ],
      ),
    ))!;
  }

  /// Arranca (o reinicia) la app.
  Future<ProviderContainer> start(
    WidgetTester tester, {
    String initial = '/',
    Size size = const Size(420, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(overrides: overrides, retry: (_, _) => null);
    addTearDown(container.dispose);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MotorSocialApp(
          routes: PrestaVecino.routes,
          initialRoute: initial,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tiempoReal(tester);
    return container;
  }

  /// Inicia sesión como un vecino de la semilla sin pasar por la UI.
  Future<void> como(
    WidgetTester tester,
    String nombre, {
    String? password,
  }) async {
    final auth = container.read(authProvider.notifier);
    if (container.read(authProvider).value?.isAuthenticated ?? false) {
      await auth.signOut();
      await tester.pumpAndSettle();
    }
    final r = await auth.signIn(nombre, password ?? 'prestavecino-$nombre-1');
    expect(r.ok, isTrue, reason: r.displayMessage);
    await tester.pumpAndSettle();
  }

  /// Registra a Eva (usuaria nueva de J-01) sin pasar por la UI.
  Future<void> eva(WidgetTester tester) async {
    final r = await container
        .read(authProvider.notifier)
        .signUp(
          email: 'eva@prestavecino.test',
          password: 'prestavecino-eva-1',
          displayName: 'Eva',
        );
    expect(r.ok, isTrue, reason: r.displayMessage);
    await tester.pumpAndSettle();
  }

  /// Le asigna una colonia de la semilla al usuario actual.
  Future<void> colonia(WidgetTester tester, String placeId) async {
    final place = semilla.data.places.firstWhere((p) => p.id == placeId);
    final user = container.read(currentUserProvider)!;
    await container
        .read(authProvider.notifier)
        .updateProfile(
          user.copyWith(
            placeId: place.id,
            postalCode: place.postalCode,
            location: place.toLocation(),
          ),
        );
    await tester.pumpAndSettle();
  }

  Future<void> ir(WidgetTester tester, String route) async {
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.pushNamed(route);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
    await _tiempoReal(tester);
  }

  /// Escribe [texto] en [campo]. En dispositivo, un segundo `enterText` sobre
  /// el mismo campo puede no llegar por la entrada de texto real; si el valor
  /// no cambió, se fija directamente en el `EditableText`.
  Future<void> escribir(WidgetTester tester, Finder campo, String texto) async {
    await tester.enterText(campo, texto);
    await tester.pumpAndSettle();
    final editable = tester.state<EditableTextState>(
      find.descendant(of: campo, matching: find.byType(EditableText)),
    );
    if (editable.textEditingValue.text != texto) {
      editable.updateEditingValue(
        TextEditingValue(
          text: texto,
          selection: TextSelection.collapsed(offset: texto.length),
        ),
      );
      await tester.pumpAndSettle();
    }
  }

  /// Textos visibles en pantalla; se usa como `reason` en las aserciones para
  /// que un fallo en dispositivo diga qué se estaba mostrando.
  String textos(WidgetTester tester) => find
      .byType(Text)
      .hitTestable()
      .evaluate()
      .map((e) => (e.widget as Text).data ?? '')
      .where((t) => t.isNotEmpty)
      .join(' | ');

  /// En un dispositivo (integration_test) el reloj es real: `pumpAndSettle`
  /// vuelve en cuanto no hay cuadros pendientes aunque siga en curso trabajo
  /// asíncrono (alta, inicio de sesión). Se le da tiempo real y se vuelve a
  /// asentar. En pruebas de widget no hace nada.
  Future<void> _tiempoReal(WidgetTester tester) async {
    if (tester.binding is! LiveTestWidgetsFlutterBinding) return;
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
    }
  }

  /// Desplaza la lista [lista] hacia abajo como lo haría el usuario: el
  /// desplazamiento infinito pide la página siguiente al llegar al final
  /// (CAT-004, ACT-003); si la página cabe en pantalla, toca [mas]
  /// ("Cargar más"). Para cuando [hayMas] es falso o tras [veces] intentos.
  Future<void> desplazar(
    WidgetTester tester,
    Key lista,
    Key mas,
    bool Function() hayMas, {
    int veces = 10,
  }) async {
    for (var i = 0; i < veces && hayMas(); i++) {
      final boton = find.byKey(mas).hitTestable();
      if (boton.evaluate().isNotEmpty) {
        await tester.tap(boton);
      } else {
        await tester.drag(find.byKey(lista), const Offset(0, -600));
      }
      await tester.pumpAndSettle();
    }
  }
}

abstract final class TestDbs {
  static String objects(ProviderContainer c) =>
      c.read(databaseCatalogProvider).objects;
  static String activities(ProviderContainer c) =>
      c.read(databaseCatalogProvider).activities;
  static String security(ProviderContainer c) =>
      c.read(databaseCatalogProvider).securityEvents;
}

/// Foto de prueba en PNG (la semilla incluye imágenes reales).
Future<Uint8List> fotoSemilla(WidgetTester tester, String nombre) async =>
    (await tester.runAsync(
      () => rootBundle.load('assets/seed/fotos/$nombre'),
    ))!.buffer.asUint8List();
