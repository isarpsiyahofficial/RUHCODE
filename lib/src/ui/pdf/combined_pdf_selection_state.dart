import '../../pdf/pdf_data_contract.dart';
import 'combined_professional_pdf_ui_actions.dart';

/// Deterministic state controller for a multi-record professional PDF UI.
///
/// Any input that contributes to the sealed preview token invalidates that
/// preview immediately. Build or native delivery is allowed only when current
/// record/locale/section state is byte-for-byte equivalent to the preview input.
final class CombinedPdfSelectionState {
  CombinedPdfSelectionState({required this.actions});

  final CombinedProfessionalPdfUiActions actions;

  PdfSubjectKind? _subjectKind;
  String? _subjectId;
  String _localeTag = 'tr';
  List<CombinedPdfUiRecord> _candidates = const <CombinedPdfUiRecord>[];
  final Set<String> _selectedRecordIds = <String>{};
  final Set<String> _selectedSectionIds = <String>{};
  CombinedPdfUiPreview? _preview;

  PdfSubjectKind? get subjectKind => _subjectKind;
  String? get subjectId => _subjectId;
  String get localeTag => _localeTag;
  List<CombinedPdfUiRecord> get candidates => _candidates;
  Set<String> get selectedRecordIds => Set<String>.unmodifiable(_selectedRecordIds);
  Set<String> get selectedSectionIds => Set<String>.unmodifiable(_selectedSectionIds);
  CombinedPdfUiPreview? get preview => _preview;

  Future<void> selectSubject({
    required PdfSubjectKind subjectKind,
    required String subjectId,
  }) async {
    final normalized = _required(subjectId, 'subjectId');
    _subjectKind = subjectKind;
    _subjectId = normalized;
    _candidates = await actions.listCandidates(
      subjectKind: subjectKind,
      subjectId: normalized,
    );
    _selectedRecordIds.clear();
    _selectedSectionIds.clear();
    _preview = null;
  }

  void setLocale(String value) {
    final language = value.trim().split(RegExp('[-_]')).first.toLowerCase();
    if (language != 'tr' && language != 'en') {
      throw FormatException('Unsupported combined PDF locale: $value');
    }
    if (_localeTag == language) return;
    _localeTag = language;
    _preview = null;
  }

  void toggleRecord(String recordId) {
    final id = _required(recordId, 'recordId');
    if (!_candidates.any((item) => item.recordId == id)) {
      throw FormatException('Record is not available for the selected subject: $id');
    }
    if (!_selectedRecordIds.add(id)) {
      _selectedRecordIds.remove(id);
    }
    _preview = null;
  }

  void setSections(Iterable<String> sectionIds) {
    final next = <String>{};
    for (final raw in sectionIds) {
      final id = _required(raw, 'sectionId');
      if (!next.add(id)) throw FormatException('Duplicate section ID: $id');
    }
    if (next.isEmpty) {
      throw const FormatException('Combined PDF requires at least one section.');
    }
    _selectedSectionIds
      ..clear()
      ..addAll(next);
    _preview = null;
  }

  Future<CombinedPdfUiPreview> createPreview() async {
    if (_subjectKind == null || _subjectId == null) {
      throw const StateError('Select a subject before combined PDF preview.');
    }
    if (_selectedRecordIds.length < 2) {
      throw const StateError('Select at least two calculation records.');
    }
    final selectedSystems = <String>{
      for (final candidate in _candidates)
        if (_selectedRecordIds.contains(candidate.recordId)) candidate.calculationType,
    };
    if (selectedSystems.length < 2) {
      throw const StateError('Combined PDF requires at least two distinct calculation systems.');
    }
    if (_selectedSectionIds.isEmpty) {
      throw const StateError('Select at least one combined PDF section.');
    }
    final preview = await actions.preview(
      recordIds: _orderedSelectedRecordIds(),
      localeTag: _localeTag,
      sectionIds: _selectedSectionIds.toList(growable: false),
    );
    if (preview.subjectKind != _subjectKind || preview.subjectId != _subjectId) {
      throw const StateError('Combined PDF preview subject drift detected.');
    }
    _preview = preview;
    return preview;
  }

  /// Returns the exact sealed preview only when the current selection still
  /// matches it. Native Save As/share must call this before delivery so it
  /// cannot bypass preview invalidation rules.
  CombinedPdfUiPreview sealedPreviewForDelivery() => _validateCurrentPreview();

  Future<List<int>> build() {
    final current = _validateCurrentPreview();
    return actions.build(preview: current);
  }

  CombinedPdfUiPreview _validateCurrentPreview() {
    final current = _preview;
    if (current == null) {
      throw const StateError('Create a current combined PDF preview before build.');
    }
    if (current.localeTag != _localeTag ||
        current.subjectKind != _subjectKind ||
        current.subjectId != _subjectId ||
        !_sameSet(current.recordIds, _selectedRecordIds) ||
        !_sameSet(current.sectionIds.where((id) => id != 'cover'), _selectedSectionIds)) {
      _preview = null;
      throw const StateError('Combined PDF selection changed after preview.');
    }
    return current;
  }

  List<String> _orderedSelectedRecordIds() => <String>[
        for (final candidate in _candidates)
          if (_selectedRecordIds.contains(candidate.recordId)) candidate.recordId,
      ];

  static String _required(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty) throw ArgumentError.value(value, name, 'Must not be blank.');
    return normalized;
  }

  static bool _sameSet(Iterable<String> a, Iterable<String> b) {
    final left = a.toSet();
    final right = b.toSet();
    return left.length == right.length && left.containsAll(right);
  }
}
