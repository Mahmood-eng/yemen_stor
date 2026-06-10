import '../entities/deposit_entity.dart';

abstract class DepositRepository {
  Future<void> submitDeposit(DepositEntity deposit);
}
