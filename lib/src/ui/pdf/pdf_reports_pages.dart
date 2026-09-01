import 'package:flutter/material.dart';

import '../../entitlements/feature_access_guard.dart';
import '../../entitlements/feature_catalog.dart';
import '../../pdf/pdf_preflight_preview.dart';
import '../../pdf/pdf_report_contract.dart';
import '../actions/ruh_action_ids.dart';
import 'professional_pdf_ui_actions.dart';

class PdfReportsHubPage extends StatelessWidget {
  const PdfReportsHubPage({
    super.key,
    required this.featureAccess,
    this.professionalActions,
    this.professionalRecords,
    this.professionalDelivery,
  });

  final FeatureAccessGuard featureAccess;
  final ProfessionalPdfBuildActions? professionalActions;
  final ProfessionalPdfRecordActions? professionalRecords;
  final ProfessionalPdfDeliveryActions? professionalDelivery;

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
                page: ProfessionalPdfBuilderPage(
                  actions: professionalActions,
                  records: professionalRecords,
                  deliveryActions: professionalDelivery,
                ),
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
  const ProfessionalPdfBuilderPage({
    super.key,
    this.actions,
    this.records,
    this.deliveryActions,
  });

  final ProfessionalPdfBuildActions? actions;
  final ProfessionalPdfRecordActions? records;
  final ProfessionalPdfDeliveryActions? deliveryActions;

  @override
  State<ProfessionalPdfBuilderPage> createState() => _ProfessionalPdfBuilderPageState();
}

class _ProfessionalPdfBuilderPageState extends State<ProfessionalPdfBuilderPage> {
  final _selected = <String>{};
  bool _busy = false;
  bool _loadingRecords = false;
  bool _deliveryBusy = false;
  List<ProfessionalPdfUiRecord> _records = const <ProfessionalPdfUiRecord>[];
  String? _selectedRecordId;
  ProfessionalPdfUiBuildResult? _result;
  _ProfessionalPdfPlanDraft? _previewDraft;
  String? _error;
  String? _deliveryNotice;

  ProfessionalPdfRecordActions? get _recordActions =>
      widget.records ?? ProfessionalPdfUiRuntimeBindings.records;
  ProfessionalPdfBuildActions? get _buildActions =>
      widget.actions ?? ProfessionalPdfUiRuntimeBindings.build;
  ProfessionalPdfDeliveryActions? get _deliveryActions =>
      widget.deliveryActions ?? ProfessionalPdfUiRuntimeBindings.delivery;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  ProfessionalPdfUiRecord _selectedRecord() {
    final recordId = _selectedRecordId;
    if (recordId == null) {
      throw const FormatException('Önce kayıtlı bir hesaplama seç.');
    }
    return _records.firstWhere(
      (record) => record.recordId == recordId,
      orElse: () => throw StateError('Seçilen hesaplama artık mevcut değil.'),
    );
  }

  List<ProfessionalPdfUiSectionOption> _sectionOptionsForSelectedRecord() {
    return ProfessionalPdfSectionCatalog.optionsFor(_selectedRecord().calculationType);
  }

  List<String> _selectedSectionIds() {
    final options = _sectionOptionsForSelectedRecord();
    return <String>[
      for (final option in options)
        if (_selected.contains(option.id)) option.id,
    ];
  }

  void _selectRecord(String? recordId) {
    _selectedRecordId = recordId;
    _selected.clear();
    if (recordId != null) {
      final record = _records.firstWhere((item) => item.recordId == recordId);
      _selected.addAll(
        ProfessionalPdfSectionCatalog.optionsFor(record.calculationType).map((item) => item.id),
      );
    }
    _invalidatePlan();
    _error = null;
  }

  String _canonicalLocaleTag() {
    final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
    if (languageCode != 'tr' && languageCode != 'en') {
      throw FormatException('Desteklenmeyen PDF dili: $languageCode');
    }
    return languageCode;
  }

