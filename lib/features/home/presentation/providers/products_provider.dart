import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductsProvider extends ChangeNotifier {
  // بيانات المنتجات المؤقتة (بديل لقاعدة البيانات حالياً)
  final List<ProductModel> _allProducts = [
    const ProductModel(
      id: "1",
      name: "حذاء رياضي نايك",
      description: "حذاء رياضي مريح جداً مناسب للجري والاستخدام اليومي، مصنوع من مواد عالية الجودة تسمح بتهوية القدم.",
      price: 25000,
      image: "assets/images/shoes.jpg",
      category: "ملابس وأحذية",
      rating: 4.8,
      reviewsCount: 342,
    ),
    const ProductModel(
      id: "2",
      name: "ساعة ذكية آبل",
      description: "ساعة ذكية متطورة تقيس نبضات القلب وتتبع نشاطك الرياضي مع شاشة Retina واضحة.",
      price: 150000,
      image: "assets/images/watch.jpg",
      category: "إلكترونيات",
      rating: 4.9,
      reviewsCount: 1024,
    ),
    const ProductModel(
      id: "3",
      name: "عطر فاخر ديور",
      description: "عطر رجالي مميز بثبات عالي ورائحة فواحة تناسب جميع المناسبات الرسمية.",
      price: 45000,
      image: "assets/images/perfume.jpg",
      category: "عطور",
      rating: 4.7,
      reviewsCount: 89,
    ),
    const ProductModel(
      id: "4",
      name: "لابتوب ماك بوك برو",
      description: "لابتوب قوي جداً للمصممين والمبرمجين مع معالج M2 وشاشة مذهلة.",
      price: 850000,
      image: "assets/images/laptop.jpg",
      category: "إلكترونيات",
      rating: 5.0,
      reviewsCount: 560,
    ),
  ];

  List<ProductModel> _filteredProducts = [];
  String _searchQuery = "";

  ProductsProvider() {
    _filteredProducts = _allProducts;
  }

  List<ProductModel> get products => _filteredProducts;
  List<ProductModel> get allProducts => _allProducts;

  // دالة البحث
  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // فلترة بالقسم
  void filterByCategory(String category) {
    if (category == "الكل") {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts.where((p) => p.category == category).toList();
    }
    notifyListeners();
  }
}
