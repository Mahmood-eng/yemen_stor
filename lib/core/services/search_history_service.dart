import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryLength = 10;
  final SharedPreferences _prefs;

  SearchHistoryService(this._prefs);

  List<String> getSearchHistory() {
    return _prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    final history = getSearchHistory();
    // إزالة الكلمة إذا كانت موجودة مسبقاً لوضعها في بداية القائمة
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    
    // إضافة الكلمة في بداية السجل
    history.insert(0, query);
    
    // الاحتفاظ بآخر 10 عمليات بحث فقط
    if (history.length > _maxHistoryLength) {
      history.removeRange(_maxHistoryLength, history.length);
    }
    
    await _prefs.setStringList(_historyKey, history);
  }

  Future<void> removeSearchQuery(String query) async {
    final history = getSearchHistory();
    history.remove(query);
    await _prefs.setStringList(_historyKey, history);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }
}
