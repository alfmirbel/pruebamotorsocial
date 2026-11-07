import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:motorsocial/motorsocial.dart';

import '../diagnostico/panel.dart';
import '../seed/seed_loader.dart';
import 'objeto_widgets.dart';
import 'prestamo.dart';

/// Modo de datos de PrestaVecino.
enum ModoDatos {
  /// Semilla en memoria (CI, demo, recorridos J-01…J-12).
  semilla,

  /// CouchDB de pruebas (`test_*`, D-11) con cuentas reales por usuario.
  integrado;

  static ModoDatos parse(String value) =>
      value == 'integrado' ? integrado : semilla;
}

/// Semilla cargada (para "restaurar semilla" en el diagnóstico, J-12).
class SemillaActiva {
  SemillaActiva(
    this.data,
    this.store,
    this.auth,
    this.postalCodes,
    this.catalog,
  );

  final SeedData data;
  final InMemoryDocumentStore store;
  final InMemoryAuthRepository auth;
  final InMemoryPostalCodeRepository postalCodes;
  final DatabaseCatalog catalog;

  Future<void> restaurar() => SeedLoader.apply(
    data,
    store,
    catalog: catalog,
    auth: auth,
    postalCodes: postalCodes,
  );
}

final modoDatosProvider = Provider<ModoDatos>((ref) => ModoDatos.semilla);
final semillaActivaProvider = Provider<SemillaActiva?>((ref) => null);

const String configAsset = 'assets/config/prestavecino.json';

/// Composición de PrestaVecino sobre el motor: configuración, semilla,
/// reglas del préstamo y dos rutas propias. Nada copiado del motor (FEA-009).
abstract final class PrestaVecino {
  /// Sustituciones de providers para [modo]. [extra] va al final (tests).
  static Future<List<Override>> overrides({
    required ModoDatos modo,
    AssetBundle? bundle,
    List<Override> extra = const [],
  }) async {
    final assets = bundle ?? rootBundle;
    var config = await SocialAppConfig.loadFromAssets(
      configAsset,
      bundle: assets,
    );
    config = config.copyWith(
      dataMode: modo == ModoDatos.integrado
          ? DataMode.couchdb
          : DataMode.memory,
    );
    final common = <Override>[
      appConfigProvider.overrideWithValue(config),
      modoDatosProvider.overrideWithValue(modo),
      objectActionsProvider.overrideWithValue(prestamoActions()),
      objectSubtitleProvider.overrideWithValue(subtituloObjeto),
      objectAttributesEditorProvider.overrideWith((ref) {
        final categorias = [
          for (final c
              in (config.extra['prestavecino']?['categorias'] as List? ??
                  const []))
            '$c',
        ];
        final colonia = ref.watch(currentUserProvider)?.placeId;
        return (attributes, onChanged) => ObjetoAtributosEditor(
          attributes: attributes,
          onChanged: onChanged,
          categorias: categorias,
          colonia: colonia,
        );
      }),
    ];
    if (modo == ModoDatos.integrado) return [...common, ...extra];

    final data = await SeedLoader(assets).read();
    final catalog = DatabaseCatalog(prefix: config.couchdb.prefix);
    final semilla = SemillaActiva(
      data,
      InMemoryDocumentStore(),
      InMemoryAuthRepository(),
      InMemoryPostalCodeRepository(),
      catalog,
    );
    await semilla.restaurar();
    return [
      ...common,
      semillaActivaProvider.overrideWithValue(semilla),
      baseDocumentStoreProvider.overrideWithValue(semilla.store),
      authRepositoryProvider.overrideWithValue(semilla.auth),
      postalCodeRepositoryProvider.overrideWithValue(semilla.postalCodes),
      ...extra,
    ];
  }

  /// Rutas propias: perfil con acceso oculto al diagnóstico y el panel.
  static final List<RouteSpec> routes = [
    RouteSpec(
      AppRoutes.profile,
      (_, _) => const PerfilPrestaVecino(),
      shell: true,
    ),
    RouteSpec(DiagnosticoPage.route, (_, _) => const DiagnosticoPage()),
  ];
}

/// Perfil del motor + versión; una pulsación larga abre el diagnóstico (J-12).
class PerfilPrestaVecino extends ConsumerWidget {
  const PerfilPrestaVecino({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version =
        ref.watch(appConfigProvider).extra['prestavecino']?['version'] ??
        '1.0.0';
    return Column(
      children: [
        const Expanded(child: ProfilePage()),
        GestureDetector(
          key: const Key('pv-version'),
          onLongPress: () =>
              Navigator.of(context).pushNamed(DiagnosticoPage.route),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'PrestaVecino $version',
              style: SocialTextStyles.of(context).meta,
            ),
          ),
        ),
      ],
    );
  }
}
