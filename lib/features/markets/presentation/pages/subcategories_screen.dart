import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';

class SubcategoriesScreen extends StatelessWidget {
  final Map<String, dynamic>? market;

  const SubcategoriesScreen({super.key, required this.market});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final marketName = market?['name'] ?? 'السوق';
    final subCategories = market?['subCategories'] ?? [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(
            marketName,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.appBarTheme.foregroundColor,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            _buildSearchField(theme, primaryColor),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: subCategories.length,
                itemBuilder: (context, index) {
                  return _buildSubcategoryCard(
                    context,
                    subCategories[index],
                    theme,
                    primaryColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: theme.cardColor,
      child: TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: "بحث عن قسم...",
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: theme.hintColor,
          ),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryCard(
    BuildContext context,
    Map<String, dynamic> subcategory,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha((0.03 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primaryColor.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(subcategory['icon'], color: primaryColor, size: 24),
        ),
        title: Text(
          subcategory['title'],
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: primaryColor.withAlpha((0.5 * 255).round()),
        ),
        onTap: () {
          context.push(
            AppRoutes.shopsList,
            extra: {'category': subcategory, 'marketName': marketName},
          );
        },
      ),
    );
  }
}
