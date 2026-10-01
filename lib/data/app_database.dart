import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Single SQLite database for the whole app.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'daftar_moein.db';
  static const _version = 1;

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, _fileName),
      version: _version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            id TEXT PRIMARY KEY NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            phone_number TEXT,
            is_archived INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY NOT NULL,
            amount INTEGER NOT NULL DEFAULT 0,
            type TEXT NOT NULL CHECK (type IN ('CREDIT', 'DEBIT')),
            date TEXT NOT NULL,
            description TEXT,
            customer_id TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_transactions_customer_id ON transactions (customer_id)',
        );
      },
    );
  }
}

/// Current timestamp in the same sortable ISO-8601 (UTC) format used for
/// `created_at` / `updated_at` columns.
String nowIso() => DateTime.now().toUtc().toIso8601String();
