import 'package:flutter/material.dart';

class MarketModel {
  final String name;
  final IconData icon;
  final List<Map<String, dynamic>> subCategories;

  MarketModel({
    required this.name,
    required this.icon,
    this.subCategories = const [],
  });
}


final List<MarketModel> mockMarkets = [
  MarketModel(
    name: "إلكترونيات",
    icon: Icons.devices_other_rounded,
    subCategories: [
      {"title": "الهواتف الذكية", "icon": Icons.smartphone},
      {"title": "أجهزة اللابتوب", "icon": Icons.laptop},
      {"title": "الساعات الذكية", "icon": Icons.watch},
    ],
  ),
  MarketModel(
    name: "أزياء",
    icon: Icons.checkroom_rounded,
    subCategories: [
      {"title": "ملابس رجالي", "icon": Icons.man},
      {"title": "ملابس نسائي", "icon": Icons.woman},
    ],
  ),
   MarketModel(
    name: "الجمال", 
    icon: Icons.face_retouching_natural_rounded,
    subCategories: [
      {"title": "عطور", "icon": Icons.opacity},
      {"title": "مكياج", "icon": Icons.brush},
    ],
  ),
  MarketModel(
    name: "غذاء",
    icon: Icons.restaurant_rounded,
    subCategories: [
      {"title": "مطاعم وجبات سريعة", "icon": Icons.fastfood_rounded},
      {"title": "مطاعم شعبية", "icon": Icons.kebab_dining_rounded},
    ],
  ),
  MarketModel(
    name: "عرطة", 
    icon: Icons.sell_rounded,
    subCategories: [], // قسم العروض
  ),
  MarketModel(
    name: "المنزل", 
    icon: Icons.chair_rounded,
    subCategories: [
      {"title": "أثاث", "icon": Icons.bed},
      {"title": "أجهزة منزلية", "icon": Icons.kitchen},
    ],
  ),
  MarketModel(
    name: "أجهزة", 
    icon: Icons.settings_input_component_rounded,
    subCategories: [
      {"title": "أجهزة كهربائية", "icon": Icons.bolt},
      {"title": "أدوات صيانة", "icon": Icons.build},
    ],
  ),
  MarketModel(
    name: "رياضة", 
    icon: Icons.fitness_center_rounded,
    subCategories: [
      {"title": "ملابس رياضية", "icon": Icons.sports_kabaddi},
      {"title": "أدوات رياضية", "icon": Icons.sports_basketball},
    ],
  ),
  MarketModel(
    name: "ألعاب", 
    icon: Icons.sports_esports_rounded,
    subCategories: [
      {"title": "بلايستيشن", "icon": Icons.videogame_asset},
      {"title": "ألعاب أطفال", "icon": Icons.toys},
    ],
  ),
  MarketModel(
    name: "صيدلية", 
    icon: Icons.medical_services_rounded,
    subCategories: [
      {"title": "أدوية", "icon": Icons.medication},
      {"title": "عناية شخصية", "icon": Icons.health_and_safety},
    ],
  ),
  MarketModel(
    name: "كتب", 
    icon: Icons.menu_book_rounded,
    subCategories: [
      {"title": "روايات", "icon": Icons.auto_stories},
      {"title": "كتب تعليمية", "icon": Icons.school},
    ],
  ),
  MarketModel(
    name: "حيوانات", 
    icon: Icons.pets_rounded,
    subCategories: [
      {"title": "طعام حيوانات", "icon": Icons.set_meal},
      {"title": "إكسسوارات", "icon": Icons.shutter_speed},
    ],
  ),
 
  MarketModel(
    name: "بقالة", 
    icon: Icons.shopping_basket_rounded,
    subCategories: [
      {"title": "خضروات", "icon": Icons.eco},
      {"title": "مواد غذائية", "icon": Icons.inventory_2},
    ],
  ),
  MarketModel(
    name: "سيارات", 
    icon: Icons.directions_car_rounded,
    subCategories: [
      {"title": "قطع غيار", "icon": Icons.settings},
    ],
  ),
];