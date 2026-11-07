import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motorsocial/motorsocial.dart';

/// La única regla de negocio propia de PrestaVecino: el estado de préstamo
/// de un objeto (`disponible` → `prestado` → `disponible`), guardado en
/// `SocialObject.attributes` y anunciado con una `SocialActivity`
/// (caso de prueba §3.1).
abstract final class Prestamo {
  static const String verboSolicito = 'solicito';
  static const String verboPresto = 'presto';
  static const String verboDevolvio = 'devolvio';

  static const String disponible = 'disponible';
  static const String prestadoA = 'prestadoA';

  static bool estaDisponible(SocialObject o) =>
      o.attribute<bool>(disponible) ?? true;

  static String? prestatario(SocialObject o) => o.attribute<String>(prestadoA);

  /// Clave de la conversación del préstamo entre dueño y solicitante.
  static String chatKey(SocialObject o, String solicitanteId) =>
      conversationKey(o.creatorId, solicitanteId, topic: o.id);
}

/// Operaciones del préstamo sobre los repositorios del motor.
class PrestamoService {
  PrestamoService(this._ref);

  final Ref _ref;

  String get _me {
    final id = _ref.read(currentUserIdProvider);
    if (id == null) throw StateError('Sin sesión');
    return id;
  }

  /// El vecino pide el objeto: actividad `solicito` dirigida al dueño y
  /// primer mensaje de la conversación. Devuelve la clave del chat.
  Future<String> solicitar(SocialObject o) async {
    final me = _me;
    if (o.creatorId == me) throw StateError('Es tu propio objeto.');
    if (!Prestamo.estaDisponible(o)) {
      throw StateError('El objeto ya está prestado.');
    }
    await _ref
        .read(feedProvider.notifier)
        .publish(
          verb: Prestamo.verboSolicito,
          objectId: o.id,
          targetId: o.creatorId,
          payload: {'title': o.title},
        );
    final key = Prestamo.chatKey(o, me);
    await _ref.read(conversationProvider(key).future);
    await _ref
        .read(conversationProvider(key).notifier)
        .send('Hola, ¿me prestas "${o.title}"?', toUserId: o.creatorId);
    return key;
  }

  /// Vecinos que lo han pedido (para elegir a quién prestarlo).
  Future<List<String>> solicitantes(SocialObject o) async {
    final pedidos = await _ref
        .read(activityRepositoryProvider)
        .byObject(o.id, verbs: const [Prestamo.verboSolicito]);
    return {for (final a in pedidos) a.actorId}.toList();
  }

  /// El dueño lo presta: deja de salir en "disponibles".
  Future<SocialObject> prestar(SocialObject o, String aUserId) => _ref
      .read(catalogActionsProvider)
      .update(
        o.copyWith(
          attributes: {
            ...o.attributes,
            Prestamo.disponible: false,
            Prestamo.prestadoA: aUserId,
          },
        ),
        announceVerb: Prestamo.verboPresto,
        payload: {'to': aUserId},
      );

  /// Quien lo tiene avisa de la devolución (no puede editar el objeto:
  /// `validate_doc_update` sólo deja escribir al dueño).
  Future<void> avisarDevolucion(SocialObject o) async {
    await _ref
        .read(feedProvider.notifier)
        .publish(
          verb: Prestamo.verboDevolvio,
          objectId: o.id,
          targetId: o.creatorId,
          payload: {'title': o.title},
        );
  }

  /// El dueño confirma que lo recibió: vuelve a estar disponible.
  Future<SocialObject> recibir(SocialObject o) {
    final attributes = {...o.attributes, Prestamo.disponible: true}
      ..remove(Prestamo.prestadoA);
    return _ref
        .read(catalogActionsProvider)
        .update(o.copyWith(attributes: attributes));
  }
}

final prestamoServiceProvider = Provider<PrestamoService>(PrestamoService.new);

Future<void> _guard(
  BuildContext context,
  Future<void> Function() body,
  String ok,
) async {
  try {
    await body();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok)));
    }
  } on Object catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ErrorState.describe(e))));
    }
  }
}

/// Acciones del detalle de un objeto (extensión `objectActionsProvider`).
List<ObjectAction> prestamoActions() => [
  ObjectAction(
    label: 'Pedir prestado',
    icon: 'chat',
    isVisible: (o, me) =>
        me != null && o.creatorId != me && Prestamo.estaDisponible(o),
    onPressed: (context, ref, o) async {
      String? key;
      await _guard(context, () async {
        key = await ref.read(prestamoServiceProvider).solicitar(o);
      }, 'Solicitud enviada');
      if (key != null && context.mounted) {
        await Navigator.of(context).pushNamed(
          '${AppRoutes.conversationFor(key!)}?to=${Uri.encodeComponent(o.creatorId)}',
        );
      }
    },
  ),
  ObjectAction(
    label: 'Prestar',
    icon: 'check',
    isVisible: (o, me) =>
        me != null && o.creatorId == me && Prestamo.estaDisponible(o),
    onPressed: (context, ref, o) async {
      final service = ref.read(prestamoServiceProvider);
      final candidatos = await service.solicitantes(o);
      if (!context.mounted) return;
      if (candidatos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nadie lo ha pedido todavía.')),
        );
        return;
      }
      final elegido = await showDialog<String>(
        context: context,
        builder: (c) => SimpleDialog(
          title: const Text('¿A quién se lo prestas?'),
          children: [
            for (final id in candidatos)
              Consumer(
                builder: (c, ref, _) => SimpleDialogOption(
                  key: Key('prestar-a-$id'),
                  onPressed: () => Navigator.pop(c, id),
                  child: Text(
                    ref.watch(userProfileProvider(id)).value?.displayName ?? id,
                  ),
                ),
              ),
          ],
        ),
      );
      if (elegido == null || !context.mounted) return;
      await _guard(
        context,
        () => service.prestar(o, elegido),
        'Marcado como prestado',
      );
    },
  ),
  ObjectAction(
    label: 'Devolver',
    icon: 'refresh',
    isVisible: (o, me) => me != null && Prestamo.prestatario(o) == me,
    onPressed: (context, ref, o) => _guard(
      context,
      () => ref.read(prestamoServiceProvider).avisarDevolucion(o),
      'Devolución avisada',
    ),
  ),
  ObjectAction(
    label: 'Recibido',
    icon: 'check',
    isVisible: (o, me) =>
        me != null && o.creatorId == me && !Prestamo.estaDisponible(o),
    onPressed: (context, ref, o) => _guard(
      context,
      () => ref.read(prestamoServiceProvider).recibir(o),
      'Vuelve a estar disponible',
    ),
  ),
];
