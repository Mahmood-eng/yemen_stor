// =============================================================
// UserModel: نموذج بيانات المستخدم
// قابل للتبديل مع Supabase لاحقاً دون تغيير الـ UI
// =============================================================

class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String city;
  final String passwordHash; // نخزن hash وليس كلمة المرور الصريحة
  final String? profileImage; // مسار الصورة الشخصية
  final double balance; // رصيد المستخدم
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.passwordHash,
    this.profileImage,
    this.balance = 500.0, // رصيد مبدئي تجريبي
    required this.createdAt,
  });

  // --- من JSON إلى Object ---
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      passwordHash: json['passwordHash'] as String,
      profileImage: json['profileImage'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 500.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // --- من Object إلى JSON ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'city': city,
      'passwordHash': passwordHash,
      'profileImage': profileImage,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // --- نسخة معدلة من الكائن (مفيدة لتحديث البروفايل لاحقاً) ---
  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? city,
    String? passwordHash,
    String? profileImage,
    double? balance,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      passwordHash: passwordHash ?? this.passwordHash,
      profileImage: profileImage ?? this.profileImage,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // --- نسخة آمنة بدون passwordHash لعرضها في الـ UI ---
  Map<String, dynamic> toSafeJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'city': city,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'UserModel(id: $id, fullName: $fullName, phone: $phone, city: $city)';
}
