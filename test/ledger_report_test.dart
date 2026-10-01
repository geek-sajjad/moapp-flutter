import 'package:daftar_moein/models/customer.dart';
import 'package:daftar_moein/models/ledger_report.dart';
import 'package:flutter_test/flutter_test.dart';

CustomerBalance _balance(String id, int balance, {int transactions = 1}) {
  return CustomerBalance(
    customer: Customer(
      id: id,
      name: id,
      isArchived: false,
      createdAt: '2024-01-01T00:00:00.000Z',
      updatedAt: '2024-01-01T00:00:00.000Z',
    ),
    balance: balance,
    transactionCount: transactions,
  );
}

void main() {
  group('LedgerReport', () {
    test('totals credit, debit and net balance', () {
      final report = LedgerReport([
        _balance('a', 500000, transactions: 3),
        _balance('b', -200000, transactions: 2),
        _balance('c', 100000),
        _balance('d', 0, transactions: 4),
      ]);

      expect(report.totalCredit, 600000);
      expect(report.totalDebit, 200000);
      expect(report.netBalance, 400000);
      expect(report.creditorCount, 2);
      expect(report.debtorCount, 1);
      expect(report.settledCount, 1);
      expect(report.customerCount, 4);
      expect(report.transactionCount, 10);
    });

    test('net balance is negative when you owe more than you are owed', () {
      final report = LedgerReport([_balance('a', 100), _balance('b', -300)]);
      expect(report.netBalance, -200);
    });

    test('open balances skip settled customers, largest amount first', () {
      final report = LedgerReport([
        _balance('small', 100),
        _balance('settled', 0),
        _balance('large-debt', -900),
        _balance('medium', 500),
      ]);
      expect(
        report.openBalances.map((b) => b.customer.id),
        ['large-debt', 'medium', 'small'],
      );
    });

    test('empty report is all zeros', () {
      const report = LedgerReport([]);
      expect(report.netBalance, 0);
      expect(report.openBalances, isEmpty);
    });
  });
}
