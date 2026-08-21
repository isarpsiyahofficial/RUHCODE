import 'package:flutter/material.dart';

import '../../entitlements/feature_access_guard.dart';
import '../../entitlements/feature_catalog.dart';
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
      _RecordsPage(featureAccess: widget.featureAccess),
      _ProfilePage(featureAccess: widget.featureAccess),
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
    required this.title,
    required this.icon,
    required this.featureId,
    this.lockedMessage = 'Bu özellik için PRO erişimi gerekiyor.',
  });

  final String title;
  final IconData icon;
  final String featureId;
  final String lockedMessage;
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

  static const tools = <_FeatureDefinition>[
    _FeatureDefinition(title: 'Batı Astrolojisi', icon: Icons.auto_awesome_outlined, featureId: RuhFeatureIds.westernNatalBasic),
    _FeatureDefinition(title: 'Vedik Astroloji', icon: Icons.brightness_4_outlined, featureId: RuhFeatureIds.vedicBasic),
    _FeatureDefinition(title: 'Gezegen Saatleri', icon: Icons.schedule_outlined, featureId: RuhFeatureIds.planetaryHours),
    _FeatureDefinition(title: 'Numeroloji', icon: Icons.pin_outlined, featureId: RuhFeatureIds.numerologyBasic),
    _FeatureDefinition(title: 'BaZi', icon: Icons.grid_4x4_outlined, featureId: RuhFeatureIds.baziBasic),
    _FeatureDefinition(title: 'Gelişmiş Batı Analizi', icon: Icons.insights_outlined, featureId: RuhFeatureIds.westernAdvanced),
  ];

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
              onTap: () => _openGuardedFeature(
                context,
                featureAccess: featureAccess,
                feature: tool,
              ),
            ),
          ),
      ],
    );
  }
}

class _RecordsPage extends StatelessWidget {
  const _RecordsPage({required this.featureAccess});

  final FeatureAccessGuard featureAccess;

  static const professionalClients = _FeatureDefinition(
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
        const Card(
          child: ListTile(
            leading: Icon(Icons.person_pin_outlined),
            title: Text('Profillerim'),
            subtitle: Text('Kayıtlı kişisel profiller'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Danışanlarım'),
            subtitle: const Text('Profesyonel danışan çalışma alanı'),
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
  const _ProfilePage({required this.featureAccess});

  final FeatureAccessGuard featureAccess;

  static const pdfPreview = _FeatureDefinition(
    title: 'PDF Rapor Önizleme',
    icon: Icons.preview_outlined,
    featureId: RuhFeatureIds.pdfSamplePreview,
  );
  static const pdfExport = _FeatureDefinition(
    title: 'Profesyonel PDF Raporu',
    icon: Icons.picture_as_pdf_outlined,
    featureId: RuhFeatureIds.pdfProfessionalExport,
    lockedMessage: 'Profesyonel PDF oluşturmak için PRO erişimi gerekiyor.',
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.preview_outlined),
            title: const Text('PDF Rapor Önizleme'),
            subtitle: const Text('Örnek raporun nasıl görüneceğini incele'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openGuardedFeature(
              context,
              featureAccess: featureAccess,
              feature: pdfPreview,
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Profesyonel PDF Raporu'),
            subtitle: const Text('Kendi verilerinle profesyonel rapor oluştur'),
            trailing: const Icon(Icons.lock_outline),
            onTap: () => _openGuardedFeature(
              context,
              featureAccess: featureAccess,
              feature: pdfExport,
            ),
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
