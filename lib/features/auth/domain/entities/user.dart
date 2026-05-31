class User {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? city;
  final bool emailVerified;
  final String? addressDetails;
  final String? accountNumber;
  final String? balance;
  final String? role;
  final String? imageUrl;
  final String? password;
  final String? confirmPassword;


  User({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.city,
    this.emailVerified = false,
    this.addressDetails,
    this.accountNumber,
    this.balance = '0',
    this.role,
    this.imageUrl,
    this.password,
    this.confirmPassword,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      city: json['city'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      addressDetails: json['addressDetails'] as String?,
      accountNumber: json['accountNumber'] as String?,
      balance: json['balance'] as String?,
      role: json['role'] as String?,
      imageUrl: json['imageUrl'] as String?,
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
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
      'addressDetails': addressDetails,
      'accountNumber': accountNumber,
      'balance': balance,
      'role': role,
      'imageUrl': imageUrl,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? city,
    String? password,
    String? confirmPassword,
    String? imageUrl,
    bool? emailVerified,
    String? addressDetails,
    String? accountNumber,
    String? balance,
    String? role,

  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      emailVerified: emailVerified ?? this.emailVerified,
      addressDetails: addressDetails ?? this.addressDetails,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
