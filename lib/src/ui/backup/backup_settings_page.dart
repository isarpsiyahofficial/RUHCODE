import 'package:flutter/material.dart';

import '../../app/build_metadata.dart';
import '../../backup/backup_application_service.dart';
import '../../backup/backup_import_coordinator.dart';
import '../../backup/backup_service.dart';
import '../actions/ruh_action_ids.dart';
import 'backup_ui_contract.dart';

class BackupSettingsPage extends StatefulWidget {
  const BackupSettingsPage({
    super.key,
    required this.backupActions,
  });

  final BackupApplicationActions backupActions;

  @override
  State<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends State<BackupSettingsPage> {
  BackupRestoreSelection? _selection;
  bool _busy = false;

  RuhLocale get _ruhLocale =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'en'
          ? RuhLocale.en
          : RuhLocale.tr;
  BackupUiCopy get _copy => backupUiCopy[_ruhLocale]!;
  String get _localeTag => Localizations.localeOf(context).toLanguageTag();

  String _fileName(DateTime nowUtc) {
    final iso = nowUtc.toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
    return 'ruh_code_$iso.ruhcode.zip';
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    if (_busy) return null;
    setState(() => _busy = true);
    try {
      return await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _messagePhase(BackupUiPhase phase) {
    if (!mounted) return;
    final text = _copy.status(phase);
    if (text.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _export() async {
    final now = DateTime.now().toUtc();
    try {
      final result = await _run(
        () => widget.backupActions.exportAndSave(
          suggestedFileName: _fileName(now),
          appVersion: RuhCodeBuildMetadata.appVersion,
          engineVersion: RuhCodeBuildMetadata.engineVersion,
          localeTag: _localeTag,
          exportedAtUtc: now,
        ),
      );
      if (result == null) return;
      _messagePhase(phaseForSaveResult(result));
    } catch (_) {
      _messagePhase(BackupUiPhase.failed);
    }
  }

  Future<void> _pickRestore() async {
    try {
      final result = await _run(widget.backupActions.pickAndPreviewRestore);
      if (result == null) return;
      final state = stateForPickResult(result);
      setState(() => _selection = state.selection);
      _messagePhase(state.phase);
    } catch (_) {
      _messagePhase(BackupUiPhase.invalidBackup);
    }
  }

  Future<void> _apply(BackupImportMode mode) async {
    final selection = _selection;
    if (selection == null || !selection.preview.valid) return;
    try {
      final result = await _run(
        () => widget.backupActions.applyRestore(selection: selection, mode: mode),
      );
      if (result == null) return;
      _messagePhase(phaseForImportResult(result));
      if (mounted) setState(() => _selection = null);
    } catch (error) {
      _messagePhase(phaseForRestoreError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = _selection;
    final copy = _copy;
    return Scaffold(
      appBar: AppBar(title: Text(copy.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(copy.description),
          const SizedBox(height: 16),
          _BackupActionTile(
            actionId: RuhActionIds.backupExport,
            title: copy.saveLabel,
            subtitle: _ruhLocale == RuhLocale.tr
                ? 'Tüm desteklenen kayıtları tek taşınabilir yedek paketine aktar'
                : 'Export all supported records into one portable backup package',
            icon: Icons.save_alt_outlined,
            enabled: !_busy,
            onTap: _export,
          ),
          _BackupActionTile(
            actionId: RuhActionIds.backupImport,
            title: copy.chooseLabel,
            subtitle: _ruhLocale == RuhLocale.tr
                ? 'Dosyayı önce doğrula; onay vermeden mevcut verileri değiştirme'
                : 'Verify the file first; do not change existing data before confirmation',
            icon: Icons.settings_backup_restore_outlined,
            enabled: !_busy,
            onTap: _pickRestore,
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (selection != null) ...[
            const SizedBox(height: 20),
            _RestorePreviewCard(
              selection: selection,
              busy: _busy,
              copy: copy,
              locale: _ruhLocale,
              onMerge: () => _apply(BackupImportMode.merge),
              onReplace: () => _apply(BackupImportMode.replace),
            ),
          ],
        ],
      ),
    );
  }
}

class _BackupActionTile extends StatelessWidget {
  const _BackupActionTile({
    required this.actionId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String actionId;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Semantics(
        label: title,
        button: true,
        enabled: enabled,
        excludeSemantics: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: ListTile(
            key: ValueKey(actionId),
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: enabled ? onTap : null,
          ),
        ),
      ),
    );
  }
}

class _RestorePreviewCard extends StatelessWidget {
  const _RestorePreviewCard({
    required this.selection,
    required this.busy,
    required this.copy,
    required this.locale,
    required this.onMerge,
    required this.onReplace,
  });

  final BackupRestoreSelection selection;
  final bool busy;
  final BackupUiCopy copy;
  final RuhLocale locale;
  final VoidCallback onMerge;
  final VoidCallback onReplace;

  int _count(String fileName) => selection.preview.recordCounts[fileName] ?? 0;

  @override
  Widget build(BuildContext context) {
    final preview = selection.preview;
    final tr = locale == RuhLocale.tr;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr ? 'Yedek Önizleme' : 'Backup Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(selection.fileName),
            Text(tr ? 'Toplam kayıt: ${preview.totalRecords}' : 'Total records: ${preview.totalRecords}'),
            Text(tr ? 'Tablo sayısı: ${preview.recordCounts.length}' : 'Table count: ${preview.recordCounts.length}'),
            const SizedBox(height: 12),
            _PreviewCount(label: tr ? 'Profiller' : 'Profiles', count: _count('profiles.csv')),
            _PreviewCount(label: tr ? 'Danışanlar' : 'Clients', count: _count('clients.csv')),
            _PreviewCount(label: tr ? 'Danışmanlıklar' : 'Consultations', count: _count('consultations.csv')),
            _PreviewCount(label: tr ? 'Günlük Kayıtları' : 'Journal Entries', count: _count('journal_entries.csv')),
            _PreviewCount(label: tr ? 'Hesaplamalar' : 'Calculations', count: _count('calculations.csv')),
            const SizedBox(height: 12),
            if (!preview.valid) ...[
              Text(copy.status(BackupUiPhase.invalidBackup)),
              const SizedBox(height: 8),
              for (final issue in preview.issues.take(5)) Text('• ${issue.message}'),
            ] else ...[
              Text(copy.status(BackupUiPhase.previewReady)),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: busy ? null : onMerge,
                child: Text(copy.mergeLabel),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: busy ? null : onReplace,
                child: Text(copy.replaceLabel),
              ),
              const SizedBox(height: 8),
              Text(
                tr
                    ? 'Değiştir seçeneğinde işlemden önce otomatik güvenlik kopyası oluşturulur.'
                    : 'Replace creates an automatic safety snapshot before changing existing data.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewCount extends StatelessWidget {
  const _PreviewCount({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$count'),
        ],
      ),
    );
  }
}