import 'package:flutter/material.dart';

import '../../entitlements/feature_access_guard.dart';
import '../../entitlements/feature_catalog.dart';
import '../actions/ruh_action_ids.dart';

class PdfReportsHubPage extends StatelessWidget {
  const PdfReportsHubPage({
    super.key,
    required this.featureAccess,
  });

  final FeatureAccessGuard featureAccess;

  Future<void> _open(
    BuildContext context, {
    required String featureId,
    required Widget page,
    required String lockedMessage,
  }) async {
    final decision = await featureAccess.forRoute(featureId);
    if (!context.mounted) return;
    if (!decision.allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lockedMessage)),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Raporları')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Raporu önce örnek olarak inceleyebilir, PRO ile kendi kayıtlarından profesyonel PDF oluşturabilirsin.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Card(
            child: _PdfActionTile(
              actionId: RuhActionIds.pdfPreview,
              title: 'Örnek PDF Önizle',
              subtitle: 'Gerçek kullanıcı verisi içermeyen örnek raporu görüntüle',
              icon: Icons.visibility_outlined,
              onTap: () => _open(
                context,
                featureId: RuhFeatureIds.pdfSamplePreview,
                page: const PdfSamplePreviewPage(),
                lockedMessage: 'Örnek PDF önizlemesi kullanılamıyor.',
              ),
            ),
          ),
          Card(
            child: _PdfActionTile(
              actionId: RuhActionIds.pdfBuild,
              title: 'Profesyonel PDF Oluştur',
              subtitle: 'Kayıtlı hesaplamandan rapor bölümlerini hazırla',
              icon: Icons.picture_as_pdf_outlined,
              trailing: const Icon(Icons.lock_outline),
              onTap: () => _open(
                context,
                featureId: RuhFeatureIds.pdfProfessionalExport,
                page: const ProfessionalPdfBuilderPage(),
                lockedMessage: 'Profesyonel PDF oluşturma PRO kullanıcılar içindir.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PdfSamplePreviewPage extends StatelessWidget {
  const PdfSamplePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Örnek PDF Önizleme')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ÖRNEK RAPOR', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                Text('Doğum Haritası Raporu', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('Bu önizleme yalnız rapor düzenini gösterir; kişisel veri içermez.'),
                const Divider(height: 32),
                const _PreviewSection(title: 'Özet Bakış', lines: ['Temel göstergeler', 'Kısa rapor özeti']),
                const _PreviewSection(title: 'Harita', lines: ['Vektörel harita alanı', 'Yerleşim özeti']),
                const _PreviewSection(title: 'Yorum', lines: ['Seçilen rapor bölümleri', 'Profesyonel not alanı']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalPdfBuilderPage extends StatelessWidget {
  const ProfessionalPdfBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profesyonel PDF Oluştur')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Rapor Bölümleri', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const _BuilderSection(title: 'Harita', description: 'Hesaplama kaydına bağlı harita ve temel göstergeler'),
          const _BuilderSection(title: 'Yerleşimler', description: 'Hesaplanan yerleşim ve tablo bilgileri'),
          const _BuilderSection(title: 'Yorum', description: 'Seçilen yorum ve açıklama bölümleri'),
          const _BuilderSection(title: 'Notlar', description: 'Profesyonelin rapora eklediği notlar'),
          const SizedBox(height: 12),
          const Text('Profesyonel rapor, seçilen gerçek hesaplama kaydının aynı calculation snapshot kimliğini kullanır.'),
        ],
      ),
    );
  }
}

class _PdfActionTile extends StatelessWidget {
  const _PdfActionTile({
    required this.actionId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  final String actionId;
  final String title;
  final String subtitle;
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
          subtitle: Text(subtitle),
          trailing: trailing ?? const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final line in lines) Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $line'),
          ),
        ],
      ),
    );
  }
}

class _BuilderSection extends StatelessWidget {
  const _BuilderSection({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}