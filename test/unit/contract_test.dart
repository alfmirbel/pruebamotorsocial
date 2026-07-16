import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const assetPath = 'assets/contracts/motorsocial_contracts.json';

  test('Contrato JSON se parsea y trae appName/modulos esperados', () async {
    final raw = await rootBundle.loadString(assetPath);
    final data = jsonDecode(raw) as Map<String, dynamic>;

    expect(data['appName'], 'MotorSocialDemo');
    expect(data['themeId'], 'light_default');

    final modules = data['modules'] as Map<String, dynamic>;
    expect(
      modules.keys,
      containsAll(<String>[
        'identity',
        'navigation',
        'location',
        'catalog',
        'media',
        'activity',
        'social_graph',
        'security',
        'design',
      ]),
    );

    final identity = modules['identity'] as Map<String, dynamic>;
    expect(identity['loginTitle'], 'Bienvenido');
    expect(identity['primaryActionText'], 'Entrar');
    expect((identity['identifierRules'] as Map<String, dynamic>)['minLength'], 4);

    final activity = modules['activity'] as Map<String, dynamic>;
    final verbs = (activity['enabledVerbs'] as List<dynamic>).cast<String>();
    expect(verbs, containsAll(<String>['view', 'like', 'share', 'message']));
  });
}
