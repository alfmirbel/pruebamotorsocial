import 'package:pruebamotorsocial/motorsocial/activity/activity.dart';
import 'package:pruebamotorsocial/motorsocial/catalog/catalog.dart';
import 'package:pruebamotorsocial/motorsocial/media/media.dart';
import 'package:pruebamotorsocial/motorsocial/social_graph/social_graph.dart';
import 'package:pruebamotorsocial/motorsocial/social_graph/data_models/social_relationship.dart';
import 'package:pruebamotorsocial/motorsocial/identity/identity.dart';
import 'package:pruebamotorsocial/motorsocial/security/repositories/security_repository.dart';

typedef SyncState = Map<String, dynamic>;

class DatabaseModule {
  DatabaseModule._();

  static final DatabaseModule instance = DatabaseModule._();

  final InMemoryActivitiesRepository activitiesRepository = InMemoryActivitiesRepository();
  final InMemoryGroupsRepository groupsRepository = InMemoryGroupsRepository();
  final InMemoryInvitationsRepository invitationsRepository = InMemoryInvitationsRepository();
  final InMemoryMediaRepository mediaRepository = InMemoryMediaRepository();
  final InMemoryCatalogRepository catalogRepository = InMemoryCatalogRepository();
  final InMemoryRelationshipsRepository relationshipsRepository = InMemoryRelationshipsRepository();
  final InMemorySecurityRepository securityRepository = InMemorySecurityRepository();
  final InMemoryUsersRepository usersRepository = InMemoryUsersRepository();
}

class InMemoryActivitiesRepository implements ActivityRepository {
Future<List<SocialActivity>> recentFeed(ActivityQuery query) async => const <SocialActivity>[];
Future<SocialActivity?> getById(String id) async => null;
Future<SocialActivity> create(SocialActivity activity) async => activity;
Future<void> delete(String id) async {}
}

class InMemoryGroupsRepository implements GroupsRepository {
Future<List<SocialGroup>> discoverable({bool? visibility, bool? joinable}) async =>
      const <SocialGroup>[];
}

class InMemoryInvitationsRepository implements InvitationsRepository {
Future<List<SocialInvitation>> pendingFor(String receiverId) async =>
      const <SocialInvitation>[];
Future<void> send(SocialInvitation invitation) async {}
}

class InMemoryMediaRepository implements MediaRepository {
Future<List<SocialMediaAsset>> byOwner(String ownerId) async => const <SocialMediaAsset>[];
Future<SocialMediaAsset> upload(SocialMediaAsset asset) async => asset;
Future<void> delete(String id) async {}
}

class InMemoryCatalogRepository implements CatalogRepository {
Future<List<SocialObjectQuery>> search(String query, {int limit = 20}) async =>
      const <SocialObjectQuery>[];
Future<SocialObject?> getById(String id) async => null;
Future<SocialObject> create(SocialObject object) async => object;
Future<SocialObject> update(String id, SocialObject object) async => object;
Future<void> delete(String id) async {}
}

class InMemoryRelationshipsRepository implements RelationshipsRepository {
Future<List<SocialRelationship>> byActor(String actorId, {String? status}) async =>
      const <SocialRelationship>[];
Future<List<SocialRelationship>> byOther(String otherId, {String? status}) async =>
      const <SocialRelationship>[];
}

class InMemorySecurityRepository implements SecurityRepository {
Future<List<SecurityEvent>> byUser(String userId, {DateTime? since}) async =>
      const <SecurityEvent>[];
}

class InMemoryUsersRepository implements UsersRepository {
Future<SocialUser?> findByEmail(String email) async => null;
Future<void> save(SocialUser user) async {}
}
