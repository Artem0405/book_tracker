// lib/features/search/view/search_screen.dart

import 'package:book_tracker_app/data/api/google_books_api_service.dart';
import 'package:book_tracker_app/data/model/book.dart' as model;
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/features/manual_add/view/manual_add_book_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск книг')),
      // Кнопка для перехода на экран ручного добавления
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ManualAddBookScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Введите название или автора',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (query) {
                context.read<SearchCubit>().searchBooks(query);
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
                      return const Center(child: Text('Ничего не найдено.'));
                    }
                    return ListView.builder(
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        final book = state.books[index];
                        return ListTile(
                          leading: book.coverUrl != null
                              ? Image.network(book.coverUrl!)
                              : const Icon(Icons.book_online),
                          title: Text(book.title),
                          subtitle: Text(book.authors.join(', ')),
                          onTap: () {
                            // Показываем диалог для выбора полки
                            _showAddBookDialog(context, book);
                          },
                        );
                      },
                    );
                  case SearchStatus.initial:
                  default:
                    return const Center(
                        child: Text('Начните поиск, чтобы увидеть результаты.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Метод для показа диалога выбора полки
  void _showAddBookDialog(BuildContext context, model.Book book) {
    final bookRepository = BookRepository();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Используем SimpleDialog для предоставления выбора
        return SimpleDialog(
          title: Text('Добавить "${book.title}" на полку:'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () async {
                await bookRepository.addBook(book, 'wantToRead');
                Navigator.of(dialogContext).pop();
              },
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: const Text('Хочу прочитать'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                await bookRepository.addBook(book, 'reading');
                Navigator.of(dialogContext).pop();
              },
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: const Text('Читаю сейчас'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                await bookRepository.addBook(book, 'read');
                Navigator.of(dialogContext).pop();
              },
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: const Text('Прочитано'),
            ),
          ],
        );
      },
    ).then((_) {
      // .then() выполнится после закрытия диалога, независимо от того,
      // как он был закрыт (выбором опции или нажатием вне диалога).
      // Это хорошее место для показа SnackBar, но мы покажем его только если
      // книга была реально добавлена.
      // В нашем случае, мы добавили SnackBar в сам метод addBook,
      // поэтому здесь его можно убрать или оставить для общих случаев.
      // Для простоты оставим как есть.
    });
  }
}