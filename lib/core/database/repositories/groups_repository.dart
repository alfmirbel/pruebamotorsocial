import 'package:pruebamotorsocial/motorsocial/social_graph/social_graph.dart';

abstract class GroupsRepository {
  Future<List<SocialGroup>> discoverable({String? visibility, bool? joinable});
}
