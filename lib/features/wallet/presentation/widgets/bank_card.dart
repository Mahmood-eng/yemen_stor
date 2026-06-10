import 'package:flutter/material.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';

class BankCard extends StatelessWidget {
  final Map<String, String> bank;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onActivateTap;

  const BankCard({
    super.key,
    required this.bank,
    required this.isSelected,
    required this.onTap,
    required this.onActivateTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isDark && isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // شريط "محتاج تفعيل"
            Positioned(
              top: 0, left: 0, right: 0,
              child: InkWell(
                onTap: onActivateTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(13), 
                      topRight: Radius.circular(13),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bolt, size: 12, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text(
                        "محتاج تفعيل",
                        style: TextStyle(
                          fontSize: 10, 
                          color: AppColors.warning, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // تم إضافة Center هنا لضمان توسيط الصورة والاسم تماماً
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // تأكيد التوسيط الأفقي
                children: [
                  const SizedBox(height: 20), // تعويض مساحة شريط التفعيل
                  // أيقونة البنك
                  Image.asset(
                    bank['icon']!, 
                    height: 45, 
                    fit: BoxFit.contain, // لضمان عدم تمدد الصورة بشكل خاطئ
                    errorBuilder: (c, e, s) => Icon(
                      Icons.account_balance, 
                      size: 35,
                      color: isDark ? Colors.white24 : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // اسم البنك
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      bank['name']!, 
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}