import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:motorsocial/motorsocial.dart';

import 'prestavecino/app.dart';

/// `--dart-define=PV_MODO=integrado` usa las bases `test_*` de CouchDB.
const String _modo = String.fromEnvironment('PV_MODO', defaultValue: 'semilla');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final overrides = [
    keyValueStoreProvider.overrideWithValue(
      await PreferencesKeyValueStore.create(),
    ),
    ...await PrestaVecino.overrides(modo: ModoDatos.parse(_modo)),
  ];
  runApp(
    ProviderScope(
      overrides: overrides,
      child: MotorSocialApp(routes: PrestaVecino.routes),
    ),
  );
}
