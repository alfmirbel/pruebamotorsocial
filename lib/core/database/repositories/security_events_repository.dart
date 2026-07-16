import 'package:pruebamotorsocial/motorsocial/security/data_models/security_event.dart';

abstract class SecurityEventsRepository {
  Future<List<SecurityEvent>> byUser(String userId, {DateTime? since});
}
