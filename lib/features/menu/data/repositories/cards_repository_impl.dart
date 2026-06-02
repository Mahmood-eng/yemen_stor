import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/cards_repository.dart';
import '../datasources/cards_data_source.dart';
import '../models/card_model.dart';

class CardsRepositoryImpl implements CardsRepository {
  final CardsDataSource _dataSource;

  CardsRepositoryImpl(this._dataSource);

  @override
  Stream<List<CardEntity>> getCardStatsStream() {
    return _dataSource.getCardStatsStream();
  }

  @override
  Future<void> addOrUpdateCategory(CardEntity card) {
    final model = CardModel(
      category: card.category,
      remaining: card.remaining,
      sold: card.sold,
      revenue: card.revenue,
      total: card.total,
      colorHex: card.colorHex,
    );
    return _dataSource.addOrUpdateCategory(model);
  }
}
