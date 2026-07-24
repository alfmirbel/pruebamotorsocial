import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final defines = jsonDecode(await File('defines.json').readAsString())
      as Map<String, dynamic>;
  final url = defines['COUCHDB_URL'] as String;
  final user = defines['COUCHDB_USER'] as String;
  final password = defines['COUCHDB_PASSWORD'] as String;

  final bases = <String>[
    'motorsocial_users',
    'motorsocial_relationships',
    'motorsocial_groups',
    'motorsocial_group_members',
    'motorsocial_invitations',
    'motorsocial_activities',
    'motorsocial_objects',
    'motorsocial_media',
    'motorsocial_security_events',
    'motorsocial_sync_state',
  ];

  final auth = base64.encode('$user:$password'.codeUnits);
  final headers = <String, String>{'Authorization': 'Basic $auth'};

  for (final db in bases) {
    final uri = '$url/$db';
    final res = await http.put(Uri.parse(uri), headers: headers);
    final status = res.statusCode;
    print('CREATE $db => $status');
    if (status == 201 || status == 412) {
      final designDocsUrl = '$url/$db/_design_docs';
      final docs = await http.get(Uri.parse(designDocsUrl), headers: headers);
      print('  DESIGN_DOCS ${docs.statusCode}');
    }
  }

  final all = await http.get(Uri.parse('$url/_all_dbs'), headers: headers);
  final list = (jsonDecode(all.body) as List<dynamic>)
      .whereType<String>()
      .where((e) => e.startsWith('motorsocial_'))
      .toList();
  print('FOUND DBs: ${list.length}');
}
