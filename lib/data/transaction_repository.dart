import 'package:uuid/uuid.dart';

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
}