  PdfReportKind _reportKindFor(String calculationType) {
    return switch (calculationType.trim()) {
      ProfessionalPdfSectionCatalog.westernNatal => PdfReportKind.western,
      ProfessionalPdfSectionCatalog.pythagorean => PdfReportKind.numerology,
      _ => throw UnsupportedError(
          'Bu hesaplama türü için production PDF handler hazır değil: $calculationType',
        ),
    };
  }

  _ProfessionalPdfPlanDraft _createPlanDraft() {
    final record = _selectedRecord();
    final supported = ProfessionalPdfSectionCatalog.optionsFor(record.calculationType);
    final supportedIds = supported.map((item) => item.id).toSet();
    final sectionIds = _selectedSectionIds();
    if (sectionIds.isEmpty) {
      throw const FormatException('En az bir rapor bölümü seçmelisin.');
    }
    if (sectionIds.any((id) => !supportedIds.contains(id))) {
      throw StateError('Seçilen rapor bölümleri production handler sözleşmesiyle uyuşmuyor.');
    }
    final localeTag = _canonicalLocaleTag();
    final plan = const PdfReportPlanner().build(
      request: PdfReportRequest(
        kind: _reportKindFor(record.calculationType),
        dataOrigin: PdfDataOrigin.user,
        localeTag: localeTag,
        coverStyle: PdfCoverStyle.professional,
        requestedSectionIds: sectionIds,
      ),
      availableSections: <PdfSectionInput>[
        const PdfSectionInput(id: PdfSectionIds.cover, hasContent: true),
        for (final id in supportedIds) PdfSectionInput(id: id, hasContent: true),
      ],
    );
    return _ProfessionalPdfPlanDraft(
      recordId: record.recordId,
      calculationType: record.calculationType,
      localeTag: localeTag,
      requestedSectionIds: List<String>.unmodifiable(sectionIds),
      preview: const PdfPreflightPreviewBuilder().fromPlan(plan),
    );
  }

  void _invalidatePlan() {
    _previewDraft = null;
    _result = null;
    _deliveryNotice = null;
  }

