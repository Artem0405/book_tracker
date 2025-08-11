// lib/features/search/view/search_screen.dart
import 'package:book_tracker_app/data/api/google_books_api_service.dart';
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
                            // TODO: Реализовать добавление книги в библиотеку
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(content: Text('Добавляем "${book.title}"...')));
                          },
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