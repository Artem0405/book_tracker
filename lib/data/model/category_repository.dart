// lib/data/repository/category_repository.dart
import 'package:book_tracker_app/data/model/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Получает все стандартные категории и категории текущего пользователя.
  Stream<List<Category>> getCategories() {
    if (_userId == null) return Stream.value([]);
    // <<< ИЗМЕНЕНИЕ ЗДЕСЬ >>>
    // Теперь мы ищем документы, где userId либо 'default', либо ID текущего пользователя.
    // Это Firestore умеет делать без проблем!
    return _firestore.collection('categories')
        .where('userId', whereIn: ['default', _userId])
        .snapshots()
        .map((snapshot) =>
    snapshot.docs
        .map((doc) => Category.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name))
    );
  }

    /// Получает список категорий по их ID.
  /// Это нужно, чтобы отобразить имена категорий на экране деталей книги.
  Future<List<Category>> getCategoriesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snapshot = await _firestore.collection('categories')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc.data(), doc.id)).toList();
  }

  /// Создает новую категорию для текущего пользователя.
  Future<void> createCategory(String name) async {
    if (_userId == null) throw Exception('Пользователь не аутентифицирован');

    // Проверяем все доступные категории
    final allCategoriesSnapshot = await _firestore.collection('categories')
        .where('userId', whereIn: ['default', _userId])
        .get();

    final doesExist = allCategoriesSnapshot.docs
        .any((doc) => doc.data()['name'].toString().toLowerCase() == name.toLowerCase());

    if (doesExist) {
      throw Exception('Категория с таким именем уже существует');
    }

    await _firestore.collection('categories').add({
      'name': name,
      'userId': _userId,
      'isDefault': false, // Оставляем для ясности
    });
  }
}
