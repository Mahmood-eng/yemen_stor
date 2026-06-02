import '../entities/card_entity.dart';

abstract class CardsRepository {
  Stream<List<CardEntity>> getCardStatsStream();
  Future<void> addOrUpdateCategory(CardEntity card);
}
