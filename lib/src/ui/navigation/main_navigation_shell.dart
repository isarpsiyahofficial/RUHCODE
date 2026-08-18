import 'package:flutter/material.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _index = 0;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny), label: 'Bugün'),
    NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Araçlar'),
    NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Kayıtlar'),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _PlaceholderPage(title: 'Bugün'),
      const _ToolsPage(),
      const _PlaceholderPage(title: 'Kayıtlar'),
      const _PlaceholderPage(title: 'Profil'),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: _destinations,
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _ToolsPage extends StatelessWidget {
  const _ToolsPage();

  @override
  Widget build(BuildContext context) {
    const tools = <(String, IconData)>[
      ('Astroloji', Icons.auto_awesome_outlined),
      ('Numeroloji', Icons.pin_outlined),
      ('Spiritüel', Icons.spa_outlined),
      ('Kişisel Gelişim', Icons.track_changes_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Araçlar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Ne yapmak istediğini seç.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        for (final tool in tools)
          Card(
            child: ListTile(
              leading: Icon(tool.$2),
              title: Text(tool.$1),
              trailing: const Icon(Icons.chevron_right),
              enabled: false,
            ),
          ),
      ],
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: Theme.of(context).textTheme.headlineMedium));
  }
}
