import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final String marketId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.marketId,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      name: json['categoryName'] ?? json['name'] ?? '',
      iconName: json['iconName'] ?? json['icon'] ?? 'category',
      marketId: json['marketId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': id,
      'name': name,
      'iconName': iconName,
      'marketId': marketId,
    };
  }

  // تحويل البيانات لشكل الخريطة القديم لضمان عمل الودجات الحالية
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'title': name,
      'icon': MarketModel.getIconData(iconName),
    };
  }
}

class MarketModel {
  final String id;
  final String name;
  final String iconName;
  final List<CategoryModel> categories;

  MarketModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.categories = const [],
  });

  factory MarketModel.fromFirestore(
    Map<String, dynamic> json,
    String id, {
    List<CategoryModel> categories = const [],
  }) {
    return MarketModel(
      id: id,
      name: json['marketName'] ?? json['name'] ?? '',
      iconName: json['iconName'] ?? json['icon'] ?? 'category',
      categories: categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }

  IconData get icon => getIconData(iconName);

  List<Map<String, dynamic>> get subCategories =>
      categories.map((c) => c.toLegacyMap()).toList();

  static IconData getIconData(String? name) {
    switch (name) {
      case 'devices_other_rounded':
        return Icons.devices_other_rounded;
      case 'smartphone':
        return Icons.smartphone;
      case 'laptop':
        return Icons.laptop;
      case 'router':
        return Icons.router;
      case 'checkroom_rounded':
        return Icons.checkroom_rounded;
      case 'man':
        return Icons.man;
      case 'woman':
        return Icons.woman;
      case 'child_care_outlined':
        return Icons.child_care_outlined;
      case 'face_retouching_natural_sharp':
        return Icons.face_retouching_natural_sharp;
      case 'opacity':
        return Icons.opacity;
      case 'brush':
        return Icons.brush;
      case 'restaurant_rounded':
        return Icons.restaurant_rounded;
      case 'fastfood_rounded':
        return Icons.fastfood_rounded;
      case 'kebab_dining_outlined':
        return Icons.kebab_dining_outlined;
      case 'sell_rounded':
        return Icons.sell_rounded;
      case 'chair_rounded':
        return Icons.chair_rounded;
      case 'bed':
        return Icons.bed;
      case 'kitchen':
        return Icons.kitchen;
      case 'settings_input_component_rounded':
        return Icons.settings_input_component_rounded;
      case 'bolt':
        return Icons.bolt;
      case 'build':
        return Icons.build;
      case 'fitness_center_rounded':
        return Icons.fitness_center_rounded;
      case 'sports_kabaddi':
        return Icons.sports_kabaddi;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'sports_esports_rounded':
        return Icons.sports_esports_rounded;
      case 'videogame_asset':
        return Icons.videogame_asset;
      case 'toys':
        return Icons.toys;
      case 'medical_services_rounded':
        return Icons.medical_services_rounded;
      case 'medication':
        return Icons.medication;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'school':
        return Icons.school;
      case 'pets_rounded':
        return Icons.pets_rounded;
      case 'set_meal':
        return Icons.set_meal;
      case 'shutter_speed':
        return Icons.shutter_speed;
      case 'shopping_basket_rounded':
        return Icons.shopping_basket_rounded;
      case 'eco':
        return Icons.eco;
      case 'inventory_2':
        return Icons.inventory_2;
      case 'directions_car_rounded':
        return Icons.directions_car_rounded;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.category;
    }
  }
}
