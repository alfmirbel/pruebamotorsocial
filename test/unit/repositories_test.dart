import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pruebamotorsocial/core/motorsocial_bridge/bridge.dart';
import 'package:motorsocial/catalog/catalog.dart';
import 'package:motorsocial/activity/activity.dart';
import 'package:motorsocial/social_graph/social_graph.dart';

void main() {
  test('Repositorios en memoria responden sin error', () async {
    final container = ProviderContainer(overrides: [
      motorSocialBridgeProvider.overrideWith((_) => createMotorSocialBridge()),
    ]);

    final catalog = container.read(catalogRepositoryProvider);
    final items = await catalog.search('motor', limit: 5);
    expect(items, isA<List<SocialObjectQuery>>());

    final activity = container.read(activityRepositoryProvider);
    final feed = await activity.recentFeed(const ActivityQuery(limit: 5));
    expect(feed, isA<List<dynamic>>());

    final groupState = container.read(groupProvider);
    expect(groupState.groups, isA<List<dynamic>>());
  });
}
