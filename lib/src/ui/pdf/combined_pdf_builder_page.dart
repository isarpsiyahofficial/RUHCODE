import 'package:flutter/material.dart';

import '../../pdf/pdf_data_contract.dart';
import '../../pdf/pdf_report_contract.dart';
import '../actions/ruh_action_ids.dart';
import 'combined_pdf_selection_state.dart';
import 'combined_professional_pdf_ui_actions.dart';
import 'professional_pdf_ui_actions.dart';

/// Visible, accessible UI for a true multi-record professional PDF.
///
/// The page never parses persisted calculation payloads itself. Subject and
/// record choices come from [CombinedProfessionalPdfUiActions], while preview,
/// build, Save As and share always use [CombinedPdfSelectionState]'s sealed
/// preview token. Any subject/record/locale/section change invalidates it.
class CombinedProfessionalPdfBuilderPage extends StatefulWidget {
  const CombinedProfessionalPdfBuilderPage({
    super.key,
    this.actions,
    this.deliveryActions,
  });

  final CombinedProfessionalPdfUiActions? actions;
  final CombinedProfessionalPdfDeliveryActions? deliveryActions;

  @override
  State<CombinedProfessionalPdfBuilderPage> createState() =>
      _CombinedProfessionalPdfBuilderPageState();
}

