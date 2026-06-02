import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import 'package:yemen_stor/features/auth/presentation/providers/auth_providers.dart';

class WifiNetworkDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> network;

  const WifiNetworkDetailsScreen({super.key, required this.network});

  @override
  ConsumerState<WifiNetworkDetailsScreen> createState() => _WifiNetworkDetailsScreenState();
}

class _WifiNetworkDetailsScreenState extends ConsumerState<WifiNetworkDetailsScreen> {
  final List<Map<String, dynamic>> _packages = [
    {
      'id': 'pkg_1h',
      'name': 'كرت 1 ساعة',
      'price': 100.0,
      'duration': 'ساعة واحدة',
      'speed': 'سرعة تصل إلى 4 ميجا',
      'icon': Icons.timer_outlined,
    },
    {
      'id': 'pkg_24h',
      'name': 'كرت 24 ساعة',
      'price': 300.0,
      'duration': 'يوم كامل',
      'speed': 'سرعة تصل إلى 6 ميجا',
      'icon': Icons.today_outlined,
    },
    {
      'id': 'pkg_1w',
      'name': 'كرت أسبوعي',
      'price': 1500.0,
      'duration': '7 أيام متواصلة',
      'speed': 'سرعة مفتوحة فايبر',
      'icon': Icons.date_range_outlined,
    },
  ];

  bool _isPurchasing = false;

  String _generatePin() {
    final random = Random();
    final parts = List.generate(3, (_) => (random.nextInt(9000) + 1000).toString());
    return parts.join('-');
  }

  Future<void> _handleCardPurchase(Map<String, dynamic> package) async {
    final userState = ref.read(userDocumentStreamProvider).value;
    final user = fb_auth.FirebaseAuth.instance.currentUser;

    if (userState == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء تسجيل الدخول أولاً لإتمام عملية الشراء", style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double balance = userState.balanceYER;
    final double price = package['price'] as double;

    if (balance < price) {
      _showInsufficientFundsDialog();
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      final String generatedPin = _generatePin();
      final double newBalance = balance - price;

      // 1. Deduct balance in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'balanceYER': newBalance,
      });

      // 2. Add transaction record to Firestore
      final transactionId = "TX-${Random().nextInt(90000) + 10000}";
      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': user.uid,
        'transactionId': transactionId,
        'title': "${package['name']} - ${widget.network['name']}",
        'category': 'واي فاي',
        'amount': "$price- YER",
        'pinCode': generatedPin,
        'networkName': widget.network['name'],
        'networkId': widget.network['id'],
        'status': 'ناجحة',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Show purchase success dialog
      if (mounted) {
        _showSuccessDialog(generatedPin, package['name'], price);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فشلت عملية الشراء: $e", style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "رصيد غير كافٍ!",
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
        content: const Text(
          "رصيدك بالعملة اليمنية (YER) لا يكفي لإتمام عملية شراء هذا الكرت. يرجى شحن محفظتك الرقمية والمحاولة لاحقاً.",
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("حسناً", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String pinCode, String packageName, double price) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text(
              "تم الشراء بنجاح!",
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "لقد اشتريت $packageName بقيمة ${price.toStringAsFixed(0)} ريال يمني.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    "رمز PIN الميكروتيك",
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    pinCode,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "يمكنك استخدام الرمز مباشرة لتسجيل الدخول لشبكة الواي فاي.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: pinCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم نسخ رمز PIN للحافظة ✓", style: TextStyle(fontFamily: 'Cairo')),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.copy, color: AppColors.primary),
            label: const Text("نسخ الرمز", style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.pop(); // Go back to wifi screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("تم", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final userState = ref.watch(userDocumentStreamProvider).value;
    final balanceYER = userState?.balanceYER ?? 0.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            widget.network['name'] ?? 'تفاصيل الشبكة',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            // معلومات الشبكة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.wifi_tethering, color: theme.colorScheme.primary, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.network['name'] ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.network['location'] ?? '',
                        style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn("المالك", widget.network['ownerName'] ?? 'يمن ستور'),
                      _buildInfoColumn("المحفظة (YER)", "${balanceYER.toStringAsFixed(0)} YER"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // قائمة باقات الكروت
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final package = _packages[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
                          isDark ? theme.colorScheme.surface : theme.colorScheme.primary.withValues(alpha: 0.03),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // أيقونة الباقة
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(package['icon'] as IconData, color: theme.colorScheme.primary, size: 28),
                        ),
                        const SizedBox(width: 16),

                        // تفاصيل الباقة
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Cairo'),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${package['duration']} • ${package['speed']}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 11, fontFamily: 'Cairo'),
                              ),
                            ],
                          ),
                        ),

                        // السعر وزر الشراء
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${(package['price'] as double).toStringAsFixed(0)} ريال",
                              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _isPurchasing ? null : () {
                                HapticFeedback.mediumImpact();
                                _handleCardPurchase(package);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _isPurchasing
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text("شراء الآن", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Cairo')),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
      ],
    );
  }
}
