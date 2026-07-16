import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionProvider = StateProvider<Map<String, String?>>((_) {
  return <String, String?>{'userId': null, 'token': null};
});

final tabIndexProvider = StateProvider<int>((_) => 0);
