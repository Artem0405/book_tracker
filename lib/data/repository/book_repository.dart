// lib/data/repository/book_repository.dart

import 'package:book_tracker_app/data/model/book.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Репозиторий для управления книгами пользователя в Firestore.
///
/// Предоставляет методы для добавления, получения и обновления
/// информации о книгах.
class BookRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  /// Конструктор позволяет передавать экземпляры Firebase для тестирования.
  /// Если они не переданы, используются глобальные экземпляры.
  BookRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Приватный геттер для удобного доступа к UID текущего пользователя.
  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Добавляет книгу в коллекцию пользователя в Firestore.
  ///
  /// [book] - объект книги, полученный из Google Books API.
  /// [shelf] - строка, идентифицирующая полку ('wantToRead', 'reading', 'read').
  Future<void> addBook(model.Book book, String shelf) async {
    // Проверка аутентификации пользователя перед выполнением операции.
    if (_userId == null) {
      throw Exception('Пользователь не аутентифицирован. Невозможно добавить книгу.');
    }

    // Формируем документ для сохранения в Firestore.
    final bookData = {
      'googleBookId': book.id,
      'title': book.title,
      'authors': book.authors,
      'coverUrl': book.coverUrl,
      'pageCount': book.pageCount,
      'userId': _userId,
      'shelf': shelf,
      'addedAt': FieldValue.serverTimestamp(), // Используем серверное время для консистентности.
      // Можно добавить и другие поля по умолчанию, например:
      'currentPage': 0,
      'rating': 0,
    };

    // Добавляем новый документ в коллекцию 'user_books'.
    await _firestore.collection('user_books').add(bookData);
  }

  /// Получает поток (stream) книг с определенной полки для текущего пользователя.
  ///
  /// Использование Stream позволяет UI обновляться в реальном времени при
  /// любых изменениях в базе данных.
  Stream<List<model.Book>> getBooksFromShelf(String shelf) {
    if (_userId == null) {
      // Если пользователь не вошел, возвращаем пустой поток.
      return Stream.value([]);
    }

    return _firestore
        .collection('user_books')
        .where('userId', isEqualTo: _userId) // Фильтруем по ID пользователя.
        .where('shelf', isEqualTo: shelf)     // Фильтруем по названию полки.
        .orderBy('addedAt', descending: true) // Сортируем, чтобы новые книги были сверху.
        .snapshots() // snapshots() возвращает Stream<QuerySnapshot>.
        .map((snapshot) {
      // Преобразуем QuerySnapshot в список наших объектов Book.
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Преобразуем данные из Firestore в нашу локальную модель Book.
        return model.Book(
          id: doc.id, // ВАЖНО: id нашей модели - это ID документа в Firestore!
          title: data['title'] ?? 'Без названия',
          authors: List<String>.from(data['authors'] ?? []),
          coverUrl: data['coverUrl'],
          pageCount: data['pageCount'],
        );
      }).toList();
    });
  }

  /// Перемещает книгу на другую полку, обновляя поле 'shelf'.
  ///
  /// [bookId] - это ID документа в коллекции 'user_books'.
  /// [newShelf] - название новой полки.
  Future<void> moveBookToShelf(String bookId, String newShelf) async {
    if (_userId == null) {
      throw Exception('Пользователь не аутентифицирован.');
    }

    // Обновляем только одно поле 'shelf' в существующем документе.
    await _firestore.collection('user_books').doc(bookId).update({
      'shelf': newShelf,
    });
  }

  /// Удаляет книгу из коллекции пользователя.
  ///
  /// [bookId] - это ID документа в коллекции 'user_books'.
  Future<void> deleteBook(String bookId) async {
    if (_userId == null) {
      throw Exception('Пользователь не аутентифицирован.');
    }

    await _firestore.collection('user_books').doc(bookId).delete();
  }
}