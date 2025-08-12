// lib/features/search/view/search_screen.dart

import 'package:book_tracker_app/data/api/google_books_api_service.dart';
import 'package:book_tracker_app/data/model/book.dart' as model;
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/features/search/cubit/search_cubit.dart';
import 'package:book_tracker_app/features/search/cubit/search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(GoogleBooksApiService()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  // Метод для отображения диалога добавления книги
  void _showAddBookDialog(BuildContext context, model.Book book) {
    // Создаем экземпляр репозитория прямо здесь.
    // В более крупном приложении его можно было бы получать через BlocProvider/RepositoryProvider.
    final bookRepository = BookRepository();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Добавить "${book.title}"?',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text('Выберите полку, на которую хотите добавить эту книгу.'),
          actions: <Widget>[
            TextButton(
              child: const Text('ОТМЕНА'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            // TODO: Добавить кнопки для других полок ('Читаю', 'Прочитано')
            FilledButton( // Используем более заметную кнопку
              child: const Text('ХОЧУ ПРОЧИТАТЬ'),
              onPressed: () async {
                try {
                  // Вызываем метод репозитория для добавления книги
                  await bookRepository.addBook(book, 'wantToRead');
                  Navigator.of(dialogContext).pop(); // Закрываем диалог

                  // Показываем подтверждение
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                      content: Text('Книга добавлена!'),
                      backgroundColor: Colors.green,
                    ));
                } catch (e) {
                  Navigator.of(dialogContext).pop();
                  // Показываем ошибку
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('Ошибка: $e'),
                      backgroundColor: Colors.red,
                    ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск книг')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Введите название или автора',
                hintText: 'Например, "1984" или "Оруэлл"',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.read<SearchCubit>().searchBooks(query);
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                switch (state.status) {
                  case SearchStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case SearchStatus.failure:
                    return Center(child: Text('Ошибка: ${state.errorMessage}'));
                  case SearchStatus.success:
                    if (state.books.isEmpty) {
                      return const Center(child: Text('Ничего не найдено. Попробуйте другой запрос.'));
                    }
                    // Результаты поиска
                    return ListView.builder(
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        final book = state.books[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: book.coverUrl != null
                                ? Image.network(
                              book.coverUrl!,
                              width: 50,
                              fit: BoxFit.cover,
                              // Обработка ошибок загрузки изображений
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book_online, size: 40),
                            )
                                : const Icon(Icons.book_online, size: 40),
                            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(book.authors.join(', ')),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () {
                              _showAddBookDialog(context, book);
                            },
                          ),
                        );
                      },
                    );
                  case SearchStatus.initial:
                  default:
                    return const Center(child: Text('Начните поиск, чтобы увидеть результаты.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}