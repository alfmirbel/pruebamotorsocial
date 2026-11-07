import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:motorsocial/motorsocial.dart';

/// Datos de la semilla de PrestaVecino (`assets/seed/`), los mismos que
/// `tool/couchdb/seed.dart` carga en las bases `test_*` del modo integrado.
class SeedData {
  SeedData({
    required this.accounts,
    required this.documents,
    required this.attachments,
    required this.places,
  });

  /// nombre → contraseña (cuentas de prueba, públicas a propósito).
  final Map<String, String> accounts;

  /// base canónica (`motorsocial_*`) → documentos.
  final Map<String, List<Map<String, dynamic>>> documents;

  /// `_id` de media → adjuntos (`original`, `thumb`) → (bytes, tipo).
  final Map<String, Map<String, (Uint8List, String)>> attachments;
  final List<SocialPlace> places;
}

/// Lee la semilla y la vuelca en los almacenes en memoria del motor.
class SeedLoader {
  SeedLoader(this.bundle, {this.root = 'assets/seed'});

  final AssetBundle bundle;
  final String root;

  static const Map<String, String> files = {
    CouchSchema.relationships: 'relationships.json',
    CouchSchema.groups: 'groups.json',
    CouchSchema.groupMembers: 'group_members.json',
    CouchSchema.invitations: 'invitations.json',
    CouchSchema.activities: 'activities.json',
    CouchSchema.objects: 'objects.json',
    CouchSchema.media: 'media.json',
  };

  Future<List<Map<String, dynamic>>> _list(String name) async {
    final raw = await bundle.loadString('$root/$name');
    return (jsonDecode(raw) as List)
        .cast<Map>()
        .map((m) => m.cast<String, dynamic>())
        .toList();
  }

  Future<SeedData> read() async {
    final accounts = <String, String>{};
    final users = <Map<String, dynamic>>[];
    for (final u in await _list('users.json')) {
      final name = u['name'] as String;
      accounts[name] = u['password'] as String;
      users.add({
        '_id': SocialUser.idFor(name),
        'docType': DocTypes.user,
        'name': name,
        ...(u['profile'] as Map).cast<String, dynamic>(),
      });
    }
    final documents = <String, List<Map<String, dynamic>>>{
      CouchSchema.users: users,
    };
    final attachments = <String, Map<String, (Uint8List, String)>>{};
    for (final e in files.entries) {
      final docs = await _list(e.value);
      for (final d in docs) {
        final fileMap = (d.remove('_files') as Map?)?.cast<String, dynamic>();
        if (fileMap == null) continue;
        final contentType = d['contentType'] as String? ?? 'image/png';
        attachments[d['_id'] as String] = {
          for (final f in fileMap.entries)
            f.key: (
              (await bundle.load('$root/${f.value}')).buffer.asUint8List(),
              contentType,
            ),
        };
      }
      documents[e.key] = docs;
    }
    final places = (await _list(
      'places.json',
    )).map(SocialPlace.fromJson).toList();
    return SeedData(
      accounts: accounts,
      documents: documents,
      attachments: attachments,
      places: places,
    );
  }

  /// Carga [data] en [store] (vaciándolo antes) con el prefijo de [catalog].
  static Future<void> apply(
    SeedData data,
    InMemoryDocumentStore store, {
    required DatabaseCatalog catalog,
    InMemoryAuthRepository? auth,
    InMemoryPostalCodeRepository? postalCodes,
  }) async {
    store.clear();
    for (final e in data.documents.entries) {
      store.seed(catalog.resolve(e.key), e.value);
    }
    final mediaDb = catalog.media;
    for (final e in data.attachments.entries) {
      for (final a in e.value.entries) {
        await store.putAttachment(
          mediaDb,
          e.key,
          a.key,
          a.value.$1,
          contentType: a.value.$2,
        );
      }
    }
    if (auth != null) {
      data.accounts.forEach(auth.addAccount);
    }
    if (postalCodes != null) {
      data.places.forEach(postalCodes.add);
    }
  }
}
