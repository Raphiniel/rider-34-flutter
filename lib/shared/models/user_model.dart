import 'package:equatable/equatable.dart';

/// User model — mirrors the Supabase `users` table.
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final double rating;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    this.rating = 5.0,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'passenger'),
        orElse: () => UserRole.passenger,
      ),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatar_url': avatarUrl,
    'role': role.name,
    'rating': rating,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, email, phone, role];
}

enum UserRole { passenger, driver }
