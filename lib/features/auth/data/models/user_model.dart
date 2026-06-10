import 'package:yemen_stor/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.phoneNumber,
    super.city,
    super.emailVerified,
    super.addressDetails,
    super.accountNumber,
    super.balance,
    super.role,
    super.imageUrl,
    super.password,
    super.confirmPassword,
    super.balanceYER,
    super.balanceSAR,
    super.balanceUSD,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: _parseStringSafe(json['displayName']),
      phoneNumber: _parseStringSafe(json['phoneNumber']),
      city: _parseStringSafe(json['city']),
      emailVerified: json['emailVerified'] as bool? ?? false,
      addressDetails: _parseStringSafe(json['addressDetails']),
      accountNumber: _parseStringSafe(json['accountNumber']),
      balance: _parseStringSafe(json['balance']),
      role: _parseStringSafe(json['role']),
      imageUrl: _parseStringSafe(json['imageUrl']),
      password: _parseStringSafe(json['password']),
      confirmPassword: _parseStringSafe(json['confirmPassword']),
      balanceYER: (json['balanceYER'] as num?)?.toDouble() ?? 0.0,
      balanceSAR: (json['balanceSAR'] as num?)?.toDouble() ?? 0.0,
      balanceUSD: (json['balanceUSD'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String? _parseStringSafe(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      if (value.isNotEmpty) {
        return value.first?.toString();
      }
      return null;
    }
    return value.toString();
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
      'balanceYER': balanceYER,
      'balanceSAR': balanceSAR,
      'balanceUSD': balanceUSD,
    };
  }

  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    String? city,
    String? phoneNumber,
    String? accountNumber,
    String? role,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? firebaseUser.phoneNumber ?? '',
      displayName: firebaseUser.displayName,
      phoneNumber: phoneNumber ?? firebaseUser.phoneNumber,
      city: city,
      emailVerified: firebaseUser.emailVerified,
      accountNumber: accountNumber,
      role: role,
    );
  }
}
