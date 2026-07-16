import 'package:pruebamotorsocial/motorsocial/catalog/catalog.dart';

abstract class ObjectsRepository {
  Future<List<SocialObject>> search(SocialObjectQuery query);
}
