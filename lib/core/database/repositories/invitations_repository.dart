import 'package:pruebamotorsocial/motorsocial/social_graph/repositories/invitations_repository.dart';
import 'package:pruebamotorsocial/motorsocial/social_graph/data_models/social_invitation.dart';

class InMemoryInvitationsRepository implements InvitationsRepository {
  @override
  Future<List<SocialInvitation>> pendingFor(String receiverId) async => const <SocialInvitation>[];
  @override
  Future<void> send(SocialInvitation invitation) async {}
}
