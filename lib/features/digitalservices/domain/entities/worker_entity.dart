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
    required this.userId,
    required this.createdAt,
  });
}
