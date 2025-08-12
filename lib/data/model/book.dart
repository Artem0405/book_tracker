// lib/data/model/book.dart

import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final int? pageCount;
  final List<String> categoryIds;
  final int currentPage;
  final String shelf; // Полка, на которой находится книга ('wantToRead', 'reading', 'read')
  final double rating; // Оценка книги от 0.0 до 5.0

  const Book({
    required this.id,
    required this.title,
    required this.shelf, // Сделали обязательным
    this.authors = const [],
    this.coverUrl,
    this.pageCount,
    this.categoryIds = const [],
    this.currentPage = 0,
    this.rating = 0.0, // Добавили в конструктор
  });

  /// Фабричный конструктор для создания экземпляра Book из JSON-ответа Google Books API.
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    return Book(
      id: json['id'],
      title: volumeInfo['title'] ?? 'Без названия',
      authors: List<String>.from(volumeInfo['authors'] ?? []),
      coverUrl: imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'],
      pageCount: volumeInfo['pageCount'],
      shelf: 'wantToRead', // По умолчанию, т.к. API не предоставляет эту информацию
    );
  }

  /// Фабричный конструктор для создания экземпляра Book из данных Firestore.
  factory Book.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Book(
      id: documentId,
      title: data['title'] ?? 'Без названия',
      authors: List<String>.from(data['authors'] ?? []),
      coverUrl: data['coverUrl'],
      pageCount: data['pageCount'],
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      currentPage: data['currentPage'] ?? 0,
      shelf: data['shelf'] ?? 'wantToRead', // Читаем полку из Firestore
      rating: (data['rating'] ?? 0.0).toDouble(), // Читаем рейтинг
    );
  }

  // Переопределяем props для корректной работы сравнения объектов в Equatable.
  @override
  List<Object?> get props => [
    id,
    title,
    authors,
    coverUrl,
    pageCount,
    categoryIds,
    currentPage,
    shelf, // Добавили полку в список
    rating, // Добавили рейтинг в список
  ];
}