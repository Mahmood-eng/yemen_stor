class User {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? city;
  final bool emailVerified;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.city,
    this.emailVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      city: json['city'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'city': city,
      'emailVerified': emailVerified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? city,
    bool? emailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
