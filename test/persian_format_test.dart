import 'package:daftar_moein/data/backup_service.dart';
import 'package:daftar_moein/models/ledger_transaction.dart';
import 'package:daftar_moein/services/statement_share_service.dart';
import 'package:daftar_moein/utils/persian_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('persian_format', () {
    test('formatNumberFa uses Persian digits and ٬ separator', () {
      expect(formatNumberFa(0), '۰');
      expect(formatNumberFa(999), '۹۹۹');
      expect(formatNumberFa(1000), '۱٬۰۰۰');
      expect(formatNumberFa(1234567), '۱٬۲۳۴٬۵۶۷');
    });

    test('formatNumberEn uses , separator', () {
      expect(formatNumberEn(50000), '50,000');
    });

    test('toEnglishNumbers converts Persian and Arabic digits', () {
      expect(toEnglishNumbers('۱۲۳٤٥'), '12345');
    });

    test('Jalali display of a Gregorian date', () {
      // 2024-03-20 == 1403/01/01 (Nowruz)
      expect(formatJalaliDisplay('2024-03-20'), '۱۴۰۳/۰۱/۰۱');
      expect(formatJalaliDisplay(''), '');
    });

    test('toIsoDate / parseIsoDate round trip uses local date', () {
      final d = DateTime(2025, 1, 5);
      expect(toIsoDate(d), '2025-01-05');
      expect(parseIsoDate('2025-01-05'), d);
    });
  });

  group('statement message', () {
    test('balance sign follows web semantics', () {
      const t = [
        LedgerTransaction(
          id: '1',
          amount: 1000,
          type: TransactionType.debit,
          date: '2024-03-20',
          customerId: 'c',
          createdAt: '',
          updatedAt: '',
        ),
      ];
      final msg = StatementShareService.instance.buildMessage(t, 'علی');
      expect(msg, contains('📄 صورت‌حساب: علی'));
      expect(msg, contains('۱۴۰۳/۰۱/۰۱: ۱٬۰۰۰ تومان (طلبتان)'));
      expect(msg, contains('💰 مانده نهایی: ۱٬۰۰۰ تومان'));
      expect(msg, contains('🔵 طلبکار هستید'));
    });
  });

  group('backup parsing', () {
    test('rejects files that are not backups', () {
      expect(
        () => BackupService.instance.parseBackup(utf8.encode('{"a":1}')),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects transactions pointing to unknown customers', () {
      final json = jsonEncode({
        'app': 'daftar-moein',
        'formatVersion': 1,
        'customers': [],
        'transactions': [
          {
            'id': 't',
            'amount': 1,
            'type': 'CREDIT',
            'date': '2024-01-01',
            'description': null,
            'customerId': 'missing',
            'createdAt': 'x',
            'updatedAt': 'x',
          }
        ],
      });
      expect(
        () => BackupService.instance.parseBackup(utf8.encode(json)),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('parses a valid backup', () {
      final json = jsonEncode({
        'app': 'daftar-moein',
        'formatVersion': 1,
        'customers': [
          {
            'id': 'c',
            'name': 'n',
            'description': null,
            'phoneNumber': '0912',
            'isArchived': false,
            'createdAt': 'x',
            'updatedAt': 'x',
          }
        ],
        'transactions': [
          {
            'id': 't',
            'amount': 5000,
            'type': 'DEBIT',
            'date': '2024-01-01',
            'description': 'd',
            'customerId': 'c',
            'createdAt': 'x',
            'updatedAt': 'x',
          }
        ],
      });
      final data = BackupService.instance.parseBackup(utf8.encode(json));
      expect(data.customers.single.phoneNumber, '0912');
      expect(data.transactions.single.type, TransactionType.debit);
    });
  });
}
