import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../models/customer.dart';
import '../models/ledger_transaction.dart';
import 'app_database.dart';

class BackupFormatException implements Exception {
  final String message;
  BackupFormatException(this.message);

  @override
  String toString() => message;
}

/// Parsed, validated contents of a backup file.
class BackupData {
  final List<Customer> customers;
  final List<LedgerTransaction> transactions;

  const BackupData(this.customers, this.transactions);
}

/// Offline backup / restore of the whole database as a single JSON file.
///
/// File format (version 1):
/// ```json
/// {
///   "app": "daftar-moein",
///   "formatVersion": 1,
///   "exportedAt": "2026-10-01T10:00:00.000Z",
///   "customers": [ { "id", "name", "description", "phoneNumber",
///                    "isArchived", "createdAt", "updatedAt" } ],
///   "transactions": [ { "id", "amount", "type", "date", "description",
///                       "customerId", "createdAt", "updatedAt" } ]
/// }
/// ```
class BackupService {
  BackupService._();

  static final BackupService instance = BackupService._();

  static const _appId = 'daftar-moein';
  static const _formatVersion = 1;

  /// Builds the backup and asks the user where to save it.
  /// Returns `false` if the user cancelled the save dialog.
  Future<bool> exportBackup() async {
    final db = await AppDatabase.instance.database;
    final customerRows = await db.query('customers', orderBy: 'created_at ASC');
    final transactionRows =
        await db.query('transactions', orderBy: 'created_at ASC');

    final data = {
      'app': _appId,
      'formatVersion': _formatVersion,
      'exportedAt': nowIso(),
      'customers':
          customerRows.map((r) => Customer.fromRow(r).toJson()).toList(),
      'transactions': transactionRows
          .map((r) => LedgerTransaction.fromRow(r).toJson())
          .toList(),
    };

    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(data)),
    );

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'ذخیره فایل پشتیبان',
      fileName: _backupFileName(),
      bytes: bytes,
    );
    return path != null;
  }

  /// Lets the user pick a backup file and parses / validates it.
  /// Returns `null` if the user cancelled the picker.
  /// Throws [BackupFormatException] if the file is not a valid backup.
  Future<BackupData?> pickBackup() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'انتخاب فایل پشتیبان',
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final bytes = result.files.single.bytes;
    if (bytes == null) {
      throw BackupFormatException('خواندن فایل امکان‌پذیر نیست.');
    }
    return parseBackup(bytes);
  }

  BackupData parseBackup(List<int> bytes) {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      throw BackupFormatException('فایل انتخاب شده یک فایل پشتیبان معتبر نیست.');
    }

    if (decoded is! Map<String, dynamic> || decoded['app'] != _appId) {
      throw BackupFormatException('فایل انتخاب شده یک فایل پشتیبان معتبر نیست.');
    }

    final version = decoded['formatVersion'];
    if (version is! int || version > _formatVersion) {
      throw BackupFormatException(
        'نسخه فایل پشتیبان پشتیبانی نمی‌شود. لطفاً برنامه را به‌روزرسانی کنید.',
      );
    }

    try {
      final customers = (decoded['customers'] as List)
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
      final transactions = (decoded['transactions'] as List)
          .map((e) => LedgerTransaction.fromJson(e as Map<String, dynamic>))
          .toList();

      final customerIds = customers.map((c) => c.id).toSet();
      if (customerIds.length != customers.length ||
          transactions.any((t) => !customerIds.contains(t.customerId))) {
        throw const FormatException('Inconsistent data');
      }

      return BackupData(customers, transactions);
    } catch (_) {
      throw BackupFormatException('اطلاعات فایل پشتیبان ناقص یا خراب است.');
    }
  }

  /// Replaces ALL current data with the backup contents, atomically.
  Future<void> restore(BackupData data) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('customers');

      final batch = txn.batch();
      for (final c in data.customers) {
        batch.insert('customers', c.toRow());
      }
      for (final t in data.transactions) {
        batch.insert('transactions', t.toRow());
      }
      await batch.commit(noResult: true);
    });
  }

  String _backupFileName() {
    final j = Jalali.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'daftar-moein-backup-${j.year}-${two(j.month)}-${two(j.day)}.json';
  }
}
