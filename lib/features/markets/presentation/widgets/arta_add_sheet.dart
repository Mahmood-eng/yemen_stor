import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

class ArtaAddSheet extends StatelessWidget {
  final Color accentColor;

  const ArtaAddSheet({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 15,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.16 * 255).round(),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "عرض منتج جديد",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "يرجى تصوير المنتج من عدة اتجاهات لوضوح العرطة",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.7 * 255).round(),
                ),
              ),
            ),
            Icon(   
              Icons.photo_camera_outlined,
              size: 40,
              color: accentColor,
            ),
            const SizedBox(height: 20),
            const ArtaInputField(
              hint: "اسم البائع",
              icon: Icons.person_outline,
            ),
            const ArtaInputField(
              hint: "ماذا تبيع؟ (اسم المنتج)",
              icon: Icons.shopping_bag_outlined,
            ),
            const ArtaInputField(
              hint: "وصف مختصر للحالة",
              icon: Icons.description_outlined,
            ),
            const ArtaInputField(
              hint: "السعر المطلوب",
              icon: Icons.money_rounded,
              isNum: true,
            ),
            const ArtaInputField(
              hint: "رقم التواصل",
              icon: Icons.phone_android_rounded,
              isNum: true,
            ),
            const ArtaInputField(
              hint: "الموقع (المنطقة - الشارع)",
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "نشر الآن",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ArtaInputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isNum;

  const ArtaInputField({
    super.key,
    required this.hint,
    required this.icon,
    this.isNum = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        textAlign: TextAlign.right,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}
