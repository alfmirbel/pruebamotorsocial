import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

@immutable
class SocialAppConfig {
  final String appName;
  final String themeId;
  final Map<String, dynamic> identity;
  final Map<String, dynamic> navigation;
  final Map<String, dynamic> location;
  final Map<String, dynamic> catalog;
  final Map<String, dynamic> media;
  final Map<String, dynamic> activity;
  final List<String> modules;
  final bool useStubRepositories;
  final CouchDbConfig? couchdb;
  final QdrantConfig? qdrant;

  const SocialAppConfig({
    required this.appName,
    required this.themeId,
    required this.identity,
    required this.navigation,
    required this.location,
    required this.catalog,
    required this.media,
    required this.activity,
    required this.modules,
    this.useStubRepositories = true,
    this.couchdb,
    this.qdrant,
  });

  factory SocialAppConfig.fromJson(Map<String, dynamic> json) {
    final couch = json['couchdb'];
    final qdrant = json['qdrant'];
    return SocialAppConfig(
      appName: (json['appName'] as String?) ?? 'MotorSocial',
      themeId: (json['themeId'] as String?) ?? 'light_default',
      identity: (json['identity'] as Map<String, dynamic>?) ?? const {},
      navigation: (json['navigation'] as Map<String, dynamic>?) ?? const {},
      location: (json['location'] as Map<String, dynamic>?) ?? const {},
      catalog: (json['catalog'] as Map<String, dynamic>?) ?? const {},
      media: (json['media'] as Map<String, dynamic>?) ?? const {},
      activity: (json['activity'] as Map<String, dynamic>?) ?? const {},
      modules: (json['modules'] as List?)?.cast<String>() ?? const [],
      useStubRepositories: (json['useStubRepositories'] as bool?) ?? true,
      couchdb: couch != null ? CouchDbConfig.fromJson(couch) : null,
      qdrant: qdrant != null ? QdrantConfig.fromJson(qdrant) : null,
    );
  }

  factory SocialAppConfig.defaults() => const SocialAppConfig(
        appName: 'MotorSocial',
        themeId: 'light_default',
        identity: <String, dynamic>{},
        navigation: <String, dynamic>{},
        location: <String, dynamic>{},
        catalog: <String, dynamic>{},
        media: <String, dynamic>{},
        activity: <String, dynamic>{},
        modules: <String>[],
        useStubRepositories: true,
        couchdb: null,
        qdrant: null,
      );

Map<String, dynamic> toJson() => {
         'appName': appName,
         'themeId': themeId,
         'identity': identity,
         'navigation': navigation,
         'location': location,
         'media': media,
         'catalog': catalog,
         'activity': activity,
         'modules': modules,
         'useStubRepositories': useStubRepositories,
         if (couchdb != null) 'couchdb': couchdb!.toJson(),
         if (qdrant != null) 'qdrant': qdrant!.toJson(),
       };

/// Carga la configuración desde el archivo JSON en assets.
  static Future<SocialAppConfig> loadFromAssets() async {
    // En una app real, usaríamos rootBundle.loadString
    // Para simplicidad en este ejemplo, asumimos que el archivo está disponible
    
    final String jsonString = await rootBundle.loadString(
        'assets/contracts/motorsocial_contracts.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return SocialAppConfig.fromJson(jsonMap);
  }

  /// Acceso conveniente a las pestañas de navegación inferior.
  List<Map<String, dynamic>> get bottomTabs =>
      navigation['bottomTabs']?.cast<Map<String, dynamic>>() ?? const [];

  /// Acceso conveniente a la ruta de inicio.
  String get startRoute => navigation['startRoute'] as String? ?? '/';

  /// Lista completa de rutas navegables desde el home.
  List<Map<String, dynamic>> get appRoutes =>
      [...bottomTabs, {'route': '/login', 'icon': 'login', 'label': 'Login'}];
}

@immutable
class CouchDbConfig {
  final String url;
  final String username;
  final String password;

  const CouchDbConfig({
    required this.url,
    required this.username,
    required this.password,
  });

  factory CouchDbConfig.fromJson(Map<String, dynamic> json) => CouchDbConfig(
        url: (json['url'] as String?) ?? 'http://localhost:5984',
        username: (json['username'] as String?) ?? '',
        password: (json['password'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'username': username,
        'password': password,
      };
}

@immutable
class QdrantConfig {
  final String url;
  final String apiKey;

  const QdrantConfig({
    required this.url,
    required this.apiKey,
  });

  factory QdrantConfig.fromJson(Map<String, dynamic> json) => QdrantConfig(
        url: (json['url'] as String?) ?? 'http://localhost:6333',
        apiKey: (json['apiKey'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'apiKey': apiKey,
      };
}
