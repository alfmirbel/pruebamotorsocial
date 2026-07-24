import 'dart:convert';

import 'package:http/http.dart' as http;

class QdrantConfig {
  final String scheme;
  final String host;
  final int port;
  final String apiKey;

  const QdrantConfig({
    this.scheme = 'http',
    this.host = '127.0.0.1',
    this.port = 6333,
    this.apiKey = '',
  });

  factory QdrantConfig.local() => const QdrantConfig(
        scheme: 'http',
        host: '100.82.190.54',
        port: 6333,
        apiKey: '',
      );

  Uri _build(String path) =>
      Uri(scheme: scheme, host: host, port: port, path: path);

  Map<String, String> _auth() =>
      apiKey.isEmpty ? const <String, String>{} : {'api-key': apiKey};

  Future<http.Response> request(String method, String path,
      {Object? body}) async {
    final uri = _build(path);
    final req = http.Request(method, uri);
    req.headers.addAll(_auth());
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

class QdrantRepository {
  final QdrantConfig config;
  final http.Client client;

  QdrantRepository({required this.config, http.Client? client})
      : client = client ?? http.Client();

  Future<bool> createCollection(
      String collection, int size, String distance) async {
    final res = await config.request(
      'PUT',
      '/collections/$collection',
      body: {
        'vectors': {'size': size, 'distance': distance},
      },
    );
    return res.statusCode == 200 || res.statusCode == 202;
  }

  Future<bool> ensureCollection(
      String collection, int size, String distance) async {
    final res = await config.request('GET', '/collections/$collection');
    if (res.statusCode == 200) return true;
    return await createCollection(collection, size, distance);
  }

  Future<void> upsertPoints(
      String collection, Map<String, dynamic> payload) async {
    final res = await config.request(
      'PUT',
      '/collections/$collection/points',
      body: payload,
    );
    if (res.statusCode != 200 && res.statusCode != 202) {
      throw Exception(
          'Qdrant ${res.statusCode}: ${res.reasonPhrase}\n${res.body}');
    }
  }

  Future<Map<String, dynamic>> search(
      String collection, Map<String, dynamic> body) async {
    final res = await config.request(
      'POST',
      '/collections/$collection/points/search',
      body: body,
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception(
        'Qdrant ${res.statusCode}: ${res.reasonPhrase}\n${res.body}');
  }
}
