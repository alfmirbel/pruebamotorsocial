import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/social_app_config.dart';
import 'core/motorsocial_bridge/bridge.dart';
import 'core/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = SocialAppConfig.defaults();

  runApp(
    ProviderScope(
      overrides: [
        motorSocialBridgeProvider.overrideWith(
          MotorSocialBridgeNotifier.new,
        ),
        socialAppConfigProvider.overrideWith((_) => config),
      ],
      child: SocialApp(config: config),
    ),
  );
}

class SocialApp extends ConsumerWidget {
  final SocialAppConfig config;
  const SocialApp({required this.config, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: config.appName,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF415AA9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF415AA9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