class _CombinedProfessionalPdfBuilderPageState
    extends State<CombinedProfessionalPdfBuilderPage> {
  CombinedPdfSelectionState? _selection;
  List<CombinedPdfUiSubject> _subjects = const <CombinedPdfUiSubject>[];
  bool _loading = false;
  bool _busy = false;
  bool _localeInitialized = false;
  int? _builtByteLength;
  String? _error;
  String? _notice;

  CombinedProfessionalPdfUiActions? get _actions =>
      widget.actions ?? CombinedProfessionalPdfUiRuntimeBindings.actions;
  CombinedProfessionalPdfDeliveryActions? get _delivery =>
      widget.deliveryActions ?? CombinedProfessionalPdfUiRuntimeBindings.delivery;

  @override
  void initState() {
    super.initState();
    final actions = _actions;
    if (actions != null) {
      _selection = CombinedPdfSelectionState(actions: actions);
      _loadSubjects();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localeInitialized) return;
    _localeInitialized = true;
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    if (_selection != null && (language == 'tr' || language == 'en')) {
      _selection!.setLocale(language);
    }
  }

  Future<void> _loadSubjects() async {
    final actions = _actions;
    if (actions == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final subjects = await actions.listSubjects();
      if (!mounted) return;
      setState(() => _subjects = subjects);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _t(
            'Kombine rapor kayıtları yüklenemedi: $error',
            'Combined report records could not be loaded: $error',
          ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _t(String tr, String en) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'en' ? en : tr;

  String _subjectKey(CombinedPdfUiSubject subject) =>
      '${subject.subjectKind.name}:${subject.subjectId}';

  CombinedPdfUiSubject? _selectedSubject() {
    final state = _selection;
    if (state?.subjectKind == null || state?.subjectId == null) return null;
    for (final subject in _subjects) {
      if (subject.subjectKind == state!.subjectKind && subject.subjectId == state.subjectId) {
        return subject;
      }
    }
    return null;
  }

  Future<void> _selectSubject(String? key) async {
    final state = _selection;
    if (state == null || key == null) return;
    final subject = _subjects.firstWhere((item) => _subjectKey(item) == key);
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
      _builtByteLength = null;
    });
    try {
      await state.selectSubject(
        subjectKind: subject.subjectKind,
        subjectId: subject.subjectId,
      );
      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _t(
            'Kişi kayıtları yüklenemedi: $error',
            'Subject records could not be loaded: $error',
          ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Set<String> _selectedSystemIds(CombinedPdfSelectionState state) => <String>{
        for (final candidate in state.candidates)
          if (state.selectedRecordIds.contains(candidate.recordId)) candidate.calculationType,
      };

  List<ProfessionalPdfUiSectionOption> _availableSections() {
    final state = _selection;
    if (state == null) return const <ProfessionalPdfUiSectionOption>[];
    final selectedTypes = _selectedSystemIds(state);
    final byId = <String, ProfessionalPdfUiSectionOption>{};
    for (final type in selectedTypes) {
      if (!ProfessionalPdfSectionCatalog.supports(type)) continue;
      for (final option in ProfessionalPdfSectionCatalog.optionsFor(type)) {
        byId.putIfAbsent(option.id, () => option);
      }
    }
    final ordered = <ProfessionalPdfUiSectionOption>[];
    for (final id in const <String>[
      PdfSectionIds.placements,
      PdfSectionIds.houses,
      PdfSectionIds.aspects,
      PdfSectionIds.numerology,
      PdfSectionIds.technicalManifest,
    ]) {
      final option = byId[id];
      if (option != null) ordered.add(option);
    }
    return List<ProfessionalPdfUiSectionOption>.unmodifiable(ordered);
  }

  String _sectionLabel(ProfessionalPdfUiSectionOption option) => switch (option.id) {
        PdfSectionIds.placements => _t('Yerleşimler', 'Placements'),
        PdfSectionIds.houses => _t('Evler', 'Houses'),
        PdfSectionIds.aspects => _t('Açılar', 'Aspects'),
        PdfSectionIds.numerology => _t('Numeroloji', 'Numerology'),
        PdfSectionIds.technicalManifest => _t('Hesaplama Bilgileri', 'Calculation Details'),
        _ => _t(option.labelTr, option.labelTr),
      };

  void _toggleRecord(CombinedPdfUiRecord record) {
    final state = _selection!;
    setState(() {
      state.toggleRecord(record.recordId);
      _builtByteLength = null;
      _error = null;
      _notice = null;
      final sections = _availableSections().map((item) => item.id).toList(growable: false);
      if (sections.isNotEmpty) state.setSections(sections);
    });
  }

  void _toggleSection(String sectionId, bool selected) {
    final state = _selection!;
    final next = state.selectedSectionIds.toSet();
    if (selected) {
      next.add(sectionId);
    } else {
      next.remove(sectionId);
    }
    if (next.isEmpty) {
      setState(() => _error = _t(
            'En az bir rapor bölümü seçmelisin.',
            'Select at least one report section.',
          ));
      return;
    }
    setState(() {
      state.setSections(next);
      _builtByteLength = null;
      _error = null;
      _notice = null;
    });
  }

  Future<void> _preview() async {
    final state = _selection!;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
      _builtByteLength = null;
    });
    try {
      await state.createPreview();
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _t(
            'Kombine PDF önizlemesi hazırlanamadı: $error',
            'Combined PDF preview could not be prepared: $error',
          ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _build() async {
    final state = _selection!;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
      _builtByteLength = null;
    });
    try {
      final bytes = await state.build();
      if (!mounted) return;
      setState(() {
        _builtByteLength = bytes.length;
        _notice = _t('Kombine PDF doğrulandı.', 'Combined PDF validated.');
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _t(
            'Kombine PDF oluşturulamadı: $error',
            'Combined PDF could not be created: $error',
          ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fileName() {
    final subjectId = _selection?.subjectId ?? 'subject';
    final safe = subjectId.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-');
    return 'ruh-code-combined-${safe.isEmpty ? 'subject' : safe}.pdf';
  }

  Future<void> _deliver({required bool share}) async {
    final delivery = _delivery;
    final state = _selection;
    if (delivery == null || state == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final preview = state.sealedPreviewForDelivery();
      final result = share
          ? await delivery.share(preview: preview, fileName: _fileName())
          : await delivery.save(preview: preview, fileName: _fileName());
      if (!mounted) return;
      setState(() {
        _notice = switch (result.outcome) {
          CombinedPdfUiDeliveryOutcome.saved => _t('PDF cihaza kaydedildi.', 'PDF saved to device.'),
          CombinedPdfUiDeliveryOutcome.shared => _t('PDF paylaşım menüsüne aktarıldı.', 'PDF sent to the share sheet.'),
          CombinedPdfUiDeliveryOutcome.cancelled => _t('İşlem iptal edildi.', 'Action cancelled.'),
          CombinedPdfUiDeliveryOutcome.unavailable => _t('Bu cihazda işlem kullanılamıyor.', 'This action is unavailable on this device.'),
        };
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _t(
            'PDF teslim işlemi başarısız: $error',
            'PDF delivery failed: $error',
          ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _subjectLabel(CombinedPdfUiSubject subject) {
    final kind = subject.subjectKind == PdfSubjectKind.client
        ? _t('Danışan', 'Client')
        : _t('Profil', 'Profile');
    return '$kind · ${subject.subjectId} · ${subject.availableRecordCount}';
  }

  String _recordLabel(CombinedPdfUiRecord record) {
    final system = switch (record.calculationType) {
      ProfessionalPdfSectionCatalog.westernNatal => _t('Batı Astrolojisi', 'Western Astrology'),
      ProfessionalPdfSectionCatalog.pythagorean => _t('Numeroloji', 'Numerology'),
      _ => record.calculationType,
    };
    final local = record.createdAtUtc.toLocal();
    final date = '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
    return '$system · $date';
  }

  @override
  Widget build(BuildContext context) {
    final state = _selection;
    final preview = state?.preview;
    final selectedSubject = _selectedSubject();
    final sections = _availableSections();
    final selectedSystemCount = state == null ? 0 : _selectedSystemIds(state).length;
    final canPreview = state != null &&
        state.selectedRecordIds.length >= 2 &&
        selectedSystemCount >= 2 &&
        state.selectedSectionIds.isNotEmpty &&
        !_busy;
    final canDeliver = preview != null && _delivery != null && !_busy;

    return Scaffold(
      appBar: AppBar(title: Text(_t('Kombine PDF Raporu', 'Combined PDF Report'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _t(
              'Aynı profil veya danışana ait en az iki farklı hesaplama sistemini tek profesyonel raporda birleştir.',
              'Combine at least two calculation systems for the same profile or client in one professional report.',
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (_actions == null)
            Text(_t(
              'Kombine PDF kaynağı production runtime’a bağlanmadı.',
              'Combined PDF source is not bound to the production runtime.',
            ))
          else if (_loading)
            const LinearProgressIndicator()
          else if (_subjects.isEmpty)
            Text(_t(
              'Kombine rapor için aynı kişiye ait en az iki farklı sistem kaydı bulunamadı.',
              'No subject has at least two distinct persisted calculation systems for a combined report.',
            ))
          else
            Semantics(
              label: _t('Kombine PDF kişi seçimi', 'Combined PDF subject selection'),
              child: DropdownButtonFormField<String>(
                key: const ValueKey('combined-pdf-subject-selector'),
                value: selectedSubject == null ? null : _subjectKey(selectedSubject),
                decoration: InputDecoration(labelText: _t('Profil / Danışan', 'Profile / Client')),
                items: [
                  for (final subject in _subjects)
                    DropdownMenuItem<String>(
                      value: _subjectKey(subject),
                      child: Text(_subjectLabel(subject)),
                    ),
                ],
                onChanged: _busy ? null : _selectSubject,
              ),
            ),
          if (state != null && state.candidates.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(_t('Hesaplamalar', 'Calculations'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final record in state.candidates)
              Semantics(
                label: '${_recordLabel(record)} ${_t('seçimi', 'selection')}',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: CheckboxListTile(
                    key: ValueKey('combined-record-${record.recordId}'),
                    value: state.selectedRecordIds.contains(record.recordId),
                    title: Text(_recordLabel(record)),
                    subtitle: Text(record.recordId),
                    onChanged: _busy ? null : (_) => _toggleRecord(record),
                  ),
                ),
              ),
            if (state.selectedRecordIds.length >= 2 && selectedSystemCount < 2)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _t(
                    'Önizleme için iki farklı hesaplama sistemi seç.',
                    'Select two distinct calculation systems to preview.',
                  ),
                ),
              ),
          ],
          if (sections.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(_t('Rapor Bölümleri', 'Report Sections'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final section in sections)
              Semantics(
                label: _sectionLabel(section),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: CheckboxListTile(
                    key: ValueKey('combined-section-${section.id}'),
                    value: state!.selectedSectionIds.contains(section.id),
                    title: Text(_sectionLabel(section)),
                    onChanged: _busy
                        ? null
                        : (value) => _toggleSection(section.id, value == true),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          Semantics(
            label: _t('Kombine PDF Önizle', 'Preview combined PDF'),
            button: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: OutlinedButton.icon(
                key: const ValueKey(RuhActionIds.pdfCombinedPreview),
                onPressed: canPreview ? _preview : null,
                icon: const Icon(Icons.preview_outlined),
                label: Text(_t('Önizle', 'Preview')),
              ),
            ),
          ),
          if (preview != null) ...[
            const SizedBox(height: 12),
            Card(
              key: const ValueKey('combined-pdf-preview-card'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t('Kombine Rapor Önizlemesi', 'Combined Report Preview'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('${_t('Sistemler', 'Systems')}: ${preview.memberSystemIds.join(' + ')}'),
                    Text('${_t('Bölümler', 'Sections')}: ${preview.sectionIds.join(', ')}'),
                    Text('${_t('Dil', 'Language')}: ${preview.localeTag.toUpperCase()}'),
                    Text('${_t('Snapshot', 'Snapshot')}: ${preview.compositeSnapshotDigest.substring(0, 12)}…'),
                    const SizedBox(height: 8),
                    Text(_t(
                      'Kayıt, dil veya bölüm seçimi değişirse bu önizleme geçersiz olur.',
                      'Changing records, language or sections invalidates this preview.',
                    )),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Semantics(
            label: _t('Kombine PDF Oluştur', 'Create combined PDF'),
            button: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton.icon(
                key: const ValueKey(RuhActionIds.pdfCombinedCreate),
                onPressed: preview == null || _busy ? null : _build,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_busy ? _t('İşleniyor…', 'Working…') : _t('PDF Oluştur', 'Create PDF')),
              ),
            ),
          ),
          if (_builtByteLength != null) ...[
            const SizedBox(height: 8),
            Text('${_t('Doğrulanan PDF boyutu', 'Validated PDF size')}: $_builtByteLength byte'),
          ],
          if (_delivery != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: _t('Kombine PDF Kaydet', 'Save combined PDF'),
                    button: true,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: OutlinedButton.icon(
                        key: const ValueKey(RuhActionIds.pdfCombinedSave),
                        onPressed: canDeliver ? () => _deliver(share: false) : null,
                        icon: const Icon(Icons.save_alt_outlined),
                        label: Text(_t('Kaydet', 'Save')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    label: _t('Kombine PDF Paylaş', 'Share combined PDF'),
                    button: true,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: OutlinedButton.icon(
                        key: const ValueKey(RuhActionIds.pdfCombinedShare),
                        onPressed: canDeliver ? () => _deliver(share: true) : null,
                        icon: const Icon(Icons.share_outlined),
                        label: Text(_t('Paylaş', 'Share')),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_notice != null) ...[
            const SizedBox(height: 12),
            Text(_notice!),
          ],
        ],
      ),
    );
  }
}
