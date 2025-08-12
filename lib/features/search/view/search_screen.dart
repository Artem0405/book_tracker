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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск книг')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true, // Клавиатура появляется сразу при открытии экрана
              decoration: const InputDecoration(
                labelText: 'Введите название или автора',
                suffixIcon: Icon(Icons.search),
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
                      return const Center(child: Text('Ничего не найдено.'));
                    }
                    return ListView.builder(
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        final book = state.books[index];
                        return ListTile(
                          leading: book.coverUrl != null
                              ? Image.network(book.coverUrl!)
                              : const Icon(Icons.book_online, size: 50),
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

  // <<< ИЗМЕНЕНИЕ ЗДЕСЬ >>>
  // Метод для показа диалога выбора полки
  void _showAddBookDialog(BuildContext context, model.Book book) {
    final bookRepository = BookRepository();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // SimpleDialog идеально подходит для предоставления списка опций
        return SimpleDialog(
          title: Text('Добавить "${book.title}" на полку:'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                // Добавляем книгу и закрываем диалог
                bookRepository.addBook(book, 'wantToRead');
                Navigator.of(dialogContext).pop();
              },
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text('Хочу прочитать', style: TextStyle(fontSize: 16)),
            ),
            SimpleDialogOption(
              onPressed: () {
                bookRepository.addBook(book, 'reading');
                Navigator.of(dialogContext).pop();
              },
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text('Читаю сейчас', style: TextStyle(fontSize: 16)),
            ),
            SimpleDialogOption(
              onPressed: () {
                bookRepository.addBook(book, 'read');
                Navigator.of(dialogContext).pop();
              },
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text('Прочитано', style: TextStyle(fontSize: 16)),
            ),
            // Опция "Отмена" для удобства
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text('ОТМЕНА', style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
          ],
        );
      },
    ).then((_) { // .then() выполнится после того, как диалог будет закрыт
      // Показываем подтверждение, но только если книга была действительно добавлена
      // (Этот блок выполнится даже при отмене, поэтому сообщение общее,
      // но можно усложнить логику, если нужно)
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Действие выполнено'),
          duration: Duration(seconds: 1),
        ));
    });
  }
}