import 'package:flutter/material.dart';

import '../widgets/arta_add_sheet.dart';
import '../widgets/arta_product_card.dart';
import '../widgets/arta_warning_banner.dart';

class ArtaMarketScreen extends StatefulWidget {
  static const String id = 'arta_market_screen';
  const ArtaMarketScreen({super.key});

  @override
  State<ArtaMarketScreen> createState() => _ArtaMarketScreenState();
}

class _ArtaMarketScreenState extends State<ArtaMarketScreen> {
  final List<Map<String, String>> _artaProducts = [
    {
      "seller": "عمر الخادم",
      "title": "آيفون 16 برو ماكس - لون ذهبي لقطة",
      "price": "1,200 \$",
      "location": "تعز - شارع جمال",
      "image": "assets/images/iphon16gold.jpg",
    },
    {
      "seller": "أبو رعد ",
      "title": "ثلاجة إل جي كبيرة - نظيفة جداً",
      "price": "250,000 ريال",
      "location": "تعز - بيرباشا",
      "image": "assets/images/refrigerator.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final accentColor = theme.colorScheme.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "سوق العرطات",
            style: theme.textTheme.titleLarge?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: primaryColor),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.favorite_rounded, color: primaryColor),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddArtaSheet(context, theme, accentColor),
            backgroundColor: accentColor,
            elevation: 4,
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
            ),
            label: Text(
              "أضف عرطة",
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            ArtaWarningBanner(accentColor: accentColor),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 100),
                itemCount: _artaProducts.length,
                itemBuilder: (context, index) {
                  return ArtaProductCard(product: _artaProducts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddArtaSheet(
    BuildContext context,
    ThemeData theme,
    Color accentColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArtaAddSheet(accentColor: accentColor),
    );
  }
}
