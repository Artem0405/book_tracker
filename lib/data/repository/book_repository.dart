// lib/data/repository/book_repository.dart

import 'package:book_tracker_app/data/model/book.dart' as model;
import 'package:book_tracker_app/data/model/quote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  // Конструктор позволяет передавать моки для тестирования,
  // но по умолчанию использует реальные экземпляры Firebase.
  BookRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Приватный геттер для удобного доступа к ID текущего пользователя.
  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Добавляет книгу в коллекцию пользователя в Firestore.
  Future<void> addBook(model.Book book, String shelf) async {
    if (_userId == null) {
      throw Exception('Пользователь не аутентифицирован.');
    }

    // Готовим данные для сохранения в Firestore.
    final bookData = {
      'googleBookId': book.id,
      'title': book.title,
      'authors': book.authors,
      'coverUrl': book.coverUrl,
      'pageCount': book.pageCount,
      'userId': _userId,
      'shelf': shelf, // 'wantToRead', 'reading', 'read'
      'addedAt': FieldValue.serverTimestamp(), // Используем серверное время для консистентности.
    };

    // Добавляем документ в коллекцию 'user_books'. Firestore автоматически сгенерирует ID.
    await _firestore.collection('user_books').add(bookData);
  }

  /// Получает поток (stream) книг с определенной полки для текущего пользователя.
  Stream<List<model.Book>> getBooksFromShelf(String shelf) {
    if (_userId == null) {
      return Stream.value([]); // Возвращаем пустой поток, если пользователя нет.
    }

    return _firestore
        .collection('user_books')
        .where('userId', isEqualTo: _userId) // Только книги этого пользователя.
        .where('shelf', isEqualTo: shelf)     // Только с нужной полки.
        .orderBy('addedAt', descending: true) // Сортируем по дате добавления.
        .snapshots() // snapshots() возвращает Stream<QuerySnapshot>.
        .map((snapshot) {
      // Преобразуем QuerySnapshot в список наших объектов Book.
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return model.Book(
          id: doc.id, // ID документа в Firestore, а не googleBookId.
          title: data['title'] ?? 'Без названия',
          authors: List<String>.from(data['authors'] ?? []),
          coverUrl: data['coverUrl'],
          pageCount: data['pageCount'],
        );
      }).toList();
    });
  }

  /// Перемещает книгу на другую полку, обновляя поле 'shelf'.
  Future<void> moveBookToShelf(String bookId, String newShelf) async {
    if (_userId == null) {
      throw Exception('Пользователь не аутентифицирован.');
    }
    // bookId - это ID документа в нашей коллекции user_books.
    await _firestore.collection('user_books').doc(bookId).update({
      'shelf': newShelf,
    });
  }

  /// Получает поток данных одной книги по ее ID документа в Firestore.
  Stream<model.Book?> getBookDetails(String bookId) {
    if (_userId == null) return Stream.value(null);

    return _firestore
        .collection('user_books')
        .doc(bookId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null; // Если документа нет, возвращаем null.
      final data = snapshot.data()!;
      return model.Book(
        id: snapshot.id,
        title: data['title'],
        authors: List<String>.from(data['authors']),
        coverUrl: data['coverUrl'],
        pageCount: data['pageCount'],
      );
    });
  }

  /// Получает поток цитат для конкретной книги из вложенной коллекции.
  Stream<List<Quote>> getQuotesForBook(String bookId) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('user_books')
        .doc(bookId)
        .collection('quotes') // Обращаемся к вложенной коллекции 'quotes'.
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Quote.fromFirestore(doc)).toList());
  }

  /// Добавляет новую цитату для книги во вложенную коллекцию.
  Future<void> addQuoteForBook(String bookId, String text, {int? pageNumber}) async {
    if (_userId == null) throw Exception('Пользователь не аутентифицирован.');

    final quoteData = {
      'text': text,
      'pageNumber': pageNumber,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('user_books')
        .doc(bookId)
        .collection('quotes')
        .add(quoteData);
  }
}