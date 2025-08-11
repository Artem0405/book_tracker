// lib/data/model/book.dart
import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final int? pageCount;

  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.coverUrl,
    this.pageCount,
  });

  // Фабричный конструктор для создания экземпляра Book из JSON-ответа Google Books API
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    return Book(
      id: json['id'],
      title: volumeInfo['title'] ?? 'Без названия',
      authors: List<String>.from(volumeInfo['authors'] ?? []),
      coverUrl: imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'],
      pageCount: volumeInfo['pageCount'],
    );
  }

  @override
  List<Object?> get props => [id, title, authors, coverUrl, pageCount];
}