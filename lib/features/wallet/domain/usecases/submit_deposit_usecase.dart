import '../entities/deposit_entity.dart';
import '../repositories/deposit_repository.dart';

class SubmitDepositUseCase {
  final DepositRepository repository;

  SubmitDepositUseCase(this.repository);

  Future<void> call(DepositEntity deposit) async {
    await repository.submitDeposit(deposit);
  }
}
