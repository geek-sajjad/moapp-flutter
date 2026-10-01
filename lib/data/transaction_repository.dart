import 'package:uuid/uuid.dart';

import '../models/customer.dart';
import '../models/ledger_report.dart';
import '../models/ledger_transaction.dart';
import 'app_database.dart';
import 'customer_repository.dart';

/// Port of the backend `TransactionService` / `TransactionRepository`.
class TransactionRepository {
  TransactionRepository._();

  static final TransactionRepository instance = TransactionRepository._();

  final _uuid = const Uuid();

  Future<LedgerTransaction> create(CreateTransactionDto dto) async {
    // Verify that the customer exists
    await CustomerRepository.instance.findOne(dto.customerId);

    final db = await AppDatabase.instance.database;
    final now = nowIso();
    final transaction = LedgerTransaction(
      id: _uuid.v4(),
      amount: dto.amount,
      type: dto.type,
      date: dto.date,
      description: dto.description,
      customerId: dto.customerId,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('transactions', transaction.toRow());
    return transaction;
  }

  Future<List<LedgerTransaction>> findAllByCustomer(String customerId) async {
    await CustomerRepository.instance.findOne(customerId);

    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(LedgerTransaction.fromRow).toList();
  }

  Future<TransactionSummary> getCustomerSummary(String customerId) async {
    await CustomerRepository.instance.findOne(customerId);

    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN type = 'CREDIT' THEN amount ELSE -amount END) AS totalBalance,
        COUNT(*) AS totalTransactions
      FROM transactions
      WHERE customer_id = ?
      ''',
      [customerId],
    );

    final row = rows.isNotEmpty ? rows.first : const <String, Object?>{};
    final totalBalance = (row['totalBalance'] as num?)?.toInt() ?? 0;
    final totalTransactions = (row['totalTransactions'] as num?)?.toInt() ?? 0;

    return TransactionSummary(
      totalBalance: totalBalance.abs(),
      totalTransactions: totalTransactions,
      totalType:
          totalBalance > 0 ? TransactionType.credit : TransactionType.debit,
    );
  }

  /// Balance of every customer (archived included), for the report page.
  Future<LedgerReport> getReport() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT
        c.*,
        COALESCE(SUM(CASE WHEN t.type = 'CREDIT' THEN t.amount ELSE -t.amount END), 0)
          AS balance,
        COUNT(t.id) AS transaction_count
      FROM customers c
      LEFT JOIN transactions t ON t.customer_id = c.id
      GROUP BY c.id
      ''');

    return LedgerReport([
      for (final row in rows)
        CustomerBalance(
          customer: Customer.fromRow(row),
          balance: (row['balance'] as num).toInt(),
          transactionCount: (row['transaction_count'] as num).toInt(),
        ),
    ]);
  }
}
