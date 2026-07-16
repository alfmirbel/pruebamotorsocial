import 'package:pruebamotorsocial/motorsocial/media/media.dart';

abstract class MediaRepository {
  Future<List<SocialMediaAsset>> byOwner(String ownerId);
}
