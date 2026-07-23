import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final defines = jsonDecode(await File('defines.json').readAsString()) as Map<String, dynamic>;
  final url = defines['COUCHDB_URL'] as String;
  final user = defines['COUCHDB_USER'] as String;
  final password = defines['COUCHDB_PASSWORD'] as String;

  final auth = base64.encode('$user:$password'.codeUnits);
  final headers = <String, String>{'Authorization': 'Basic $auth'};

  final Map<String, Map<String, String>> designDocs = {
    'motorsocial_users': {
      'by_email': "function (doc) { if (doc.value && doc.value.email) emit(doc.value.email.toLowerCase(), {id: doc._id, rev: doc._rev, displayName: doc.value.displayName}); }",
      'by_createdAt': "function (doc) { if (doc.value && doc.value.createdAt) emit(doc.value.createdAt, doc._id); }",
    },
    'motorsocial_relationships': {
      'by_actor_status': "function (doc) { if (doc.actorId) emit([doc.actorId, doc.status], {id: doc._id, otherId: doc.otherId, direction: doc.direction, createdAt: doc.createdAt}); }",
      'by_other_status': "function (doc) { if (doc.otherId) emit([doc.otherId, doc.status], {id: doc._id, actorId: doc.actorId, direction: doc.direction, createdAt: doc.createdAt}); }",
      'by_direction_createdAt': "function (doc) { if (doc.direction) emit([doc.actorId, doc.direction, doc.createdAt], doc._id); }",
    },
    'motorsocial_groups': {
      'by_owner': "function (doc) { if (doc.ownerId) emit(doc.ownerId, {id: doc._id, name: doc.name, visibility: doc.visibility, joinable: doc.joinable}); }",
      'by_visibility_joinable': "function (doc) { emit([doc.visibility || 'public', String(doc.joinable)], doc._id); }",
      'by_createdAt': "function (doc) { if (doc.createdAt) emit(doc.createdAt, doc._id); }",
    },
    'motorsocial_group_members': {
      'by_group_user': "function (doc) { if (doc.groupId && doc.userId) emit([doc.groupId, doc.userId], {role: doc.role, joinedAt: doc.joinedAt}); }",
      'by_user': "function (doc) { if (doc.userId) emit(doc.userId, {groupId: doc.groupId, role: doc.role, joinedAt: doc.joinedAt}); }",
      'by_group_role': "function (doc) { if (doc.groupId) emit([doc.groupId, doc.role], doc.userId); }",
    },
    'motorsocial_invitations': {
      'by_receiver_status': "function (doc) { if (doc.receiverId) emit([doc.receiverId, doc.status], {id: doc._id, senderId: doc.senderId, type: doc.type, objectId: doc.objectId, createdAt: doc.createdAt}); }",
      'by_sender': "function (doc) { if (doc.senderId) emit([doc.senderId, doc.createdAt], {id: doc._id, status: doc.status, type: doc.type}); }",
      'by_object': "function (doc) { if (doc.objectId) emit([doc.objectId, doc.createdAt], doc._id); }",
    },
    'motorsocial_activities': {
      'by_actor_createdAt': "function (doc) { if (doc.actorId) emit([doc.actorId, doc.createdAt], {id: doc._id, verb: doc.verb, objectType: doc.objectType, objectId: doc.objectId, targetId: doc.targetId}); }",
      'by_verb_createdAt': "function (doc) { if (doc.verb) emit([doc.verb, doc.createdAt], {id: doc._id, actorId: doc.actorId, objectType: doc.objectType}); }",
      'by_object_createdAt': "function (doc) { if (doc.objectId) emit([doc.objectType, doc.objectId, doc.createdAt], doc._id); }",
      'by_target_createdAt': "function (doc) { if (doc.targetId) emit([doc.targetId, doc.createdAt], {id: doc._id, verb: doc.verb, actorId: doc.actorId}); }",
    },
    'motorsocial_objects': {
      'by_creator_type_status': "function (doc) { emit([doc.creatorId, doc.type, doc.status], {id: doc._id, attributes: doc.attributes, labels: doc.labels, location: doc.location, mediaIds: doc.mediaIds, createdAt: doc.createdAt}); }",
      'by_type_status_createdAt': "function (doc) { emit([doc.type, doc.status, doc.createdAt], {id: doc._id, creatorId: doc.creatorId}); }",
      'by_labels': "function (doc) { if (doc.labels) for (let k in doc.labels) emit([k, doc.labels[k]], doc._id); }",
      'by_location': "function (doc) { if (doc.location) emit([doc.location.country, doc.location.city, doc.createdAt], doc._id); }",
    },
    'motorsocial_media': {
      'by_owner_createdAt': "function (doc) { if (doc.ownerId) emit([doc.ownerId, doc.createdAt], doc._id); }",
      'by_asset_type': "function (doc) { if (doc.assetType) emit(doc.assetType, doc._id); }",
    },
    'motorsocial_security_events': {
      'by_user_createdAt': "function (doc) { if (doc.userId) emit([doc.userId, doc.createdAt], {id: doc._id, eventType: doc.eventType}); }",
      'by_type_createdAt': "function (doc) { emit([doc.eventType, doc.createdAt], doc._id); }",
    },
    'motorsocial_sync_state': {
      'by_platform_lastSync': "function (doc) { if (doc.platform) emit([doc.platform, doc.lastSyncAt], {id: doc._id, status: doc.status}); }",
    },
  };

  for (final entry in designDocs.entries) {
    final db = entry.key;
    final views = entry.value;
    final designId = '_design/${db.replaceFirst('motorsocial_', '')}';
    final doc = <String, dynamic>{
      '_id': designId,
      'views': <String, dynamic>{},
    };
    for (final viewEntry in views.entries) {
      (doc['views'] as Map<String, dynamic>)[viewEntry.key] = <String, String>{'map': viewEntry.value};
    }

    final res = await http.put(
      Uri.parse('$url/$db/$designId'),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(doc),
    );
    print('DESIGN $db/$designId => ${res.statusCode}');
    final queryRes = await http.get(
      Uri.parse('$url/$db/$designId/_view/${views.keys.first}'),
      headers: headers,
    );
    print('  QUERY ${views.keys.first} => ${queryRes.statusCode}');
  }
}
