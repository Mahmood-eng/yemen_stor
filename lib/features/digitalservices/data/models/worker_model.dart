import '../../domain/entities/worker_entity.dart';

class WorkerModel extends WorkerEntity {
  WorkerModel({
    required super.id,
    required super.name,
    required super.profession,
    required super.experienceYears,
    required super.phone,
    required super.city,
    required super.address,
    required super.bio,
    required super.imageUrl,
    super.rating = 5.0,
    super.status = 'متاح',
    super.isAvailable = true,
    super.isVerified = false,
    super.category = 'عمالة مهنية',
    super.portfolioLinks = const [],
    super.projectLinks = const [],
    super.cvUrl,
    super.certificates = const [],
    required super.userId,
    required super.createdAt,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profession: json['profession'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      bio: json['bio'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 5.0).toDouble(),
      status: json['status'] ?? 'متاح',
      isAvailable: json['isAvailable'] ?? true,
      isVerified: json['isVerified'] ?? false,
      category: json['category'] ?? 'عمالة مهنية',
      portfolioLinks: List<String>.from(json['portfolioLinks'] ?? []),
      projectLinks: List<String>.from(json['projectLinks'] ?? []),
      cvUrl: json['cvUrl'],
      certificates: List<String>.from(json['certificates'] ?? []),
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profession': profession,
      'experienceYears': experienceYears,
      'phone': phone,
      'city': city,
      'address': address,
      'bio': bio,
      'imageUrl': imageUrl,
      'rating': rating,
      'status': status,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'category': category,
      'portfolioLinks': portfolioLinks,
      'projectLinks': projectLinks,
      'cvUrl': cvUrl,
      'certificates': certificates,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}
