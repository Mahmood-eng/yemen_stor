import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';

import 'package:yemen_stor/features/digitalservices/presentation/widgets/service_category_card.dart';
import 'package:yemen_stor/features/digitalservices/presentation/widgets/services_banner.dart';
import 'package:yemen_stor/features/digitalservices/presentation/widgets/services_search.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/features/digitalservices/presentation/widgets/section_title.dart';
import 'package:yemen_stor/features/digitalservices/presentation/widgets/services_grid.dart';

import '../../../menu/presentation/pages/app_drawer.dart';

class DigitalServicesScreen extends StatelessWidget {
  const DigitalServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: YemenStoreAppBar(
          title: const Text("الخدمات الرقمية"),
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: theme.appBarTheme.iconTheme?.color),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              context.push(AppRoutes.cart);
            },
          ),
          ],
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

              const SectionTitle(title: "اتصالات وشبكات"),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  ServiceCategoryCard(
                    title: "شحن رصيد",
                    icon: Icons.phone_android,
                    iconColor: AppColors.iconOrange,
                    onTap: () => context.push(AppRoutes.topUp),
                  ),
                  ServiceCategoryCard(
                    title: "كروت واي فاي",
                    icon: Icons.wifi,
                    iconColor: AppColors.iconBlue,
                    onTap: () => context.push(AppRoutes.wifiNetworks),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const SectionTitle(title: "اشتراكات برامج ومحتوى"),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  ServiceCategoryCard(
                    title: "ذكاء اصطناعي",
                    icon: Icons.psychology,
                    iconColor: AppColors.iconPurple,
                    onTap: () => context.push(AppRoutes.aiSubscription),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const SectionTitle(title: "خدمات الأيدي العاملة"),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  ServiceCategoryCard(
                    title: "عمالة مهنية",
                    icon: Icons.handyman_outlined,
                    iconColor: AppColors.iconBrown,
                    onTap: () => context.push(AppRoutes.workersList, extra: 'عمالة مهنية'),
                  ),
                  ServiceCategoryCard(
                    title: "كوادر علمية",
                    icon: Icons.school_outlined,
                    iconColor: AppColors.iconTeal,
                    onTap: () => context.push(AppRoutes.workersList, extra: 'كوادر علمية'),
                  ),
                  ServiceCategoryCard(
                    title: "مستشارين",
                    icon: Icons.support_agent_outlined,
                    iconColor: AppColors.iconCyan,
                    onTap: () => context.push(AppRoutes.workersList, extra: 'مستشارين'),
                  ),
                  ServiceCategoryCard(
                    title: "استشارات مهنية",
                    icon: Icons.support_agent_outlined,
                    iconColor: AppColors.iconCyan,
                    onTap: () => context.push(AppRoutes.workersList, extra: 'استشارات مهنية'),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const SectionTitle(title: "سجلات وتقارير"),
              const SizedBox(height: 15),
              ServicesGrid(
                children: [
                  ServiceCategoryCard(
                    title: "سجل العمليات",
                    icon: Icons.history,
                    iconColor: AppColors.iconIndigo,
                    onTap: () => context.push(AppRoutes.transactionHistory),
                  ),
                ],
              ),
            ],
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return FloatingActionButton(
              heroTag: 'digital_services_fab',
              onPressed: () => context.push(AppRoutes.transactionHistory),
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.history,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }
}
