import 'package:flutter/material.dart';

import '../../entitlements/feature_access_guard.dart';
import '../../entitlements/feature_catalog.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.featureAccess,
  });

  final FeatureAccessGuard featureAccess;

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
      _ToolsPage(featureAccess: widget.featureAccess),
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

class _ToolDefinition {
  const _ToolDefinition({
    required this.title,
    required this.icon,
    required this.featureId,
  });

  final String title;
  final IconData icon;
  final String featureId;
}

class _ToolsPage extends StatelessWidget {
  const _ToolsPage({required this.featureAccess});

  final FeatureAccessGuard featureAccess;

  static const tools = <_ToolDefinition>[
    _ToolDefinition(title: 'Batı Astrolojisi', icon: Icons.auto_awesome_outlined, featureId: RuhFeatureIds.westernNatalBasic),
    _ToolDefinition(title: 'Vedik Astroloji', icon: Icons.brightness_4_outlined, featureId: RuhFeatureIds.vedicBasic),
    _ToolDefinition(title: 'Gezegen Saatleri', icon: Icons.schedule_outlined, featureId: RuhFeatureIds.planetaryHours),
    _ToolDefinition(title: 'Numeroloji', icon: Icons.pin_outlined, featureId: RuhFeatureIds.numerologyBasic),
    _ToolDefinition(title: 'BaZi', icon: Icons.grid_4x4_outlined, featureId: RuhFeatureIds.baziBasic),
  ];

  Future<void> _openTool(BuildContext context, _ToolDefinition tool) async {
    final decision = await featureAccess.forRoute(tool.featureId);
    if (!context.mounted) return;
    if (!decision.allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu araç için PRO erişimi gerekiyor.')),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _FeaturePlaceholderPage(
          title: tool.title,
          featureId: tool.featureId,
          featureAccess: featureAccess,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Araçlar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Kullanmak istediğin aracı seç.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        for (final tool in tools)
          Card(
            child: ListTile(
              leading: Icon(tool.icon),
              title: Text(tool.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openTool(context, tool),
            ),
          ),
      ],
    );
  }
}

class _FeaturePlaceholderPage extends StatelessWidget {
  const _FeaturePlaceholderPage({
    required this.title,
    required this.featureId,
    required this.featureAccess,
  });

  final String title;
  final String featureId;
  final FeatureAccessGuard featureAccess;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FeatureAccessDecision>(
      future: featureAccess.forUi(featureId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final allowed = snapshot.hasData && snapshot.data!.allowed;
        if (!allowed) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: const Center(child: Text('Bu özellik kilitli.')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: Text(
              '$title ekranı',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        );
      },
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
