// lib/data/repository/book_repository.dart

import 'dart:io';
import 'package:book_tracker_app/data/model/book.dart' as model;
import 'package:book_tracker_app/data/model/quote.dart';
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

  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Добавляет книгу из Google Books API в коллекцию пользователя.
  Future<void> addBook(model.Book book, String shelf) async {
    if (_userId == null) throw Exception('Пользователь не аутентифицирован.');

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
      'categoryIds': [], // Добавляем пустое поле для категорий
    };

    await _firestore.collection('user_books').add(bookData);
  }

  /// Добавляет книгу, введенную вручную.
  Future<void> addManualBook({
    required String title,
    required String author,
    required String shelf,
    int? pageCount,
    File? imageFile,
  }) async {
    if (_userId == null) throw Exception('Пользователь не аутентифицирован.');

    const String? coverUrl = null;

    final bookData = {
      'googleBookId': null,
      'title': title,
      'authors': [author],
      'coverUrl': coverUrl,
      'pageCount': pageCount,
      'userId': _userId,
      'shelf': shelf,
      'addedAt': FieldValue.serverTimestamp(),
      'currentPage': 0,
      'rating': 0.0,
      'categoryIds': [], // Добавляем пустое поле для категорий
    };

    await _firestore.collection('user_books').add(bookData);
  }

  /// Получает поток книг с определенной полки.
  Stream<List<model.Book>> getBooksFromShelf(String shelf) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('user_books')
        .where('userId', isEqualTo: _userId)
        .where('shelf', isEqualTo: shelf)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => model.Book.fromFirestore(doc.data(), doc.id))
          .toList();
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

  /// <<< НОВЫЙ МЕТОД >>>
  /// Обновляет список категорий для конкретной книги.
  Future<void> updateBookCategories(String bookId, List<String> categoryIds) async {
    if (_userId == null) throw Exception('Пользователь не аутентифицирован.');
    await _firestore.collection('user_books').doc(bookId).update({
      'categoryIds': categoryIds,
    });
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
      // Используем новый конструктор fromFirestore
      return model.Book.fromFirestore(snapshot.data()!, snapshot.id);
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