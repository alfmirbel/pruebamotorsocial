import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pruebamotorsocial/motorsocial/navigation/data_models/menu_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.category,
      'label': 'Catálogo',
      'route': '/catalog',
    },
    {
      'icon': Icons.print,
      'label': 'Actividad',
      'route': '/activity',
    },
    {
      'icon': Icons.group,
      'label': 'Comunidad',
      'route': '/social_graph',
    },
    {
      'icon': Icons.person,
      'label': 'Perfil',
      'route': '/profile',
    },
    {
      'icon': Icons.login,
      'label': 'Login',
      'route': '/login',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MotorSocial'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return Card(
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  Navigator.of(context).pushNamed(item['route'] as String),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData,
                        size: 20, color: colorScheme.primary),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
