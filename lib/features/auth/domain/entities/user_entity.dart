class UserEntity {
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
  final double balanceYER;
  final double balanceSAR;
  final double balanceUSD;

  UserEntity({
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
    this.balanceYER = 0.0,
    this.balanceSAR = 0.0,
    this.balanceUSD = 0.0,
  });

  UserEntity copyWith({
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
    double? balanceYER,
    double? balanceSAR,
    double? balanceUSD,
  }) {
    return UserEntity(
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
      balanceYER: balanceYER ?? this.balanceYER,
      balanceSAR: balanceSAR ?? this.balanceSAR,
      balanceUSD: balanceUSD ?? this.balanceUSD,
    );
  }
}
