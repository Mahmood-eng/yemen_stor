class WorkerEntity {
  final String id;
  final String name;
  final String profession; // e.g. "سباك", "كهربائي", "نجار", "مبرمج", "مصمم"
  final int experienceYears;
  final String phone;
  final String city;
  final String address;
  final String bio;
  final String imageUrl;
  final double rating;
  final String status; // "متاح", "مشغول"
  final bool isAvailable;
  final bool isVerified;
  final String category; // "عمالة مهنية", "كوادر علمية", "استشارات مهنية", "عمالة مهنية"
  final List<String> portfolioLinks; // معرض الأعمال (روابط صور)
  final List<String> projectLinks;  // GitHub/Behance etc
  final String? cvUrl;
  final List<String> certificates;  // الشهادات الأكاديمية
  final String userId; // User who registered as worker
  final dynamic createdAt;

  WorkerEntity({
    required this.id,
    required this.name,
    required this.profession,
    required this.experienceYears,
    required this.phone,
    required this.city,
    required this.address,
    required this.bio,
    required this.imageUrl,
    this.rating = 5.0,
    this.status = 'متاح',
    this.isAvailable = true,
    this.isVerified = false,
    this.category = 'عمالة مهنية',
    this.portfolioLinks = const [],
    this.projectLinks = const [],
    this.cvUrl,
    this.certificates = const [],
    required this.userId,
    required this.createdAt,
  });
}
