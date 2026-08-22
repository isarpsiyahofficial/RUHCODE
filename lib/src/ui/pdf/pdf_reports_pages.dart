import 'package:flutter/material.dart';

import '../../entitlements/feature_access_guard.dart';
import '../../entitlements/feature_catalog.dart';
import '../actions/ruh_action_ids.dart';
import 'professional_pdf_ui_actions.dart';

class PdfReportsHubPage extends StatelessWidget {
  const PdfReportsHubPage({
    super.key,
    required this.featureAccess,
    this.professionalActions,
  });

  final FeatureAccessGuard featureAccess;
  final ProfessionalPdfBuildActions? professionalActions;

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
                page: ProfessionalPdfBuilderPage(actions: professionalActions),
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

  static const samplePersonLabel = 'Örnek Kişi — Demo Profil';

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
                const Chip(
                  avatar: Icon(Icons.science_outlined, size: 18),
                  label: Text(samplePersonLabel),
                ),
                const SizedBox(height: 8),
                const Text('Bu önizleme yalnız rapor düzenini gösterir; kişisel veri içermez.'),
                const Text('Demo içerik gerçek bir kullanıcı, danışan veya kayıtla ilişkilendirilmez.'),
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

class ProfessionalPdfBuilderPage extends StatefulWidget {
  const ProfessionalPdfBuilderPage({super.key, this.actions});

  final ProfessionalPdfBuildActions? actions;

  @override
  State<ProfessionalPdfBuilderPage> createState() => _ProfessionalPdfBuilderPageState();
}

class _ProfessionalPdfBuilderPageState extends State<ProfessionalPdfBuilderPage> {
  final _recordController = TextEditingController();
  final _selected = <String>{'chart', 'placements', 'interpretation', 'notes'};
  bool _busy = false;
  ProfessionalPdfUiBuildResult? _result;
  String? _error;

  static const _sections = <(String, String, String)>[
    ('chart', 'Harita', 'Hesaplama kaydına bağlı harita ve temel göstergeler'),
    ('placements', 'Yerleşimler', 'Hesaplanan yerleşim ve tablo bilgileri'),
    ('interpretation', 'Yorum', 'Seçilen yorum ve açıklama bölümleri'),
    ('notes', 'Notlar', 'Profesyonelin rapora eklediği notlar'),
  ];

  @override
  void dispose() {
    _recordController.dispose();
    super.dispose();
  }

  Future<void> _buildPdf() async {
    final actions = widget.actions;
    if (actions == null) {
      setState(() {
        _result = null;
        _error = 'PDF üretim kaynağı henüz production runtime’a bağlanmadı.';
      });
      return;
    }
    if (_recordController.text.trim().isEmpty) {
      setState(() {
        _result = null;
        _error = 'Önce rapor oluşturulacak kayıt kimliğini seç.';
      });
      return;
    }
    if (_selected.isEmpty) {
      setState(() {
        _result = null;
        _error = 'En az bir rapor bölümü seçmelisin.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _result = null;
      _error = null;
    });
    try {
      final result = await actions.build(
        recordId: _recordController.text.trim(),
        localeTag: Localizations.localeOf(context).toLanguageTag(),
        sectionIds: [for (final section in _sections) if (_selected.contains(section.$1)) section.$1],
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'PDF oluşturulamadı: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profesyonel PDF Oluştur')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _recordController,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Hesaplama Kaydı',
              hintText: 'Kayıt kimliği',
              helperText: 'PDF yalnız seçtiğin kayıt snapshot’ından oluşturulur.',
            ),
          ),
          const SizedBox(height: 20),
          Text('Rapor Bölümleri', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          for (final section in _sections)
            CheckboxListTile(
              value: _selected.contains(section.$1),
              title: Text(section.$2),
              subtitle: Text(section.$3),
              onChanged: _busy
                  ? null
                  : (value) => setState(() {
                        if (value == true) {
                          _selected.add(section.$1);
                        } else {
                          _selected.remove(section.$1);
                        }
                      }),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('ACTION-PDF-PREVIEW-CREATE'),
            onPressed: _busy ? null : _buildPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(_busy ? 'Oluşturuluyor…' : 'PDF Oluştur'),
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_result case final result?) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('PDF doğrulandı'),
                subtitle: Text('${result.pageCount} sayfa · ${result.byteLength} byte'),
              ),
            ),
          ],
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
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $line'),
            ),
        ],
      ),
    );
  }
}
