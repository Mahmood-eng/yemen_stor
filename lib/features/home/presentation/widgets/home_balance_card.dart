import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/features/wallet/presentation/pages/recharge_wallet_screen.dart';

class HomeBalanceCard extends StatefulWidget {
  const HomeBalanceCard({super.key});

  @override
  State<HomeBalanceCard> createState() => _HomeBalanceCardState();
}

class _HomeBalanceCardState extends State<HomeBalanceCard> {
  bool _isVisible = false;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: PageView(
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _buildItem("رصيد اليمني", "0 YR"),
              _buildItem("رصيد السعودي", "0 SR"),
              _buildItem("رصيد الدولار", "0 \$"),
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
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RechargeWalletScreen(),
                    ),
                  );  
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