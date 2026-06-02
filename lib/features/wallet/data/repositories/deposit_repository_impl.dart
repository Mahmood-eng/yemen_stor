import '../../domain/entities/deposit_entity.dart';
import '../../domain/repositories/deposit_repository.dart';
import '../datasources/deposit_datasource.dart';
import '../models/deposit_model.dart';

class DepositRepositoryImpl implements DepositRepository {
  final DepositDataSource remoteDataSource;

  DepositRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> submitDeposit(DepositEntity deposit) async {
    final depositModel = DepositModel(
      id: deposit.id,
      userId: deposit.userId,
      amount: deposit.amount,
      currency: deposit.currency,
      bankId: deposit.bankId,
      uniqueCode: deposit.uniqueCode,
      status: deposit.status,
      createdAt: deposit.createdAt,
    );
    await remoteDataSource.submitDeposit(depositModel);
  }
}
