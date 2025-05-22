import 'package:event_app/models/blog_approved.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/models/user.dart';

class UserModel {
  final int id;
  final String? full_Name;
  final String? email;
  final String? photo;
  final String? description;
  final String? role;
  final String? phone;
  final String? address;
  final int? budget;
  final double? averageRating;
  final List<BlogApproved> blogs;

  UserModel({
    required this.id,
    this.full_Name,
    this.email,
    this.photo,
    this.phone,
    this.address,
    this.role,
    this.description,
    this.averageRating,
    this.budget,
    required this.blogs,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      full_Name: json['full_name'],
      email: json['email'] ?? '',
      photo: json['photo'],
      phone: json['phone'],
      address: json['address'],
      budget: json['budget'],
      role: json['role'],
      description: json['description'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      blogs: (json['blogs'] as List?)
              ?.map((i) => BlogApproved.fromJson(i))
              .toList() ??
          [],
    );
  }
}
