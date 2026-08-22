import 'package:flutter/material.dart';

import '../../app/build_metadata.dart';
import '../../backup/backup_application_service.dart';
import '../../backup/backup_import_coordinator.dart';
import '../../backup/backup_service.dart';
import '../actions/ruh_action_ids.dart';

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

  void _message(String text) {
    if (!mounted) return;
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
      if (result.status == BackupUserOperationStatus.cancelled) {
        _message('Yedekleme iptal edildi.');
      } else {
        _message('Tam yedek başarıyla kaydedildi.');
      }
    } catch (_) {
      _message('Tam yedek oluşturulamadı. Mevcut veriler değiştirilmedi.');
    }
  }

  Future<void> _pickRestore() async {
    try {
      final result = await _run(widget.backupActions.pickAndPreviewRestore);
      if (result == null) return;
      if (result.status == BackupUserOperationStatus.cancelled) {
        _message('Yedek seçimi iptal edildi.');
        return;
      }
      final selection = result.selection;
      if (selection == null) {
        _message('Yedek dosyası okunamadı.');
        return;
      }
      setState(() => _selection = selection);
      if (!selection.preview.valid) {
        _message('Bu yedek doğrulanamadı. Mevcut veriler değiştirilmedi.');
      }
    } catch (_) {
      _message('Yedek dosyası doğrulanamadı. Mevcut veriler değiştirilmedi.');
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
      _message(
        mode == BackupImportMode.merge
            ? '${result.importedRecordCount} kayıt yedekten birleştirildi.'
            : '${result.importedRecordCount} kayıt yedekten geri yüklendi.',
      );
      if (mounted) setState(() => _selection = null);
    } on BackupRestoreException catch (error) {
      if (error.rollbackRestored) {
        _message('Geri yükleme başarısız oldu; önceki veriler güvenlik kopyasından geri getirildi.');
      } else {
        _message('Geri yükleme ve güvenlik kopyasını geri alma başarısız oldu. Veri bütünlüğü kontrol edilmeli.');
      }
    } catch (_) {
      _message('Yedekten geri yükleme başarısız oldu.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = _selection;
    return Scaffold(
      appBar: AppBar(title: const Text('Yedekleme ve Aktarma')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tam yedek, Ruh Code verilerini taşınabilir .ruhcode.zip paketi olarak cihazında tutar. Sunucu hesabı gerekmez.',
          ),
          const SizedBox(height: 16),
          _BackupActionTile(
            actionId: RuhActionIds.backupExport,
            title: 'Tam Yedek Oluştur',
            subtitle: 'Tüm desteklenen kayıtları tek taşınabilir yedek paketine aktar',
            icon: Icons.save_alt_outlined,
            enabled: !_busy,
            onTap: _export,
          ),
          _BackupActionTile(
            actionId: RuhActionIds.backupImport,
            title: 'Yedekten Geri Yükle',
            subtitle: 'Dosyayı önce doğrula ve içeriği görmeden verileri değiştirme',
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
    required this.onMerge,
    required this.onReplace,
  });

  final BackupRestoreSelection selection;
  final bool busy;
  final VoidCallback onMerge;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final preview = selection.preview;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yedek Önizleme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(selection.fileName),
            Text('Toplam kayıt: ${preview.totalRecords}'),
            Text('Tablo sayısı: ${preview.recordCounts.length}'),
            const SizedBox(height: 12),
            if (!preview.valid) ...[
              const Text('Yedek doğrulanamadı. Hiçbir veri değiştirilmedi.'),
              const SizedBox(height: 8),
              for (final issue in preview.issues.take(5)) Text('• ${issue.message}'),
            ] else ...[
              const Text('Yedek doğrulandı. Nasıl geri yükleneceğini seç:'),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: busy ? null : onMerge,
                child: const Text('Birleştir'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: busy ? null : onReplace,
                child: const Text('Mevcut Veriyi Değiştir'),
              ),
              const SizedBox(height: 8),
              const Text('Değiştir seçeneğinde işlemden önce otomatik güvenlik kopyası oluşturulur.'),
            ],
          ],
        ),
      ),
    );
  }
}