import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const String id = 'onboarding_screen';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "تسوق من منزلك",
      "desc": "كل المحلات والمتاجر المحلية أصبحت بين يديك في تطبيق واحد.",
      "image": "assets/images/onboard1.png"
    },
    {
      "title": "توصيل سريع",
      "desc": "نصل إليك في أسرع وقت ممكن إلى باب بيتك في جميع المحافظات.",
      "image": "assets/images/onboard2.png"
    },
    {
      "title": "دفع آمن",
      "desc": "طرق دفع متعددة وآمنة لتسهيل عملية الشراء وضمان حقوقك.",
      "image": "assets/images/onboard3.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // الخلفية تسحب تلقائياً من ScaffoldBackgroundColor في الثيم
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (value) => setState(() => _currentPage = value),
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // حاوية الصورة التجميلية
                  Container(
                    width: size.width * 0.85,
                    height: size.height * 0.45,
                    margin: const EdgeInsets.only(top: 40),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        _onboardingData[index]["image"]!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  
                 
                  Text(
                    _onboardingData[index]["title"]!,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
                  ),
                  
                 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    child: Text(
                      _onboardingData[index]["desc"]!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: size.height * 0.05),
            child: Column(
              children: [
                // مؤشرات الصفحات (Dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => buildDot(index, isDark),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                
               
                CustomButton(
                  text: _currentPage == _onboardingData.length - 1 ? "ابدأ الآن" : "التالي",
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      context.go(AppRoutes.login);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? AppColors.primary 
            : (isDark ? Colors.white24 : const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}