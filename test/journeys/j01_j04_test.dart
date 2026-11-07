import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorsocial/motorsocial.dart';

import 'harness.dart';

void main() {
  testWidgets('J-01 alta y sesión', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);

    // Alta de Eva → inicio.
    expect(find.byKey(const Key('login-identifier')), findsOneWidget);
    await pv.tap(tester, find.byKey(const Key('login-register')));
    await tester.enterText(find.byKey(const Key('register-name')), 'Eva');
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'eva@prestavecino.test',
    );
    await tester.enterText(find.byKey(const Key('register-password')), 'corta');
    await pv.tap(tester, find.byKey(const Key('register-submit')));
    expect(find.textContaining('al menos 8'), findsOneWidget); // IDN-004
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'prestavecino-eva-1',
    );
    await pv.tap(tester, find.byKey(const Key('register-submit')));
    expect(find.text('Hola, Eva'), findsOneWidget);

    // Reabrir: la sesión sigue (IDN-006, IDN-007).
    await pv.start(tester);
    expect(find.text('Hola, Eva'), findsOneWidget);

    // Cerrar sesión (IDN-008, NAV-007).
    await pv.tap(tester, find.text('Perfil').last);
    await pv.tap(tester, find.byKey(const Key('profile-logout')));
    expect(find.byKey(const Key('login-identifier')), findsOneWidget);

    // Ruta privada sin sesión → login (NAV-004).
    await pv.start(tester, initial: '/catalog');
    expect(find.byKey(const Key('login-identifier')), findsOneWidget);

    // Contraseña incorrecta: mensaje genérico (IDN-002).
    await tester.enterText(
      find.byKey(const Key('login-identifier')),
      'eva@prestavecino.test',
    );
    await tester.enterText(find.byKey(const Key('login-secret')), 'mala-1234');
    await pv.tap(tester, find.byKey(const Key('login-submit')));
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);

    // Olvidé mi contraseña: siempre el mismo mensaje (IDN-005).
    await pv.tap(tester, find.text('¿Olvidaste tu contraseña?'));
    await tester.enterText(
      find.byKey(const Key('recover-email')),
      'eva@prestavecino.test',
    );
    await pv.tap(tester, find.byKey(const Key('recover-submit')));
    expect(find.byKey(const Key('recover-sent')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Entra y vuelve a la ruta original (NAV-009).
    await tester.enterText(
      find.byKey(const Key('login-secret')),
      'prestavecino-eva-1',
    );
    await pv.tap(tester, find.byKey(const Key('login-submit')));
    expect(find.byKey(const Key('catalog-search')), findsOneWidget);
  });

  testWidgets('J-02 mi colonia y mi cuenta', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    await pv.eva(tester);

    // CP 44160 → Americana (LOC-004, LOC-005).
    await pv.ir(tester, AppRoutes.locality);
    await tester.enterText(find.byKey(const Key('locality-cp')), '44160');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await pv.tap(tester, find.byKey(const Key('locality-place:americana')));
    expect(pv.container.read(currentUserProvider)!.placeId, 'place:americana');

    // Se mantiene tras reiniciar.
    await pv.start(tester);
    expect(pv.container.read(currentUserProvider)!.postalCode, '44160');

    // Permiso denegado → entrada manual y no se vuelve a pedir (LOC-006, LOC-007).
    await pv.ir(tester, AppRoutes.locality);
    await pv.tap(tester, find.byKey(const Key('locality-gps')));
    expect(find.byKey(const Key('locality-manual')), findsOneWidget);
    expect(find.byKey(const Key('locality-gps')), findsNothing);
    expect(pv.geo.requests, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Cuenta: nombre visible editable (FEA-006) y visible en Perfil (FEA-005).
    await pv.ir(tester, AppRoutes.account);
    await tester.enterText(find.byKey(const Key('account-name')), 'Eva G.');
    await pv.tap(tester, find.byKey(const Key('account-save')));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await pv.tap(tester, find.text('Perfil').last);
    expect(find.text('Eva G.'), findsOneWidget);
  });

  testWidgets('J-03 unirme a mi colonia', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    await pv.eva(tester);
    await pv.colonia(tester, 'place:americana');

    await pv.ir(tester, AppRoutes.groups);
    // Los grupos de mi colonia van primero (SOC-005).
    final first = tester.widget<ListTile>(find.byType(ListTile).first);
    expect((first.title as Text).data, 'Vecinos Americana');
    await pv.tap(tester, find.byKey(const Key('join-group:americana')));
    await pv.tap(tester, find.byKey(const Key('group-group:americana')));
    expect(
      find.byKey(const Key('member-user:eva@prestavecino.test')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('member-user:ana')),
        matching: find.byKey(const Key('member-admin')),
      ),
      findsOneWidget,
    ); // SOC-006
  });

  testWidgets('J-04 vecino de confianza', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);

    // Carla ve 1 invitación y acepta la de Beto (SOC-004, SOC-008).
    await pv.como(tester, 'carla');
    expect(
      find.descendant(
        of: find.byKey(const Key('badge-invitations')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    await pv.ir(tester, AppRoutes.invitations);
    await pv.tap(tester, find.byKey(const Key('accept-invitation:beto-carla')));
    expect(find.text('No tienes invitaciones pendientes.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await pv.ir(tester, AppRoutes.contacts);
    expect(find.byKey(const Key('contact-user:beto')), findsOneWidget);

    // Eva invita a Dani y Dani la rechaza (SOC-003).
    await pv.container.read(authProvider.notifier).signOut();
    await tester.pumpAndSettle();
    await pv.eva(tester);
    await pv.ir(tester, AppRoutes.contacts);
    await tester.enterText(find.byKey(const Key('contacts-search')), 'Dani');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await pv.tap(tester, find.byKey(const Key('invite-user:dani')));

    await pv.como(tester, 'dani');
    await pv.ir(tester, AppRoutes.invitations);
    await pv.tap(tester, find.byIcon(SocialIcons.close).first);
    final sent = await pv.container
        .read(invitationsRepositoryProvider)
        .sent('user:eva@prestavecino.test');
    expect(sent.single.status, InvitationStatus.rejected);
  });
}
