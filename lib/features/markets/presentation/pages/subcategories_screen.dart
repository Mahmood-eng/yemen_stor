import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class SubcategoriesScreen extends StatelessWidget {
  final Map<String, dynamic> market;
  final Map<String, dynamic> subcategory;

  const SubcategoriesScreen({
    super.key,
    required this.market,
    required this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    final marketName = market['name'] ?? '';
    final subcategoryName = subcategory['title'] ?? '';
    final subcategoryIcon = subcategory['icon'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            subcategoryName,
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                subcategoryIcon,
                size: 80,
                color: AppColors.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 20),
              Text(
                "قسم $subcategoryName",
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "من سوق $marketName",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  context.push(
                    AppRoutes.shopsList,
                    extra: {'market': market, 'subcategory': subcategory},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "عرض المحلات",
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
