import 'package:pruebamotorsocial/motorsocial/identity/data_models/social_identity_contract.dart';
import 'package:pruebamotorsocial/motorsocial/identity/data_models/auth_state.dart';
import 'package:pruebamotorsocial/motorsocial/navigation/data_models/navigation_contract.dart';
import 'package:pruebamotorsocial/motorsocial/location/data_models/location_contract.dart';
import 'package:pruebamotorsocial/motorsocial/catalog/data_models/catalog_contract.dart';
import 'package:pruebamotorsocial/motorsocial/media/data_models/media_contract.dart';
import 'package:pruebamotorsocial/motorsocial/activity/data_models/activity_contract.dart';

class SocialAppConfig {
  final String appName;
  final String themeId;
  final SocialIdentityContract identity;
  final NavigationContract navigation;
  final LocationContract location;
  final CatalogContract catalog;
  final MediaContract media;
  final ActivityContract? activity;
  final List<String> modules;

  const SocialAppConfig({
    required this.appName,
    required this.themeId,
    required this.identity,
    required this.navigation,
    required this.location,
    required this.catalog,
    required this.media,
    this.activity,
    this.modules = const <String>[],
  });

  factory SocialAppConfig.defaults() => SocialAppConfig(
        appName: 'MotorSocialDemo',
        themeId: 'light_default',
        identity: SocialIdentityContract(authState: AuthState()),
        navigation: const NavigationContract(),
        location: const LocationContract(),
        catalog: const CatalogContract(providerName: 'demo'),
        media: const MediaContract(),
        activity: const ActivityContract(),
        modules: const <String>[],
      );

  factory SocialAppConfig.fromJson(Map<String, dynamic> json) {
    return SocialAppConfig(
      appName: (json['appName'] as String?) ?? 'MotorSocialDemo',
      themeId: (json['themeId'] as String?) ?? 'light_default',
      identity: const SocialIdentityContract(authState: AuthState()),
      navigation: const NavigationContract(),
      location: const LocationContract(),
      catalog: const CatalogContract(providerName: 'demo'),
      media: const MediaContract(),
      activity: const ActivityContract(),
      modules: const <String>[],
    );
  }

  String? moduleStatus(String name) {
    switch (name) {
      case 'identity':
      case 'activity':
      case 'catalog':
      case 'media':
      case 'social_graph':
      case 'design':
      case 'security':
      case 'location':
        return 'stub';
      default:
        return null;
    }
  }
}
