import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/social_app_config.dart';
import '../database/database_module.dart';

MotorSocialBridge createMotorSocialBridge({
  required SocialAppConfig config,
  DatabaseModule? databaseModule,
}) {
  return MotorSocialBridge(
    config: config,
    databaseModule: databaseModule,
  );
}

class MotorSocialBridge {
  final SocialAppConfig config;
  final DatabaseModule? databaseModule;

  MotorSocialBridge({
    required this.config,
    this.databaseModule,
  });

  String? moduleStatus(String name) => config.moduleStatus(name);
}

final motorSocialBridgeProvider = Provider<MotorSocialBridge>((ref) {
  return createMotorSocialBridge(config: SocialAppConfig.defaults());
});

final socialAppConfigProvider = Provider<SocialAppConfig>((ref) {
  final bridge = ref.watch(motorSocialBridgeProvider);
  return bridge.config;
});
