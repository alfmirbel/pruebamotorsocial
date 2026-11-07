import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motorsocial/motorsocial.dart';

import '../prestavecino/app.dart';

/// `true` si la configuración no lleva credenciales (CORE-009).
bool configSinCredenciales(SocialAppConfig config) {
  final json = jsonEncode(config.toJson()).toLowerCase();
  return !json.contains('"password"') &&
      !json.contains('"username"') &&
      !json.contains('couchdb_password');
}

/// Panel de diagnóstico (J-12): configuración, plataforma, sesión, cola de
/// sincronización, tema y modo de datos; restaura la semilla en modo semilla.
class DiagnosticoPage extends ConsumerWidget {
  const DiagnosticoPage({super.key});

  static const String route = '/diagnostico';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final modo = ref.watch(modoDatosProvider);
    final platform = ref.watch(platformInfoProvider);
    final auth = ref.watch(authProvider).value;
    final sync = ref.watch(syncStateProvider);
    final online = ref.watch(connectionStatusProvider).isOnline;
    final tokens = ref.watch(activeThemeTokensProvider);
    final semilla = ref.watch(semillaActivaProvider);
    final sinCredenciales = configSinCredenciales(config);

    Widget fila(String k, String v, {Key? key}) =>
        ListTile(key: key, dense: true, title: Text(k), subtitle: Text(v));

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico')),
      body: ListView(
        key: const Key('diagnostico'),
        padding: const EdgeInsets.all(8),
        children: [
          fila('App', config.appName),
          fila(
            'Modo',
            modo == ModoDatos.semilla ? 'semilla' : 'integrado',
            key: const Key('diag-modo'),
          ),
          fila(
            'Datos',
            '${config.dataMode.name} · prefijo "${config.couchdb.prefix}"',
          ),
          fila('Servidor', config.couchdb.url),
          fila(
            'Plataforma',
            '${platform.platform} ${platform.version}'.trim(),
            key: const Key('diag-plataforma'),
          ),
          fila('Sesión', auth?.user?.displayName ?? 'sin sesión'),
          fila('Conexión', online ? 'en línea' : 'sin conexión'),
          fila(
            'Pendientes de sincronizar',
            '${sync.pendingCount}',
            key: const Key('diag-pendientes'),
          ),
          fila(
            'Última sincronización',
            sync.lastSyncedAt == null
                ? '—'
                : DateTime.fromMillisecondsSinceEpoch(
                    sync.lastSyncedAt!,
                  ).toIso8601String(),
          ),
          fila('Tema', tokens.id, key: const Key('diag-tema')),
          fila(
            'Configuración sin credenciales',
            sinCredenciales ? 'sí' : 'NO',
            key: const Key('diag-credenciales'),
          ),
          const SizedBox(height: 16),
          if (semilla != null)
            FilledButton.icon(
              key: const Key('diag-restaurar'),
              icon: const Icon(SocialIcons.refresh),
              label: const Text('Restaurar semilla'),
              onPressed: () async {
                await semilla.restaurar();
                ref.invalidate(catalogProvider);
                ref.invalidate(feedProvider);
                ref.invalidate(receivedInvitationsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semilla restaurada')),
                  );
                }
              },
            )
          else
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Modo integrado: recarga las bases test_* con '
                'dart run tool/couchdb/seed.dart --prefix test_ --reset --fixtures ..\\pruebamotorsocial\\assets\\seed',
              ),
            ),
        ],
      ),
    );
  }
}