  Future<void> _loadRecords() async {
    final source = _recordActions;
    if (source == null) return;
    setState(() {
      _loadingRecords = true;
      _error = null;
    });
    try {
      final records = await source.listRecords();
      final supportedRecords = records
          .where((record) => ProfessionalPdfSectionCatalog.supports(record.calculationType))
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _records = List<ProfessionalPdfUiRecord>.unmodifiable(supportedRecords);
        if (_selectedRecordId != null &&
            !_records.any((record) => record.recordId == _selectedRecordId)) {
          _selectedRecordId = null;
          _selected.clear();
          _invalidatePlan();
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _records = const <ProfessionalPdfUiRecord>[];
        _selectedRecordId = null;
        _selected.clear();
        _invalidatePlan();
        _error = 'Kayıtlı hesaplamalar yüklenemedi: $error';
      });
    } finally {
      if (mounted) setState(() => _loadingRecords = false);
    }
  }

  void _previewPdf() {
    try {
      final draft = _createPlanDraft();
      setState(() {
        _previewDraft = draft;
        _result = null;
        _error = null;
        _deliveryNotice = null;
      });
    } catch (error) {
      setState(() {
        _previewDraft = null;
        _result = null;
        _error = 'PDF önizlemesi hazırlanamadı: $error';
      });
    }
  }

  Future<void> _buildPdf() async {
    final actions = _buildActions;
    if (actions == null) {
      setState(() {
        _result = null;
        _error = 'PDF üretim kaynağı henüz production runtime’a bağlanmadı.';
      });
      return;
    }

    _ProfessionalPdfPlanDraft currentDraft;
    try {
      currentDraft = _createPlanDraft();
    } catch (error) {
      setState(() {
        _result = null;
        _error = 'PDF oluşturulamadı: $error';
      });
      return;
    }
    final previewDraft = _previewDraft;
    if (previewDraft == null || !previewDraft.sameBuildInputAs(currentDraft)) {
      setState(() {
        _result = null;
        _error = 'PDF oluşturmadan önce güncel rapor planını Önizle.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _result = null;
      _error = null;
      _deliveryNotice = null;
    });
    try {
      final result = await actions.build(
        recordId: previewDraft.recordId,
        localeTag: previewDraft.localeTag,
        sectionIds: previewDraft.requestedSectionIds,
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

  Future<void> _sharePdf() async {
    final delivery = _deliveryActions;
    final draft = _previewDraft;
    if (delivery == null || draft == null || _result == null) return;
    setState(() {
      _deliveryBusy = true;
      _deliveryNotice = null;
      _error = null;
    });
    try {
      final result = await delivery.share(
        recordId: draft.recordId,
        localeTag: draft.localeTag,
        sectionIds: draft.requestedSectionIds,
      );
      if (!mounted) return;
      setState(() {
        _deliveryNotice = switch (result.outcome) {
          ProfessionalPdfUiDeliveryOutcome.success => 'PDF paylaşım menüsüne aktarıldı.',
          ProfessionalPdfUiDeliveryOutcome.cancelled => 'Paylaşım iptal edildi.',
          ProfessionalPdfUiDeliveryOutcome.unavailable => 'Bu cihazda PDF paylaşımı kullanılamıyor.',
        };
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'PDF paylaşılamadı: $error');
    } finally {
      if (mounted) setState(() => _deliveryBusy = false);
    }
  }

  String _recordLabel(ProfessionalPdfUiRecord record) {
    final local = record.createdAtUtc.toLocal();
    final date = '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
    return '${record.calculationType} · $date';
  }

  String _kindLabel(PdfReportKind kind) => switch (kind) {
        PdfReportKind.western => 'Batı Astrolojisi',
        PdfReportKind.vedic => 'Vedik Astroloji',
        PdfReportKind.numerology => 'Numeroloji',
        PdfReportKind.bazi => 'BaZi',
        PdfReportKind.combined => 'Birleşik',
        PdfReportKind.sample => 'Örnek',
      };

  String _sectionLabel(_ProfessionalPdfPlanDraft draft, String id) {
    if (id == PdfSectionIds.cover) return 'Kapak';
    for (final option in ProfessionalPdfSectionCatalog.optionsFor(draft.calculationType)) {
      if (option.id == id) return option.labelTr;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final previewDraft = _previewDraft;
    final recordSourceAvailable = _recordActions != null;
    final deliveryAvailable = _deliveryActions != null;
    final selectedRecord = _selectedRecordId == null
        ? null
        : _records.where((item) => item.recordId == _selectedRecordId).firstOrNull;
    final sectionOptions = selectedRecord == null
        ? const <ProfessionalPdfUiSectionOption>[]
        : ProfessionalPdfSectionCatalog.optionsFor(selectedRecord.calculationType);

    return Scaffold(
      appBar: AppBar(title: const Text('Profesyonel PDF Oluştur')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_loadingRecords)
            const LinearProgressIndicator()
          else if (!recordSourceAvailable)
            const Text('Kayıtlı hesaplama seçicisi henüz production runtime’a bağlanmadı.')
          else if (_records.isEmpty)
            const Text('PDF için desteklenen kayıtlı hesaplama bulunamadı.')
          else
            DropdownButtonFormField<String>(
              key: const ValueKey('professional-pdf-record-selector'),
              initialValue: _selectedRecordId,
              decoration: const InputDecoration(
                labelText: 'Kayıtlı Hesaplama',
                helperText: 'PDF yalnız seçtiğin kayıt snapshot’ından oluşturulur.',
              ),
              items: [
                for (final record in _records)
                  DropdownMenuItem<String>(
                    value: record.recordId,
                    child: Text(_recordLabel(record)),
                  ),
              ],
              onChanged: _busy || _deliveryBusy
                  ? null
                  : (value) => setState(() => _selectRecord(value)),
            ),
          const SizedBox(height: 20),
          Text('Rapor Bölümleri', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (selectedRecord == null)
            const Text('Kullanılabilir rapor bölümlerini görmek için kayıtlı bir hesaplama seç.')
          else
            for (final section in sectionOptions)
              CheckboxListTile(
                value: _selected.contains(section.id),
                title: Text(section.labelTr),
                subtitle: Text(section.descriptionTr),
                onChanged: _busy || _deliveryBusy
                    ? null
                    : (value) => setState(() {
                          if (value == true) {
                            _selected.add(section.id);
                          } else {
                            _selected.remove(section.id);
                          }
                          _invalidatePlan();
                          _error = null;
                        }),
              ),
          const SizedBox(height: 12),
          Semantics(
            label: 'PDF Önizle',
            button: true,
            excludeSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: OutlinedButton.icon(
                key: const ValueKey(RuhActionIds.pdfPreflight),
                onPressed: _busy || _loadingRecords || _deliveryBusy || selectedRecord == null
                    ? null
                    : _previewPdf,
                icon: const Icon(Icons.preview_outlined),
                label: const Text('Önizle'),
              ),
            ),
          ),
          if (previewDraft != null) ...[
            const SizedBox(height: 12),
            Card(
              key: const ValueKey('professional-pdf-preflight-preview'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rapor Önizlemesi', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('${_kindLabel(previewDraft.preview.kind)} · ${previewDraft.preview.localeTag.toUpperCase()}'),
                    Text('A4 · ${previewDraft.preview.pageSpec.widthMm.toInt()} × ${previewDraft.preview.pageSpec.heightMm.toInt()} mm'),
                    const SizedBox(height: 8),
                    for (final id in previewDraft.preview.sectionIds)
                      Text('• ${_sectionLabel(previewDraft, id)}'),
                    const SizedBox(height: 8),
                    const Text('PDF, bu önizlemede gösterilen aynı kayıt ve bölüm sırasıyla oluşturulur.'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Semantics(
            label: 'PDF Oluştur',
            button: true,
            excludeSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton.icon(
                key: const ValueKey(RuhActionIds.pdfCreate),
                onPressed: _busy || _loadingRecords || _deliveryBusy || previewDraft == null
                    ? null
                    : _buildPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_busy ? 'Oluşturuluyor…' : 'PDF Oluştur'),
              ),
            ),
          ),
          if (previewDraft == null) ...[
            const SizedBox(height: 8),
            const Text('PDF oluşturmadan önce güncel rapor planını önizle.'),
          ],
          if (_busy || _deliveryBusy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('PDF doğrulandı'),
                subtitle: Text('${result.pageCount} sayfa · ${result.byteLength} byte'),
              ),
            ),
            if (deliveryAvailable) ...[
              const SizedBox(height: 8),
              Semantics(
                label: 'PDF Paylaş',
                button: true,
                excludeSemantics: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: OutlinedButton.icon(
                    key: const ValueKey(RuhActionIds.pdfShare),
                    onPressed: _deliveryBusy ? null : _sharePdf,
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Paylaş'),
                  ),
                ),
              ),
            ],
          ],
          if (_deliveryNotice != null) ...[
            const SizedBox(height: 12),
            Text(_deliveryNotice!),
          ],
          const SizedBox(height: 12),
          const Text('Profesyonel rapor, seçilen gerçek hesaplama kaydının aynı calculation snapshot kimliğini kullanır.'),
        ],
      ),
    );
  }
}

final class _ProfessionalPdfPlanDraft {
  const _ProfessionalPdfPlanDraft({
    required this.recordId,
    required this.calculationType,
    required this.localeTag,
    required this.requestedSectionIds,
    required this.preview,
  });

  final String recordId;
  final String calculationType;
  final String localeTag;
  final List<String> requestedSectionIds;
  final PdfPreflightPreview preview;

  bool sameBuildInputAs(_ProfessionalPdfPlanDraft other) {
    if (recordId != other.recordId ||
        calculationType != other.calculationType ||
        localeTag != other.localeTag) {
      return false;
    }
    if (requestedSectionIds.length != other.requestedSectionIds.length) return false;
    for (var i = 0; i < requestedSectionIds.length; i++) {
      if (requestedSectionIds[i] != other.requestedSectionIds[i]) return false;
    }
    return true;
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
