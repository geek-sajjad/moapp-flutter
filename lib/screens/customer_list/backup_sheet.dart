import 'package:flutter/material.dart';

import '../../data/backup_service.dart';
import '../../theme/app_icons.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/confirm_dialog.dart';

/// Content of the "backup & restore" modal.
/// Calls [onRestored] after data has been replaced from a backup file.
class BackupSheet extends StatefulWidget {
  final VoidCallback onRestored;

  const BackupSheet({super.key, required this.onRestored});

  @override
  State<BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends State<BackupSheet> {
  final _alert = AlertService.instance;
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final saved = await BackupService.instance.exportBackup();
      if (saved) {
        _alert.showSuccess('فایل پشتیبان با موفقیت ذخیره شد.');
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error exporting backup: $e');
      _alert.showError('خطا در ایجاد فایل پشتیبان');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    try {
      final data = await BackupService.instance.pickBackup();
      if (data == null || !mounted) return;

      final confirmed = await showConfirmDialog(
        context: context,
        message:
            'با بازیابی، تمام اطلاعات فعلی حذف و اطلاعات فایل پشتیبان '
            '(${data.customers.length} مشتری و ${data.transactions.length} تراکنش) '
            'جایگزین می‌شود. آیا مطمئن هستید؟',
        confirmText: 'بله، بازیابی شود',
      );
      if (!confirmed) return;

      await BackupService.instance.restore(data);
      _alert.showSuccess('اطلاعات با موفقیت بازیابی شد.');
      widget.onRestored();
      if (mounted) Navigator.of(context).pop();
    } on BackupFormatException catch (e) {
      _alert.showError(e.message, duration: const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      _alert.showError('خطا در بازیابی اطلاعات');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card.filled(
          color: scheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(AppIcons.info, color: scheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'تمام اطلاعات (مشتریان و تراکنش‌ها) فقط روی همین گوشی ذخیره می‌شود. '
                    'برای جلوگیری از از دست رفتن اطلاعات، به صورت منظم از آن فایل پشتیبان '
                    'تهیه کرده و در جای امنی نگه دارید.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_busy) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
        ],
        FilledButton.icon(
          onPressed: _busy ? null : _export,
          icon: const Icon(AppIcons.download),
          label: const Text('ذخیره فایل پشتیبان'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _busy ? null : _restore,
          icon: const Icon(AppIcons.upload),
          label: const Text('بازیابی از فایل پشتیبان'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(AppIcons.warning, size: 18, color: scheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'توجه: بازیابی، اطلاعات فعلی را به طور کامل جایگزین می‌کند.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
