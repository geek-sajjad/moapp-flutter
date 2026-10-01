import 'package:flutter/material.dart';

import '../../data/backup_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_icon.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'تمام اطلاعات (مشتریان و تراکنش‌ها) فقط روی همین گوشی ذخیره می‌شود. '
          'برای جلوگیری از از دست رفتن اطلاعات، به صورت منظم از آن فایل پشتیبان '
          'تهیه کرده و در جای امنی نگه دارید.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'ذخیره فایل پشتیبان',
          icon: AppIconName.download,
          size: AppButtonSize.lg,
          fullWidth: true,
          onPressed: _busy ? null : _export,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'بازیابی از فایل پشتیبان',
          icon: AppIconName.upload,
          variant: AppButtonVariant.outline,
          size: AppButtonSize.lg,
          fullWidth: true,
          onPressed: _busy ? null : _restore,
        ),
        const SizedBox(height: 12),
        const Text(
          'توجه: بازیابی، اطلاعات فعلی را به طور کامل جایگزین می‌کند.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.red600,
          ),
        ),
      ],
    );
  }
}
