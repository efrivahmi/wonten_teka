import 'package:equatable/equatable.dart';

class ClaimCategoryModel extends Equatable {
  final int id;

  final String name;
  final bool requiresReceipt;
  final double? maxAmount;

  const ClaimCategoryModel({
    required this.id,

    required this.name,
    this.requiresReceipt = false,
    this.maxAmount,
  });

  factory ClaimCategoryModel.fromJson(Map<String, dynamic> json) {
    return ClaimCategoryModel(
      id: json['id'] as int,

      name: json['name'] as String,
      requiresReceipt: json['requires_receipt'] as bool? ?? false,
      maxAmount: (json['max_amount'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class ClaimModel extends Equatable {
  final int id;

  final int employeeId;
  final int claimCategoryId;
  final double amount;
  final DateTime expenseDate;
  final String description;
  final String? receiptUrl;
  final String status;
  final ClaimCategoryModel? claimCategory;
  final DateTime? createdAt;

  const ClaimModel({
    required this.id,

    required this.employeeId,
    required this.claimCategoryId,
    required this.amount,
    required this.expenseDate,
    required this.description,
    this.receiptUrl,
    this.status = 'pending',
    this.claimCategory,
    this.createdAt,
  });

  bool get isPending => status == 'pending';

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      id: json['id'] as int,

      employeeId: json['employee_id'] as int,
      claimCategoryId: json['claim_category_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expense_date'] as String),
      description: json['description'] as String,
      receiptUrl: json['receipt_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      claimCategory: json['claim_category'] != null
          ? ClaimCategoryModel.fromJson(json['claim_category'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, amount, status];
}
