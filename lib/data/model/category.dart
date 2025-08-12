// lib/data/model/category.dart
import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}