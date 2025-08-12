// lib/data/repository/book_repository.dart

import 'dart:io'; // Оставим импорт, если в будущем вернем загрузку
import 'package:book_tracker_app/data/model/book.dart' as model;
import 'package:book_tracker_app/data/model/quote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Пока не используем

class BookRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // Пока не используем

  BookRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Приватный геттер для удобного доступа к UID текущего пользователя
  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Добавляет книгу из Google Books API в коллекцию пользователя.
  Future<void> addBook(model.Book book, String shelf) async {
    if (_userId == null) {
      throw Exception('Пользователь не аутентифицирован.');
    }

    final bookData = {
      'googleBookId': book.id,
      'title': book.title,
      'authors': book.authors,
      'coverUrl': book.coverUrl,
      'pageCount': book.pageCount,
      'userId': _userId,
      'shelf': shelf,
      'addedAt': FieldValue.serverTimestamp(),
      'currentPage': 0,
      'rating': 0.0,
    };

    await _firestore.collection('user_books').add(bookData);
  }

  /// Добавляет книгу, введенную вручную.
  Future<void> addManualBook({
    required String title,
    required String author,
    required String shelf,
    int? pageCount,
    File? imageFile, // Параметр остается, но мы его не используем
  }) async {
    if (_userId == null) throw Exception('Пользователь не аутентифицирован.');

    // В этой версии мы не загружаем обложку, поэтому coverUrl всегда null.
    const String? coverUrl = null;

    final bookData = {
      'googleBookId': null, // У ручных книг нет Google ID
      'title': title,
      'authors': [author], // Сохраняем как массив для единообразия
      'coverUrl': coverUrl,
      'pageCount': pageCount,
      'userId': _userId,
      'shelf': shelf,
      'addedAt': FieldValue.serverTimestamp(),
      'currentPage': 0,
      'rating': 0.0,
    };

    await _firestore.collection('user_books').add(bookData);
  }

  /// Получает поток (stream) книг с определенной полки.
  Stream<List<model.Book>> getBooksFromShelf(String shelf) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('user_books')
        .where('userId', isEqualTo: _userId)
        .where('shelf', isEqualTo: shelf)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return model.Book(
          id: doc.id,
          title: data['title'] ?? 'Без названия',
          authors: List<String>.from(data['authors'] ?? []),
          coverUrl: data['coverUrl'],
          pageCount: data['pageCount'],
        );
      }).toList();
    });
  }

  /// Перемещает книгу на другую полку.
  Future<void> moveBookToShelf(String bookId, String newShelf) async {
    if (_userId == null) throw Exception('Пользователь не аутентифицирован.');
    await _firestore.collection('user_books').doc(bookId).update({
      'shelf': newShelf,
    });
  }

  /// Удаляет книгу из коллекции пользователя.
  Future<void> deleteBook(String bookId) async {
    if (_userId == null) throw Exception('Пользователь не аутентифицирован.');
    await _firestore.collection('user_books').doc(bookId).delete();
  }

  /// Получает поток данных одной книги по ее ID.
  Stream<model.Book?> getBookDetails(String bookId) {
    if (_userId == null) return Stream.value(null);

    return _firestore
        .collection('user_books')
        .doc(bookId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data()!;
      return model.Book(
        id: snapshot.id,
        title: data['title'] ?? 'Без названия',
        authors: List<String>.from(data['authors'] ?? []),
        coverUrl: data['coverUrl'],
        pageCount: data['pageCount'],
      );
    });
  }

  /// Получает поток цитат для конкретной книги.
  Stream<List<Quote>> getQuotesForBook(String bookId) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('user_books')
        .doc(bookId)
        .collection('quotes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Quote.fromFirestore(doc)).toList());
  }

  /// Добавляет новую цитату для книги.
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