import 'models.dart';

/// Cloud user profile returned by `/get_user_data`.
class UserCloudModel {
  const UserCloudModel({
    required this.id,
    required this.cloudUserId,
    required this.email,
    required this.name,
    required this.surname,
    required this.role,
    required this.createdAt,
    this.password,
    this.birthdate,
    this.birthplace,
    this.city,
    this.gender,
    this.houseNumber,
    this.personalCode,
    this.phoneNumber,
    this.postalCode,
    this.street,
    this.totpSecret,
    this.twoFaMethod,
  });

  final int id;
  final String cloudUserId;
  final String email;
  final String name;
  final String surname;
  final String role;
  final String createdAt;
  final String? password;

  final String? birthdate;
  final String? birthplace;
  final String? city;
  final String? gender;
  final String? houseNumber;
  final String? personalCode;
  final String? phoneNumber;
  final String? postalCode;
  final String? street;
  final String? totpSecret;
  final TwoFaMethod? twoFaMethod;

  factory UserCloudModel.fromJson(Map<String, dynamic> json) {
    return UserCloudModel(
      id: _asInt(json['id']) ?? 0,
      cloudUserId: json['cloud_user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      surname: json['surname']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      password: _asNullableString(json['password']),
      birthdate: _asNullableString(json['birthdate']),
      birthplace: _asNullableString(json['birthplace']),
      city: _asNullableString(json['city']),
      gender: _asNullableString(json['gender']),
      houseNumber: _asNullableString(json['house_number']),
      personalCode: _asNullableString(json['personal_code']),
      phoneNumber: _asNullableString(json['phone_number']),
      postalCode: _asNullableString(json['postal_code']),
      street: _asNullableString(json['street']),
      totpSecret: _asNullableString(json['totp_secret']),
      twoFaMethod: twoFaMethodFromName(
        _asNullableString(json['two_fa_method']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cloud_user_id': cloudUserId,
      'email': email,
      'name': name,
      'surname': surname,
      'role': role,
      'created_at': createdAt,
      'password': password,
      'birthdate': birthdate,
      'birthplace': birthplace,
      'city': city,
      'gender': gender,
      'house_number': houseNumber,
      'personal_code': personalCode,
      'phone_number': phoneNumber,
      'postal_code': postalCode,
      'street': street,
      'totp_secret': totpSecret,
      'two_fa_method': twoFaMethod?.name,
    };
  }

  /// Fields collected during sign-up (excludes password).
  Map<String, dynamic> toSignUpJson() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'phone_number': phoneNumber,
      'street': street,
      'house_number': houseNumber,
      'city': city,
      'postal_code': postalCode,
      'gender': gender,
      'birthdate': birthdate,
      'birthplace': birthplace,
      'password': password,
    };
  }
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
