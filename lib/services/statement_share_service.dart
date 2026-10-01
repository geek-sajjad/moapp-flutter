import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/ledger_transaction.dart';
import '../utils/persian_format.dart';

/// Port of `ExportService.shareStatement`.
class StatementShareService {
  StatementShareService._();

  static final StatementShareService instance = StatementShareService._();

  String buildMessage(List<LedgerTransaction> transactions, String personName) {
    var total = 0;
    final message = StringBuffer()
      ..write('📄 صورت‌حساب: $personName\n')
      ..write('📅 تاریخ: ${currentJalaliDateFa()}\n')
      ..write('--------------------------\n');

    for (final t in transactions) {
      final jalaliDate = formatJalaliDisplay(t.date);
      final amount = formatNumberFa(t.amount);
      final type = t.type == TransactionType.debit ? 'طلبتان' : 'بدهی‌تان';
      message.write('$jalaliDate: $amount تومان ($type)\n');
      total += t.type == TransactionType.debit ? t.amount : -t.amount;
    }

    message
      ..write('--------------------------\n')
      ..write('💰 مانده نهایی: ${formatNumberFa(total.abs())} تومان\n')
      ..write(total >= 0 ? '🔵 طلبکار هستید' : '🔴 بدهکار هستید')
      ..write('\n\n+دفتر معین شخصی+');

    return message.toString();
  }

  /// Opens the SMS app (if a phone number exists) or the system share sheet.
  Future<void> shareStatement(
    List<LedgerTransaction> transactions,
    String personName, {
    String? phoneNumber,
  }) async {
    if (transactions.isEmpty) return;

    final message = buildMessage(transactions, personName);
    final phone = phoneNumber?.replaceAll(RegExp(r'\s'), '') ?? '';

    if (phone.isNotEmpty) {
      final smsUri =
          Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
      try {
        if (await launchUrl(smsUri)) return;
      } catch (_) {
        // Fall through to the share sheet.
      }
    }

    await SharePlus.instance.share(
      ShareParams(text: message, subject: 'صورت‌حساب'),
    );
  }
}
