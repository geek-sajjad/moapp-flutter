/// CREDIT = بستانکار, DEBIT = بدهکار
enum TransactionType {
  credit('CREDIT'),
  debit('DEBIT');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => throw FormatException('Invalid transaction type: $value'),
    );
  }
}

/// Named `LedgerTransaction` to avoid clashing with sqflite's `Transaction`.
class LedgerTransaction {
  final String id;
  final int amount;
  final TransactionType type;

  /// Gregorian date in `yyyy-MM-dd` format (local date, no time part).
  final String date;
  final String? description;
  final String customerId;
  final String createdAt;
  final String updatedAt;

  const LedgerTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.description,
    required this.customerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LedgerTransaction.fromRow(Map<String, Object?> row) {
    return LedgerTransaction(
      id: row['id'] as String,
      amount: (row['amount'] as num).toInt(),
      type: TransactionType.fromValue(row['type'] as String),
      date: row['date'] as String,
      description: row['description'] as String?,
      customerId: row['customer_id'] as String,
      createdAt: row['created_at'] as String,
      updatedAt: row['updated_at'] as String,
    );
  }

  Map<String, Object?> toRow() {
    return {
      'id': id,
      'amount': amount,
      'type': type.value,
      'date': date,
      'description': description,
      'customer_id': customerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) {
    return LedgerTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      type: TransactionType.fromValue(json['type'] as String),
      date: json['date'] as String,
      description: json['description'] as String?,
      customerId: json['customerId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.value,
      'date': date,
      'description': description,
      'customerId': customerId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CreateTransactionDto {
  final int amount;
  final TransactionType type;
  final String date;
  final String description;
  final String customerId;

  const CreateTransactionDto({
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    required this.customerId,
  });
}

class TransactionSummary {
  final int totalBalance;
  final TransactionType totalType;
  final int totalTransactions;

  const TransactionSummary({
    required this.totalBalance,
    required this.totalType,
    required this.totalTransactions,
  });
}

/// Raw values of the "new transaction" form.
class TransactionFormData {
  final String transactionDate;
  final TransactionType type;
  final String amount;
  final String description;

  const TransactionFormData({
    required this.transactionDate,
    required this.type,
    required this.amount,
    required this.description,
  });
}
