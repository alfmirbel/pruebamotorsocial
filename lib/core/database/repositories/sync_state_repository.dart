abstract class SyncStateRepository {
  Future<Map<String, dynamic>> byPlatform(String platform);
  Future<void> upsert(Map<String, dynamic> syncState);
}
