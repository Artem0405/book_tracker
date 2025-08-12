// lib/data/repository/book_repository.dart
import 'package:book_tracker_app/data/model/book.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  BookRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Получаем UID текущего пользователя
  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Добавляет книгу в коллекцию пользователя в Firestore.
  Future<void> addBook(model.Book book, String shelf) async {
    if (_userId == null) {
      throw Exception('Пользователь не аутентифицирован.');
    }

    // Создаем документ книги, добавляя к нему ID пользователя и полку
    final bookData = {
      'googleBookId': book.id,
      'title': book.title,
      'authors': book.authors,
      'coverUrl': book.coverUrl,
      'pageCount': book.pageCount,
      'userId': _userId,
      'shelf': shelf, // 'wantToRead', 'reading', 'read'
      'addedAt': FieldValue.serverTimestamp(), // Дата добавления
    };

    // Добавляем в коллекцию 'user_books'
    await _firestore.collection('user_books').add(bookData);
  }

  /// Получает поток (stream) книг с определенной полки.
  Stream<List<model.Book>> getBooksFromShelf(String shelf) {
    if (_userId == null) {
      return Stream.value([]); // Возвращаем пустой поток, если пользователя нет
    }

    return _firestore
        .collection('user_books')
        .where('userId', isEqualTo: _userId) // Только книги этого пользователя
        .where('shelf', isEqualTo: shelf)     // Только с нужной полки
        .orderBy('addedAt', descending: true) // Сортируем по дате добавления
        .snapshots() // snapshots() возвращает Stream
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Преобразуем данные из Firestore в нашу модель Book.
        // Обратите внимание, что мы создаем "локальную" модель.
        // Здесь можно было бы создать отдельную модель для Firestore, но для простоты используем ту же.
        return model.Book(
          id: doc.id, // Используем ID документа Firestore
          title: data['title'] ?? 'Без названия',
          authors: List<String>.from(data['authors'] ?? []),
          coverUrl: data['coverUrl'],
          pageCount: data['pageCount'],
        );
      }).toList();
    });
  }
}