import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/social_app_config.dart';

final socialAppConfigProvider = Provider<SocialAppConfig>((_) {
  throw StateError('SocialAppConfig no inicializada. Cargala en main.dart antes de runApp.');
});
