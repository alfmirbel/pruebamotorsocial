import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pruebamotorsocial/main.dart';
import 'package:pruebamotorsocial/core/motorsocial_bridge/bridge.dart';

void main() {
  test('Bridge expone config y modulos por defecto', () {
    final container = ProviderContainer(overrides: [
      motorSocialBridgeProvider.overrideWith((_) => createMotorSocialBridge()),
    ]);

    final bridge = container.read(motorSocialBridgeProvider);
    expect(bridge.config.appName, 'MotorSocialDemo');

    expect(bridge.catalog, isA);
    expect(bridge.identity, isA);
    expect(bridge.design, isA);

    final config = container.read(socialAppConfigProvider);
    expect(config.appName, 'MotorSocialDemo');
  });
}
