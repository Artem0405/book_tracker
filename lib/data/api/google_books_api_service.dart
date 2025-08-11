// lib/data/api/google_books_api_service.dart

import 'package:book_tracker_app/data/model/book.dart';
import 'package:dio/dio.dart';

class GoogleBooksApiService {
  // Создаем один экземпляр Dio для всего сервиса.
  // Это более эффективно, чем создавать его для каждого запроса.
  final Dio _dio = Dio();

  // Базовый URL для API Google Books.
  final String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// Ищет книги по заданному запросу [query].
  /// 
  /// Возвращает список объектов [Book].
  /// Если запрос пустой или произошла ошибка, возвращает пустой список.
  Future<List<Book>> searchBooks(String query) async {
    // Если строка поиска пуста, нет смысла делать запрос.
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Выполняем GET-запрос к API.
      final response = await _dio.get(
        _baseUrl,
        // Параметры запроса: 'q' - сам поисковый запрос, 'maxResults' - сколько результатов вернуть.
        queryParameters: {
          'q': query,
          'maxResults': 20,
        },
      );

      // Проверяем, что сервер ответил успешно (код 200).
      if (response.statusCode == 200) {
        final data = response.data;
        // Получаем список 'items' из ответа. Он может быть null, если ничего не найдено.
        final items = data['items'] as List?;
        if (items != null) {
          // Преобразуем каждый элемент списка (который является JSON-объектом)
          // в наш объект Book с помощью фабричного конструктора Book.fromJson.
          return items.map((item) => Book.fromJson(item)).toList();
        }
      }
      // Если статус код не 200 или 'items' равно null, возвращаем пустой список.
      return [];
    } on DioException catch (e) {
      // Ловим ошибки, специфичные для Dio (например, нет интернета).
      // В реальном приложении здесь была бы более сложная логика:
      // логирование, показ ошибки пользователю и т.д.
      print('Dio error searching books: $e');
      // В случае ошибки также возвращаем пустой список, чтобы приложение не падало.
      return [];
    } catch (e) {
      // Ловим любые другие непредвиденные ошибки.
      print('Unexpected error searching books: $e');
      return [];
    }
  }
}