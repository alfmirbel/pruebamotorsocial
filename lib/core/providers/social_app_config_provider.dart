import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/social_app_config.dart';
import '../motorsocial_bridge/bridge.dart';

final socialAppConfigProvider = Provider<SocialAppConfig>((ref) {
  final bridge = ref.watch(motorSocialBridgeProvider);
  return bridge.config;
});
