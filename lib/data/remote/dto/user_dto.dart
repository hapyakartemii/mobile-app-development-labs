import 'package:flutter_lab1/domain/entities/app_user.dart';

/// User as the API sends it: `{id, name, email, createdAt}`.
class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    createdAt: json['createdAt'] as String,
  );

  factory UserDto.fromEntity(AppUser user) => UserDto(
    id: user.id,
    name: user.name,
    email: user.email,
    createdAt: user.createdAt.toIso8601String(),
  );

  final String id;
  final String name;
  final String email;
  final String createdAt;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'createdAt': createdAt,
  };

  AppUser toEntity() => AppUser(
    id: id,
    name: name,
    email: email,
    createdAt: DateTime.parse(createdAt),
  );
}

/// Reply of `/auth/login` and `/auth/register`: JWT plus the user.
class AuthResponseDto {
  const AuthResponseDto({required this.token, required this.user});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      AuthResponseDto(
        token: json['token'] as String,
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      );

  final String token;
  final UserDto user;
}
