import 'package:uuid/uuid.dart';

import '../models/customer.dart';
import 'app_database.dart';

class CustomerNotFoundException implements Exception {
  @override
  String toString() => 'Customer not found';
}

/// Port of the backend `CustomerService`.
class CustomerRepository {
  CustomerRepository._();

  static final CustomerRepository instance = CustomerRepository._();

  final _uuid = const Uuid();

  Future<Customer> create(CreateCustomerDto dto) async {
    final db = await AppDatabase.instance.database;
    final now = nowIso();
    final customer = Customer(
      id: _uuid.v4(),
      name: dto.name,
      description: dto.description,
      phoneNumber: dto.phoneNumber,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('customers', customer.toRow());
    return customer;
  }

  Future<List<Customer>> findAll({bool includeArchived = false}) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'customers',
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'created_at DESC',
    );
    return rows.map(Customer.fromRow).toList();
  }

  Future<Customer> findOne(String id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) throw CustomerNotFoundException();
    return Customer.fromRow(rows.first);
  }

  Future<Customer> update(String id, UpdateCustomerDto dto) async {
    final db = await AppDatabase.instance.database;
    await findOne(id);
    final values = <String, Object?>{
      'name': dto.name,
      'description': dto.description,
      'updated_at': nowIso(),
    };
    // Same as the backend: an omitted phone number keeps the current one.
    if (dto.phoneNumber != null) values['phone_number'] = dto.phoneNumber;
    await db.update(
      'customers',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    return findOne(id);
  }

  Future<Customer> archive(String id) => _setArchived(id, true);

  Future<Customer> unarchive(String id) => _setArchived(id, false);

  Future<Customer> _setArchived(String id, bool archived) async {
    final db = await AppDatabase.instance.database;
    await findOne(id);
    await db.update(
      'customers',
      {'is_archived': archived ? 1 : 0, 'updated_at': nowIso()},
      where: 'id = ?',
      whereArgs: [id],
    );
    return findOne(id);
  }
}
