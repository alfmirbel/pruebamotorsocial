import 'package:pruebamotorsocial/motorsocial/identity/identity.dart';

abstract class UsersRepository {
  Future<SocialUser?> findByEmail(String email);
  Future<void> save(SocialUser user);
}
