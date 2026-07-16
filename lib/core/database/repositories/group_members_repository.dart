import 'package:pruebamotorsocial/motorsocial/social_graph/repositories/groups_repository.dart';
import 'package:pruebamotorsocial/motorsocial/social_graph/data_models/social_group.dart';

class InMemoryGroupMembersRepository implements GroupsRepository {
  Future<List<SocialGroup>> byGroup(String groupId) async => const <SocialGroup>[];
  Future<void> add(SocialGroup member) async {}
  Future<List<SocialGroup>> discoverable({bool? visibility, bool? joinable}) async =>
      const <SocialGroup>[];
}
