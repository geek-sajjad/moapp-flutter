class Customer {
  final String id;
  final String name;
  final String? description;
  final String? phoneNumber;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.description,
    this.phoneNumber,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromRow(Map<String, Object?> row) {
    return Customer(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      phoneNumber: row['phone_number'] as String?,
      isArchived: (row['is_archived'] as int? ?? 0) == 1,
      createdAt: row['created_at'] as String,
      updatedAt: row['updated_at'] as String,
    );
  }

  Map<String, Object?> toRow() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone_number': phoneNumber,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isArchived: json['isArchived'] == true,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phoneNumber': phoneNumber,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CreateCustomerDto {
  final String name;
  final String? description;
  final String? phoneNumber;

  const CreateCustomerDto({
    required this.name,
    this.description,
    this.phoneNumber,
  });
}

class UpdateCustomerDto {
  final String name;
  final String? description;
  final String? phoneNumber;

  const UpdateCustomerDto({
    required this.name,
    this.description,
    this.phoneNumber,
  });
}
