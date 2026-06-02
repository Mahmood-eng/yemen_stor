import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_history_provider.dart';

class SmartSearchDelegate extends SearchDelegate<String> {
  final String searchHint;
  final WidgetRef ref;

  SmartSearchDelegate({
    required this.ref,
    this.searchHint = 'بحث...',
  }) : super(
          searchFieldLabel: searchHint,
          searchFieldStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
          ),
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      // حفظ كلمة البحث في السجل
      ref.read(searchHistoryProvider.notifier).addQuery(query.trim());
      // نعيد القيمة للصفحة لتنفيذ البحث
      Future.delayed(Duration.zero, () {
        close(context, query.trim());
      });
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);

    // تصفية السجل حسب ما يكتبه المستخدم
    final suggestions = query.isEmpty
        ? history
        : history
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();

    if (suggestions.isEmpty && query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 80, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text(
              "ابحث عما تريده الآن",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length + (query.isEmpty && history.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // زر "مسح السجل" في النهاية
        if (query.isEmpty && history.isNotEmpty && index == suggestions.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: TextButton.icon(
              onPressed: () {
                ref.read(searchHistoryProvider.notifier).clearHistory();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text(
                "مسح سجل البحث",
                style: TextStyle(fontFamily: 'Cairo', color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(
            query.isEmpty ? Icons.history : Icons.search,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          title: Text(
            suggestion,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          trailing: query.isEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: theme.dividerColor,
                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).removeQuery(suggestion);
                  },
                )
              : const Icon(Icons.north_west, size: 16),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}
