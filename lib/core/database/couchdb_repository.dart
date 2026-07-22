import 'dart:convert';
import 'package:http/http.dart' as http;

class CouchDbConfig {
  final String scheme;
  final String host;
  final int port;
  final String username;
  final String password;
  final String prefix;

  const CouchDbConfig({
    this.scheme = 'http',
    this.host = '127.0.0.1',
    this.port = 5984,
    this.username = '',
    this.password = '',
    this.prefix = '',
  });

  factory CouchDbConfig.local() => const CouchDbConfig(
        scheme: 'http',
        host: '127.0.0.1',
        port: 5984,
        username: '',
        password: '',
        prefix: '',
      );

  Uri _build(String path) => Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: '/$prefix/$path',
      );

  Map<String, String>? _authHeader() {
    if (username.isEmpty && password.isEmpty) return null;
    final basic = base64.encode('$username:$password'.codeUnits);
    return <String, String>{'Authorization': 'Basic $basic'};
  }

  Future<http.Response> request(String method, String path,
      {Object? body, Map<String, String>? headers}) async {
    final uri = _build(path);
    final base = _authHeader() ?? const <String, String>{};
    final req = http.Request(method, uri);
    req.headers.addAll(base);
    if (headers != null) req.headers.addAll(headers);
    if (body is Map<String, dynamic>) {
      req.body = jsonEncode(body);
      req.headers['Content-Type'] = 'application/json';
    } else if (body is String) {
      req.body = body;
    }
    final streamed = await req.send();
    return http.Response.fromStream(streamed);
  }
}

class CouchDbRepository {
  final CouchDbConfig config;
  final http.Client client;

  CouchDbRepository({
    required this.config,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<bool> ping() async {
    final res = await config.request('GET', '');
    return res.statusCode == 200;
  }

  Future<bool> createDatabase(String db) async {
    final res = await config.request('PUT', db);
    return res.statusCode == 201 || res.statusCode == 412;
  }

  Future<bool> ensureDatabase(String db) async {
    if (await ping()) return await createDatabase(db);
    return false;
  }

  Future<Map<String, dynamic>> get(String db, String id) async {
    final res = await config.request('GET', '$db/$id');
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    throw _couchError(res);
  }

  Future<String> put(String db, Map<String, dynamic> doc) async {
    final id = doc['_id'] as String?;
    final path = id != null ? '$db/$id' : db;
    final res = await config.request('PUT', path, body: doc);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['id'] as String;
    }
    throw _couchError(res);
  }

  Future<void> delete(String db, String id, String rev) async {
    final res = await config.request('DELETE', '$db/$id?rev=$rev');
    if (res.statusCode != 200 && res.statusCode != 202) throw _couchError(res);
  }

  Future<Map<String, dynamic>> queryView(String db, String design, String view,
      {Map<String, String>? queryParams}) async {
    final params = <String, String>{
      if (queryParams != null) ...queryParams,
    };
    final qs = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    final res = await config.request('GET', '$db/_design/$design/_view/$view$qs');
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    throw _couchError(res);
  }

  Future<void> ensureDesignDoc(
      String db, String design, Map<String, dynamic> functions) async {
    final id = '_design/$design';
    final doc = <String, dynamic>{
      '_id': id,
      'views': <String, dynamic>{},
    };
    for (final entry in functions.entries) {
      (doc['views'] as Map<String, dynamic>)[entry.key] = <String, String>{
        'map': entry.value as String,
      };
    }
    await config.request('PUT', db, body: doc);
  }

  Future<Map<String, dynamic>> query(String db, String view,
      {String? key, String? startKey, String? endKey, bool descending = false, int? limit}) async {
    final params = <String, String>{
      if (key != null) 'key': key,
      if (startKey != null) 'startkey': startKey,
      if (endKey != null) 'endkey': endKey,
      'descending': descending ? 'true' : 'false',
    };
    return queryView(db, '_design/motorsocial_guide', view, queryParams: params);
  }

  Exception _couchError(http.Response res) =>
      Exception('CouchDB ${res.statusCode}: ${res.reasonPhrase}\n${res.body}');
}
