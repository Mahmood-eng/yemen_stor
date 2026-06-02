import '../../domain/entities/deposit_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepositModel extends DepositEntity {
  DepositModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.currency,
    required super.bankId,
    required super.uniqueCode,
    super.status = 'pending',
    required super.createdAt,
    super.isApplied = false,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json, String id) {
    return DepositModel(
      id: id,
      userId: json['userId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'YER',
      bankId: json['bankId'] ?? '',
      uniqueCode: json['uniqueCode'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isApplied: json['isApplied'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'bankId': bankId,
      'uniqueCode': uniqueCode,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'isApplied': isApplied,
    };
  }
}
