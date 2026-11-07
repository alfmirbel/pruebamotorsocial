import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorsocial/motorsocial.dart';
import 'package:pruebamotorsocial/prestavecino/prestamo.dart';

import 'harness.dart';

void main() {
  testWidgets('J-05 publicar un objeto con fotos', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    await pv.como(tester, 'beto');
    final foto = await fotoSemilla(tester, 'catan-1.png');
    pv.picker.next = [
      PickedMedia(
        bytes: foto,
        fileName: 'lijadora-1.png',
        contentType: 'image/png',
      ),
      PickedMedia(
        bytes: foto,
        fileName: 'lijadora-2.png',
        contentType: 'image/png',
      ),
    ];

    await pv.ir(tester, AppRoutes.catalogNew);
    // Sin título falla la validación (CAT-006).
    await pv.tap(tester, find.byKey(const Key('object-save')));
    expect(find.text('Escribe un título.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('object-title')), 'Lijadora');
    await pv.tap(tester, find.byKey(const Key('objeto-categoria')));
    await tester.tap(find.text('herramientas').last);
    await tester.pumpAndSettle();
    await pv.tap(tester, find.byKey(const Key('object-photos-add'))); // MED-003
    expect(find.text('Fotos (2)'), findsOneWidget);
    await pv.tap(tester, find.byKey(const Key('object-save')));

    // Publicado: detalle, catálogo, feed y biblioteca (CAT-002, ACT-004, MED-004).
    expect(find.byKey(const Key('object-detail')), findsOneWidget);
    final objetos = await pv.container
        .read(catalogRepositoryProvider)
        .search(const SocialObjectQuery(text: 'Lijadora'));
    final lijadora = objetos.items.single;
    expect(lijadora.mediaIds, hasLength(2));
    expect(Prestamo.estaDisponible(lijadora), isTrue);
    expect(lijadora.attribute<String>('colonia'), 'place:americana');
    final feed = pv.semilla.store.dump(TestDbs.activities(pv.container));
    expect(
      feed.where((a) => a['verb'] == 'post' && a['objectId'] == lijadora.id),
      hasLength(1),
    );
    final biblioteca = await pv.container.read(mediaLibraryProvider.future);
    expect(biblioteca.where((m) => m.objectId == lijadora.id), hasLength(2));
  });

  testWidgets('J-06 explorar, filtrar y ver fotos', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    await pv.eva(tester);
    await pv.colonia(tester, 'place:americana');
    await pv.tap(tester, find.text('Explorar').last);

    // pageSize = 5 con paginación (CAT-003, CAT-004).
    expect(find.byType(ObjectCard), findsNWidgets(5));
    expect(find.byKey(const Key('catalog-more')), findsOneWidget);
    await pv.desplazar(
      tester,
      const Key('catalog-list'),
      const Key('catalog-more'),
      () => pv.container.read(catalogProvider).value!.hasMore,
    );
    expect(pv.container.read(catalogProvider).value!.items, hasLength(12));
    expect(pv.container.read(catalogProvider).value!.hasMore, isFalse);
    await tester.drag(
      find.byKey(const Key('catalog-list')),
      const Offset(0, 3000),
    );
    await tester.pumpAndSettle();

    // Filtros: herramientas y sólo disponibles (CAT-005).
    await pv.tap(
      tester,
      find.byKey(const Key('filter-categoria-herramientas')),
    );
    await pv.tap(tester, find.byKey(const Key('filter-disponible-true')));
    final items = pv.container.read(catalogProvider).value!.items;
    expect(items.map((o) => o.id).toSet(), {'object:taladro', 'object:caja'});

    // Detalle con presentación de fotos (CAT-008, MED-006).
    await pv.tap(tester, find.text('Taladro inalámbrico'));
    expect(find.byKey(const Key('object-gallery')), findsOneWidget);
    await pv.tap(
      tester,
      find
          .descendant(
            of: find.byKey(const Key('object-gallery')),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.fling(
      find.byKey(const Key('media-slideshow')),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
  });

  testWidgets('J-07 pedir prestado y devolver', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    await pv.eva(tester);
    const taladro = 'object:taladro';

    // Me interesa + pedir prestado abre la conversación (ACT-006, ACT-007).
    await pv.ir(tester, AppRoutes.catalogItem(taladro));
    await pv.tap(tester, find.byKey(const Key('like-$taladro')));
    expect(
      find.descendant(
        of: find.byKey(const Key('like-$taladro')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    await pv.tap(tester, find.byKey(const Key('object-action-Pedir prestado')));
    expect(find.byKey(const Key('conversation-list')), findsOneWidget);
    expect(find.textContaining('¿me prestas'), findsOneWidget);

    // Beto lo presta: deja de estar disponible (CAT-002).
    await pv.como(tester, 'beto');
    await pv.ir(tester, AppRoutes.catalogItem(taladro));
    await pv.tap(tester, find.byKey(const Key('object-action-Prestar')));
    await pv.tap(
      tester,
      find.byKey(const Key('prestar-a-user:eva@prestavecino.test')),
    );
    var o = (await pv.container.read(catalogRepositoryProvider).get(taladro))!;
    expect(Prestamo.estaDisponible(o), isFalse);
    expect(Prestamo.prestatario(o), 'user:eva@prestavecino.test');
    final disponibles = await pv.container
        .read(catalogRepositoryProvider)
        .search(
          const SocialObjectQuery(attributes: {'disponible': true}, limit: 50),
        );
    expect(disponibles.items.map((x) => x.id), isNot(contains(taladro)));

    // Eva avisa de la devolución y Beto la confirma.
    await pv.como(
      tester,
      'eva@prestavecino.test',
      password: 'prestavecino-eva-1',
    );
    await pv.ir(tester, AppRoutes.catalogItem(taladro));
    await pv.tap(tester, find.byKey(const Key('object-action-Devolver')));
    await pv.como(tester, 'beto');
    await pv.ir(tester, AppRoutes.catalogItem(taladro));
    await pv.tap(tester, find.byKey(const Key('object-action-Recibido')));
    o = (await pv.container.read(catalogRepositoryProvider).get(taladro))!;
    expect(Prestamo.estaDisponible(o), isTrue);
    final verbos = pv.semilla.store
        .dump(TestDbs.activities(pv.container))
        .where((a) => a['objectId'] == taladro)
        .map((a) => a['verb'])
        .toList();
    expect(verbos, containsAll(['solicito', 'presto', 'devolvio', 'like']));
  });

  testWidgets('J-08 feed vecinal', (tester) async {
    final pv = Pv();
    await pv.init(tester);
    await pv.start(tester);
    // Ana: contacto de Beto y administradora del grupo de su colonia.
    await pv.como(tester, 'ana');
    await pv.tap(tester, find.text('Actividad').last);

    final feed = pv.container.read(feedProvider).value!;
    final actores = feed.items.map((a) => a.actorId).toSet();
    // Contacto (Beto) y grupo (Carla publica en el grupo), no Dani (otra colonia).
    expect(actores, containsAll(['user:beto', 'user:carla']));
    expect(actores, isNot(contains('user:dani')));
    final fechas = feed.items.map((a) => a.createdAt).toList();
    expect(fechas, [...fechas]..sort((a, b) => b.compareTo(a)));
    expect(feed.items, hasLength(10));
    expect(feed.hasMore, isTrue);
    await pv.desplazar(
      tester,
      const Key('feed-list'),
      const Key('feed-more'),
      () => pv.container.read(feedProvider).value!.items.length <= 10,
      veces: 3,
    );
    expect(
      pv.container.read(feedProvider).value!.items.length,
      greaterThan(10),
    );
    await tester.drag(
      find.byKey(const Key('feed-list')),
      const Offset(0, 3000),
    );
    await tester.pumpAndSettle();

    // Aparece en vivo una actividad nueva de Beto (ACT-009).
    await pv.semilla.store.put(TestDbs.activities(pv.container), {
      '_id': 'activity:en-vivo',
      'docType': 'activity',
      'actorId': 'user:beto',
      'actorName': 'Beto',
      'verb': 'post',
      'objectType': 'note',
      'objectId': 'activity:en-vivo',
      'payload': {'text': 'Presto mi escalera el domingo'},
      'createdAt': ahora + 1000,
    });
    await tester.pumpAndSettle();
    expect(
      pv.container.read(feedProvider).value!.items.first.id,
      'activity:en-vivo',
    );
    expect(find.text('Presto mi escalera el domingo'), findsOneWidget);
  });
}
