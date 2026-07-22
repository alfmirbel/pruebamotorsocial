import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../features/auth/pages/login_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/catalog/pages/catalog_page.dart';
import '../features/account/pages/account_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/feed/pages/feed_page.dart';
import '../features/chat/pages/chat_page.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final userId = session['userId'];
    if (userId == null || userId.isEmpty) {
      return const LoginPage(key: ValueKey('login'));
    }

    return Scaffold(
      body: const _Pages(),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _Pages extends ConsumerStatefulWidget {
  const _Pages();

  @override
  ConsumerState<_Pages> createState() => _PagesState();
}

class _PagesState extends ConsumerState<_Pages> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final current = _clamp(_index);
    return IndexedStack(
      index: current,
      children: const [
        HomePage(),
        CatalogPage(),
        FeedPage(),
        ChatPage(),
        AccountPage(),
        ProfilePage(),
      ],
    );
  }

  int _clamp(int v) {
    if (v < 0) return 0;
    if (v > 5) return 5;
    return v;
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final userId = session['userId'];
    if (userId == null || userId.isEmpty) {
      return const SizedBox.shrink();
    }

    final index = ref.watch(tabIndexProvider);

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) {
        ref.read(tabIndexProvider.notifier).state = _clamp(value);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.category), label: 'Catálogo'),
        NavigationDestination(icon: Icon(Icons.feed), label: 'Actividad'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Comunidad'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Cuenta'),
        NavigationDestination(icon: Icon(Icons.account_circle), label: 'Perfil'),
      ],
    );
  }

  int _clamp(int v) {
    if (v < 0) return 0;
    if (v > 5) return 5;
    return v;
  }
}

