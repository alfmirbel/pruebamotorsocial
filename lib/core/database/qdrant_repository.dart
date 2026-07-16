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

  Uri _build(String path) => Uri(scheme: scheme, host: host, port: port, path: path);

  Map<String, String> _auth() =>
      apiKey.isEmpty ? const <String, String>{} : {'api-key': apiKey};

  Future<http.Response> request(String method, String path, {Object? body}) async {
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

  Future<http.Response> upsert(String collection, Map<String, dynamic> body) async {
    return request('PUT', '/collections/$collection/points', body: body);
  }
}

abstract class QdrantRepository {
  Future<void> upsertPoints(String collection, Map<String, dynamic> payload);
}

class HttpQdrantRepository implements QdrantRepository {
  final QdrantConfig config;
  final http.Client client;

  HttpQdrantRepository({required this.config, http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<void> upsertPoints(String collection, Map<String, dynamic> payload) async {
    final res = await config.upsert(collection, payload);
    if (res.statusCode != 200 && res.statusCode != 202) {
      throw Exception('Qdrant ${res.statusCode}: ${res.reasonPhrase}');
    }
  }
}