import 'package:flutter/material.dart';

import '../../entitlements/feature_access_guard.dart';
import '../../entitlements/feature_catalog.dart';
import '../actions/ruh_action_ids.dart';
import '../numerology/numerology_screen.dart';

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
    NavigationDestination(
      icon: KeyedSubtree(
        key: ValueKey(RuhActionIds.navigationToday),
        child: Icon(Icons.wb_sunny_outlined),
      ),
      selectedIcon: Icon(Icons.wb_sunny),
      label: 'Bugün',
    ),
    NavigationDestination(
      icon: KeyedSubtree(
        key: ValueKey(RuhActionIds.navigationTools),
        child: Icon(Icons.grid_view_outlined),
      ),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'Araçlar',
    ),
    NavigationDestination(
      icon: KeyedSubtree(
        key: ValueKey(RuhActionIds.navigationRecords),
        child: Icon(Icons.book_outlined),
      ),
      selectedIcon: Icon(Icons.book),
      label: 'Kayıtlar',
    ),
    NavigationDestination(
      icon: KeyedSubtree(
        key: ValueKey(RuhActionIds.navigationProfile),
        child: Icon(Icons.person_outline),
      ),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _PlaceholderPage(title: 'Bugün'),
      _ToolsPage(featureAccess: widget.featureAccess),
      _RecordsPage(featureAccess: widget.featureAccess),
      const _ProfilePage(),
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

class _FeatureDefinition {
  const _FeatureDefinition({
    required this.actionId,
    required this.title,
    required this.icon,
    required this.featureId,
    this.lockedMessage = 'Bu özellik için PRO erişimi gerekiyor.',
  });

  final String actionId;
  final String title;
  final IconData icon;
  final String featureId;
  final String lockedMessage;
}

class _CategoryDefinition {
  const _CategoryDefinition({
    required this.actionId,
    required this.title,
    required this.icon,
  });

  final String actionId;
  final String title;
  final IconData icon;
}

class _ActionListTile extends StatelessWidget {
  const _ActionListTile({
    required this.actionId,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final String actionId;
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      button: true,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: ListTile(
          key: ValueKey(actionId),
          leading: Icon(icon),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: trailing ?? const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

Future<void> _openGuardedFeature(
  BuildContext context, {
  required FeatureAccessGuard featureAccess,
  required _FeatureDefinition feature,
}) async {
  final decision = await featureAccess.forRoute(feature.featureId);
  if (!context.mounted) return;
  if (!decision.allowed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(feature.lockedMessage)),
    );
    return;
  }
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => _buildFeatureScreen(
        feature: feature,
        featureAccess: featureAccess,
      ),
    ),
  );
}

Future<void> _pushPage(BuildContext context, Widget page) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}

Widget _buildFeatureScreen({
  required _FeatureDefinition feature,
  required FeatureAccessGuard featureAccess,
}) {
  if (feature.featureId == RuhFeatureIds.numerologyBasic) {
    // The profile/calculation flow is not wired yet. Showing the real empty
    // state is preferable to fabricating sample results or recalculating in UI.
    return const NumerologyScreen(model: null);
  }
  return _FeaturePlaceholderPage(
    title: feature.title,
    featureId: feature.featureId,
    featureAccess: featureAccess,
  );
}

class _ToolsPage extends StatelessWidget {
  const _ToolsPage({required this.featureAccess});

  final FeatureAccessGuard featureAccess;

  static const categories = <_CategoryDefinition>[
    _CategoryDefinition(
      actionId: RuhActionIds.toolsAstrology,
      title: 'Astroloji',
      icon: Icons.auto_awesome_outlined,
    ),
    _CategoryDefinition(
      actionId: RuhActionIds.toolsNumerology,
      title: 'Numeroloji',
      icon: Icons.pin_outlined,
    ),
    _CategoryDefinition(
      actionId: RuhActionIds.toolsSpiritual,
      title: 'Spiritüel',
      icon: Icons.self_improvement_outlined,
    ),
    _CategoryDefinition(
      actionId: RuhActionIds.toolsGrowth,
      title: 'Kişisel Gelişim',
      icon: Icons.trending_up_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Araçlar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Çalışmak istediğin alanı seç.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        for (final category in categories)
          Card(
            child: _ActionListTile(
              actionId: category.actionId,
              title: category.title,
              icon: category.icon,
              onTap: () {
                if (category.actionId == RuhActionIds.toolsAstrology) {
                  _pushPage(context, _AstrologyHubPage(featureAccess: featureAccess));
                  return;
                }
                if (category.actionId == RuhActionIds.toolsNumerology) {
                  _openGuardedFeature(
                    context,
                    featureAccess: featureAccess,
                    feature: const _FeatureDefinition(
                      actionId: RuhActionIds.toolsNumerology,
                      title: 'Numeroloji',
                      icon: Icons.pin_outlined,
                      featureId: RuhFeatureIds.numerologyBasic,
                    ),
                  );
                  return;
                }
                _pushPage(context, _SimpleHubPage(title: category.title));
              },
            ),
          ),
      ],
    );
  }
}

