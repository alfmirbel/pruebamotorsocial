import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pruebamotorsocial/motorsocial/identity/identity.dart';
import 'package:pruebamotorsocial/motorsocial/activity/activity.dart';
import 'package:pruebamotorsocial/motorsocial/catalog/catalog.dart';
import 'package:pruebamotorsocial/motorsocial/design/engine/design_engine.dart';
import 'package:pruebamotorsocial/motorsocial/design/repositories/theme_repository.dart';
import 'package:pruebamotorsocial/motorsocial/design/data_models/design_token.dart';
import '../config/social_app_config.dart';

MotorSocialBridge createMotorSocialBridge({
  required SocialAppConfig config,
  CatalogRepository? catalogRepository,
  ActivityRepository? activityRepository,
  ThemeRepository? themeRepository,
}) {
  return MotorSocialBridge(
    config: config,
    catalog: CatalogEngine(catalogRepository ?? const _InMemoryCatalogRepository()),
    identity: const SocialIdentityEngine(),
    design: DesignEngine(themeRepository ?? const _InMemoryThemeRepository()),
    activityRepository: activityRepository,
  );
}

class MotorSocialBridgeNotifier extends Notifier<MotorSocialBridge> {
MotorSocialBridge build() => createMotorSocialBridge(
        config: SocialAppConfig.defaults(),
      );
}

class MotorSocialBridge {
  final SocialAppConfig config;
  final CatalogEngine catalog;
  final SocialIdentityEngine identity;
  final DesignEngine design;
  final ActivityRepository? activityRepository;

  const MotorSocialBridge({
    required this.config,
    required this.catalog,
    required this.identity,
    required this.design,
    this.activityRepository,
  });

  String? moduleStatus(String name) => config.moduleStatus(name);
}

final motorSocialBridgeProvider = NotifierProvider<MotorSocialBridgeNotifier, MotorSocialBridge>(MotorSocialBridgeNotifier.new);
final socialAppConfigProvider = Provider<SocialAppConfig>((ref) => ref.watch(motorSocialBridgeProvider).config);

class _InMemoryCatalogRepository implements CatalogRepository {
  const _InMemoryCatalogRepository();
Future<List<SocialObjectQuery>> search(String query, {int limit = 20}) async =>
      const <SocialObjectQuery>[];
Future<SocialObject?> getById(String id) async => null;
Future<SocialObject> create(SocialObject object) async => object;
Future<SocialObject> update(String id, SocialObject object) async => object;
Future<void> delete(String id) async {}
}

class _InMemoryThemeRepository implements ThemeRepository {
  const _InMemoryThemeRepository();
ThemeTokenSet loadTheme(String themeId) =>
      ThemeTokenSet(const <String, DesignToken>{});
Future<void> saveTheme(ThemeTokenSet tokenSet) async {}
}
