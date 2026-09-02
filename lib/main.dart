import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pruebamotorsocial/motorsocial/navigation/shell/social_scaffold.dart';
import 'package:pruebamotorsocial/motorsocial/navigation/data_models/menu_item.dart';
import 'package:pruebamotorsocial/motorsocial/catalog/pages/catalog_list_page.dart';
import 'package:pruebamotorsocial/motorsocial/activity/pages/activity_feed_page.dart';
import 'package:pruebamotorsocial/motorsocial/social_graph/pages/contacts_page.dart';
import 'package:pruebamotorsocial/motorsocial/features/profile/pages/profile_page.dart';
import 'package:pruebamotorsocial/motorsocial/identity/pages/login_page.dart';
import 'package:pruebamotorsocial/motorsocial/features/home/pages/home_page.dart';

import 'motorsocial/core/config/social_app_config.dart';
import 'motorsocial/core/motorsocial_bridge/bridge.dart';
import 'motorsocial/core/database/database_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await SocialAppConfig.loadFromAssets();
  final databaseModule = DatabaseModule.inMemory();

  runApp(
    ProviderScope(
      overrides: [
        motorSocialBridgeProvider.overrideWithValue(
          createMotorSocialBridge(
            config: config,
            databaseModule: databaseModule,
          ),
        ),
      ],
      child: const SocialAppRoot(),
    ),
  );
}

class SocialAppRoot extends ConsumerWidget {
  const SocialAppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.read(motorSocialBridgeProvider);
    final config = bridge.config;
    final uiMode =
        config.themeId.contains('dark') ? ThemeMode.dark : ThemeMode.system;
    const seed = Color(0xFF415AA9);

    return MaterialApp(
      title: config.appName,
      themeMode: uiMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: config.startRoute,
      onGenerateRoute: _generateRoute,
    );
  }

Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/catalog':
        return MaterialPageRoute(builder: (_) => const CatalogListPage());
      case '/activity':
        return MaterialPageRoute(builder: (_) => const ActivityFeedPage());
      case '/social_graph':
        return MaterialPageRoute(builder: (_) => const ContactsPage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
case '/login':
         return MaterialPageRoute(builder: (_) => const LoginPage());
       default:
         return MaterialPageRoute(
           builder: (_) => Scaffold(
             appBar: AppBar(title: const Text('No encontrado')),
             body: Center(
               child: Text('Ruta desconocida: ${settings.name}'),
             ),
           ),
         );
     }
   }
 }
