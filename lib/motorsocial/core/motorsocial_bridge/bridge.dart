import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pruebamotorsocial/motorsocial/core/config/social_app_config.dart';
import 'package:pruebamotorsocial/motorsocial/core/database/database_module.dart';

/// Interfaz del puente entre el motor y la aplicación de prueba.
abstract class MotorSocialBridge {
  /// La configuración de la aplicación cargada desde assets.
  SocialAppConfig get config;
  
  /// El módulo de base de datos para pruebas.
  DatabaseModule get databaseModule;
}

/// Implementación del puente para la aplicación de prueba.
class MotorSocialDBBridge implements MotorSocialBridge {
  final SocialAppConfig _config;
  final DatabaseModule _databaseModule;

  MotorSocialDBBridge({
    required SocialAppConfig config,
    required DatabaseModule databaseModule,
  })  : _config = config,
        _databaseModule = databaseModule;

  @override
  SocialAppConfig get config => _config;

  @override
  DatabaseModule get databaseModule => _databaseModule;
}

/// Función de ayuda para crear una instancia del puente.
MotorSocialBridge createMotorSocialBridge({
  required SocialAppConfig config,
  required DatabaseModule databaseModule,
}) {
  return MotorSocialDBBridge(
    config: config,
    databaseModule: databaseModule,
  );
}

/// Provider para el puente del motor.
final motorSocialBridgeProvider = Provider<MotorSocialBridge>((ref) {
  // En una implementación real, esto vendría de la inyección de dependencias
  throw UnimplementedError('motorSocialBridgeProvider requires override');
});