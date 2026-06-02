import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import 'package:yemen_stor/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_stor/features/wallet/presentation/providers/wallet_providers.dart';

class HomeBalanceCard extends ConsumerStatefulWidget {
  const HomeBalanceCard({super.key});

  @override
  ConsumerState<HomeBalanceCard> createState() => _HomeBalanceCardState();
}

class _HomeBalanceCardState extends ConsumerState<HomeBalanceCard> {
  bool _isVisible = false;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(depositStatusListenerProvider);
    final userAsync = ref.watch(userDocumentStreamProvider);

    return userAsync.when(
      data: (user) {
        final yerVal = user?.balanceYER ?? 0.0;
        final sarVal = user?.balanceSAR ?? 0.0;
        final usdVal = user?.balanceUSD ?? 0.0;

        return Column(
          children: [
            SizedBox(
              height: 100,
              child: PageView(
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildItem("رصيد اليمني", "${yerVal.toStringAsFixed(0)} YER"),
                  _buildItem("رصيد السعودي", "${sarVal.toStringAsFixed(0)} SAR"),
                  _buildItem("رصيد الدولار", "${usdVal.toStringAsFixed(2)} \$"),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => _buildIndicator(i == _currentPage)),
            ),
          ],
        );
      },
      loading: () => Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (err, stack) => Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            "خطأ في تحميل المحفظة: $err",
            style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String label, String amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // أيقونة الزائد داخل دائرة لتغذية الرصيد
              GestureDetector(
                onTap: () {
                  context.push(AppRoutes.wallet);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              // أيقونة العين للإظهار والإخفاء
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                  size: 22,
                ),
                onPressed: () => setState(() => _isVisible = !_isVisible),
              ),
            ],
          ),

          // الجهة اليسرى: النص والمبلغ
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Cairo',
                  fontSize: 12,
                ),
              ),
              Text(
                _isVisible ? amount : "••••••",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 6,
      width: isActive ? 18 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
