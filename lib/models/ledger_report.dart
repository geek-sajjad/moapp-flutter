import 'customer.dart';

/// A customer's balance: sum of CREDIT minus sum of DEBIT amounts.
/// Positive = بستانکار (the customer owes you), negative = بدهکار (you owe).
class CustomerBalance {
  final Customer customer;
  final int balance;
  final int transactionCount;

  const CustomerBalance({
    required this.customer,
    required this.balance,
    required this.transactionCount,
  });
}

/// Totals over all customers (archived ones included: their balances are
/// still owed).
class LedgerReport {
  final List<CustomerBalance> balances;

  const LedgerReport(this.balances);

  /// Sum of positive balances (what customers owe you).
  int get totalCredit => balances
      .where((b) => b.balance > 0)
      .fold(0, (sum, b) => sum + b.balance);

  /// Sum of negative balances, as a positive number (what you owe).
  int get totalDebit => balances
      .where((b) => b.balance < 0)
      .fold(0, (sum, b) => sum - b.balance);

  /// [totalCredit] - [totalDebit]; positive means you are owed overall.
  int get netBalance => totalCredit - totalDebit;

  int get creditorCount => balances.where((b) => b.balance > 0).length;

  int get debtorCount => balances.where((b) => b.balance < 0).length;

  int get settledCount => balances.where((b) => b.balance == 0).length;

  int get customerCount => balances.length;

  int get transactionCount =>
      balances.fold(0, (sum, b) => sum + b.transactionCount);

  /// Customers with a non-zero balance, largest amount first.
  List<CustomerBalance> get openBalances {
    final open = balances.where((b) => b.balance != 0).toList();
    open.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
    return open;
  }
}