class _AstrologyHubPage extends StatelessWidget {
  const _AstrologyHubPage({required this.featureAccess});

  final FeatureAccessGuard featureAccess;

  static const features = <_FeatureDefinition>[
    _FeatureDefinition(
      actionId: RuhActionIds.astrologyWestern,
      title: 'Batı Astrolojisi',
      icon: Icons.auto_awesome_outlined,
      featureId: RuhFeatureIds.westernNatalBasic,
    ),
    _FeatureDefinition(
      actionId: RuhActionIds.astrologyVedic,
      title: 'Vedik Astroloji',
      icon: Icons.brightness_4_outlined,
      featureId: RuhFeatureIds.vedicBasic,
    ),
    _FeatureDefinition(
      actionId: RuhActionIds.astrologyChinese,
      title: 'Çin Astrolojisi',
      icon: Icons.public_outlined,
      featureId: RuhFeatureIds.chineseBasic,
    ),
    _FeatureDefinition(
      actionId: RuhActionIds.astrologyBazi,
      title: 'BaZi',
      icon: Icons.grid_4x4_outlined,
      featureId: RuhFeatureIds.baziBasic,
    ),
    _FeatureDefinition(
      actionId: RuhActionIds.astrologyPlanetaryHours,
      title: 'Gezegen Saatleri',
      icon: Icons.schedule_outlined,
      featureId: RuhFeatureIds.planetaryHours,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Astroloji')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Astroloji araçları', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          for (final feature in features)
            Card(
              child: _ActionListTile(
                actionId: feature.actionId,
                title: feature.title,
                icon: feature.icon,
                onTap: () => _openGuardedFeature(
                  context,
                  featureAccess: featureAccess,
                  feature: feature,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecordsPage extends StatelessWidget {
  const _RecordsPage({required this.featureAccess});

  final FeatureAccessGuard featureAccess;

  static const personalProfiles = _FeatureDefinition(
    actionId: RuhActionIds.recordsProfiles,
    title: 'Profillerim',
    icon: Icons.person_pin_outlined,
    featureId: RuhFeatureIds.personalProfiles,
  );

  static const professionalClients = _FeatureDefinition(
    actionId: RuhActionIds.recordsClients,
    title: 'Danışanlarım',
    icon: Icons.groups_outlined,
    featureId: RuhFeatureIds.professionalClients,
    lockedMessage: 'Danışan çalışma alanı PRO kullanıcılar içindir.',
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Kayıtlar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Kendi kayıtların ve profesyonel çalışma alanın.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Card(
          child: _ActionListTile(
            actionId: RuhActionIds.recordsProfiles,
            title: 'Profillerim',
            subtitle: 'Kayıtlı kişisel profiller',
            icon: Icons.person_pin_outlined,
            onTap: () => _openGuardedFeature(
              context,
              featureAccess: featureAccess,
              feature: personalProfiles,
            ),
          ),
        ),
        Card(
          child: _ActionListTile(
            actionId: RuhActionIds.recordsClients,
            title: 'Danışanlarım',
            subtitle: 'Profesyonel danışan çalışma alanı',
            icon: Icons.groups_outlined,
            trailing: const Icon(Icons.lock_outline),
            onTap: () => _openGuardedFeature(
              context,
              featureAccess: featureAccess,
              feature: professionalClients,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Card(
          child: _ActionListTile(
            actionId: RuhActionIds.profileSettings,
            title: 'Ayarlar',
            subtitle: 'Dil, bildirimler, gizlilik, yedekleme ve raporlar',
            icon: Icons.settings_outlined,
            onTap: () => _pushPage(context, const _SettingsPlaceholderPage()),
          ),
        ),
      ],
    );
  }
}

class _SettingsPlaceholderPage extends StatelessWidget {
  const _SettingsPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: const Center(child: Text('Ayarlar')),
    );
  }
}

class _SimpleHubPage extends StatelessWidget {
  const _SimpleHubPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title alanı',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
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
