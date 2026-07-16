import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const assetPath = 'assets/contracts/motorsocial_contracts.json';

  testWidgets('Smoke: arranque del shell con login fallido', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MainShell()),
      ),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
