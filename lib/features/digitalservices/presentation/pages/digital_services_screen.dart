import 'package:flutter/material.dart';
import 'package:yemen_store/core/widgets/app_drawer.dart';
import 'package:yemen_store/features/digitalservices/presentation/widgets/service_category_card%20.dart';

import 'package:yemen_store/features/digitalservices/presentation/widgets/services_banner.dart';
import 'package:yemen_store/features/digitalservices/presentation/widgets/services_search.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/features/digitalservices/presentation/widgets/section_title.dart';
import 'package:yemen_store/features/digitalservices/presentation/widgets/services_grid.dart';

class DigitalServicesScreen extends StatelessWidget {
  const DigitalServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "الخدمات الرقمية",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,

          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),

        drawer: const AppDrawer(),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const ServicesSearchField(),
              const SizedBox(height: 15),
              const ServicesBanner(),
              const SizedBox(height: 22),

              const SectionTitle(title: "اتصالات"),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  const ServiceCategoryCard(
                    title: "شحن رصيد",
                    icon: Icons.phone_android,
                    iconColor: AppColors.iconOrange,
                  ),
                  const ServiceCategoryCard(
                    title: "كروت واي فاي",
                    icon: Icons.wifi,
                    iconColor: AppColors.iconBlue,
                  ),
                  const ServiceCategoryCard(
                    title: "باقات",
                    icon: Icons.cloud_upload,
                    iconColor: AppColors.iconLightBlue,
                  ),
                  const ServiceCategoryCard(
                    title: "خدمات أخرى",
                    icon: Icons.settings_outlined,
                    iconColor: AppColors.iconGrey,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const SectionTitle(title: "اشتراكات برامج ومحتوى"),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  const ServiceCategoryCard(
                    title: "ذكاء اصطناعي",
                    icon: Icons.psychology,
                    iconColor: AppColors.iconPurple,
                  ),
                  const ServiceCategoryCard(
                    title: "برامج تصميم",
                    icon: Icons.dashboard_customize,
                    iconColor: AppColors.iconPink,
                  ),
                  const ServiceCategoryCard(
                    title: "برامج إنتاجية",
                    icon: Icons.work_outline,
                    iconColor: AppColors.iconGreen,
                  ),
                  const ServiceCategoryCard(
                    title: "منصات تعليمية",
                    icon: Icons.school_outlined,
                    iconColor: AppColors.iconTeal,
                  ),
                  const ServiceCategoryCard(
                    title: "منصات ترفيهية",
                    icon: Icons.movie_outlined,
                    iconColor: AppColors.iconRedAccent,
                  ),
                  const ServiceCategoryCard(
                    title: "محتوى مرئي",
                    icon: Icons.play_circle_fill,
                    iconColor: AppColors.iconRed,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const SectionTitle(title: "خدمات الأيدي العاملة"),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  const ServiceCategoryCard(
                    title: "عمالة مهنية",
                    icon: Icons.handyman_outlined,
                    iconColor: AppColors.iconBrown,
                  ),
                  const ServiceCategoryCard(
                    title: "كوادر علمية",
                    icon: Icons.school_outlined,
                    iconColor: AppColors.iconTeal,
                  ),
                  const ServiceCategoryCard(
                    title: "مستشارين",
                    icon: Icons.support_agent_outlined,
                    iconColor: AppColors.iconCyan,
                  ),
                  const ServiceCategoryCard(
                    title: "استشارات مهنية",
                    icon: Icons.support_agent_outlined,
                    iconColor: AppColors.iconCyan,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const SectionTitle(title: "ألعاب إلكترونية"),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  const ServiceCategoryCard(
                    title: "شحن العاب",
                    icon: Icons.videogame_asset,
                    iconColor: AppColors.iconGreen,
                  ),

                  const ServiceCategoryCard(
                    title: "بطاقات هدايا",
                    icon: Icons.card_giftcard,
                    iconColor: AppColors.iconRedAccent,
                  ),
                  const ServiceCategoryCard(
                    title: "اشتراكات ألعاب",
                    icon: Icons.gamepad_outlined,
                    iconColor: AppColors.iconDeepPurple,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const SectionTitle(title: "مالية "),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  const ServiceCategoryCard(
                    title: "تحويلات مالية",
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.iconIndigo,
                  ),
                  const ServiceCategoryCard(
                    title: "دفع فواتير",
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.iconOrangeAccent,
                  ),
                  const ServiceCategoryCard(
                    title: "خدمات بنكية",
                    icon: Icons.account_balance_outlined,
                    iconColor: AppColors.iconBlueGrey,
                  ),
                ],
              ),
            ],
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: const Color(0xFF0D3B66),
          icon: const Icon(Icons.history, color: Colors.white, size: 20),
          label: const Text(
            "آخر العمليات",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
