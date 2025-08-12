// lib/data/model/book.dart

import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final int? pageCount;
  final List<String> categoryIds; // Поле для хранения ID категорий

  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.coverUrl,
    this.pageCount,
    this.categoryIds = const [], // Инициализация пустым списком
  });

  /// Фабричный конструктор для создания экземпляра Book из JSON-ответа Google Books API.
  /// Обратите внимание, что categoryIds здесь не заполняются, так как API их не предоставляет.
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    return Book(
      id: json['id'],
      title: volumeInfo['title'] ?? 'Без названия',
      authors: List<String>.from(volumeInfo['authors'] ?? []),
      coverUrl: imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'],
      pageCount: volumeInfo['pageCount'],
      // categoryIds остаются пустыми по умолчанию
    );
  }

  /// Фабричный конструктор для создания экземпляра Book из данных Firestore.
  /// Этот конструктор будет использоваться в нашем BookRepository.
  factory Book.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Book(
      id: documentId,
      title: data['title'] ?? 'Без названия',
      authors: List<String>.from(data['authors'] ?? []),
      coverUrl: data['coverUrl'],
      pageCount: data['pageCount'],
      // Читаем список ID категорий из Firestore
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
    );
  }

  // Переопределяем props для корректной работы сравнения объектов в Equatable.
  @override
  List<Object?> get props => [id, title, authors, coverUrl, pageCount, categoryIds];
}