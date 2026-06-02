import '../entities/card_entity.dart';
import '../repositories/cards_repository.dart';

class GetCardStatsUseCase {
  final CardsRepository _repository;

  GetCardStatsUseCase(this._repository);

  Stream<List<CardEntity>> call() {
    return _repository.getCardStatsStream();
  }
}

class AddCardCategoryUseCase {
  final CardsRepository _repository;

  AddCardCategoryUseCase(this._repository);

  Future<void> call(CardEntity card) {
    return _repository.addOrUpdateCategory(card);
  }
}
