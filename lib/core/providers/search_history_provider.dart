import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/search_history_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SearchHistoryService(prefs);
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final SearchHistoryService _service;

  SearchHistoryNotifier(this._service) : super(_service.getSearchHistory());

  Future<void> addQuery(String query) async {
    await _service.addSearchQuery(query);
    state = _service.getSearchHistory();
  }

  Future<void> removeQuery(String query) async {
    await _service.removeSearchQuery(query);
    state = _service.getSearchHistory();
  }

  Future<void> clearHistory() async {
    await _service.clearHistory();
    state = [];
  }
}

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  final service = ref.watch(searchHistoryServiceProvider);
  return SearchHistoryNotifier(service);
});
