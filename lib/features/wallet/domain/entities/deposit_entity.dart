class DepositEntity {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String bankId;
  final String uniqueCode;
  final String status;
  final DateTime createdAt;
  final bool isApplied;

  DepositEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.bankId,
    required this.uniqueCode,
    this.status = 'pending',
    required this.createdAt,
    this.isApplied = false,
  });
}
