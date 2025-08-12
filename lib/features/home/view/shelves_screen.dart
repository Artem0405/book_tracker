// lib/features/home/view/shelves_screen.dart

import 'package:book_tracker_app/common_widgets/book_cover_widget.dart';
import 'package:book_tracker_app/data/model/book.dart';
import 'package:book_tracker_app/data/model/category.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/data/model/category_repository.dart';
import 'package:book_tracker_app/features/book_details/view/book_details_screen.dart';
import 'package:book_tracker_app/features/home/cubit/shelves_cubit.dart';
import 'package:book_tracker_app/features/home/cubit/shelves_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShelvesScreen extends StatelessWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Предоставляем ShelvesCubit этому экрану и его дочерним виджетам
    return BlocProvider(
      create: (context) => ShelvesCubit(),
      child: DefaultTabController(
        length: 3, // У нас будет 3 полки
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Мои полки'),
            actions: [
              // Кнопка фильтра, иконка которой зависит от состояния
              BlocBuilder<ShelvesCubit, ShelvesState>(
                builder: (context, state) {
                  return IconButton(
                    icon: Icon(
                      state.selectedCategoryId == null
                          ? Icons.filter_list_off_outlined
                          : Icons.filter_list,
                    ),
                    onPressed: () => _showFilterDialog(context),
                    tooltip: 'Фильтр по категории',
                  );
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Хочу прочитать'),
                Tab(text: 'Читаю'),
                Tab(text: 'Прочитано'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _BookListView(shelf: 'wantToRead'),
              _BookListView(shelf: 'reading'),
              _BookListView(shelf: 'read'),
            ],
          ),
        ),
      ),
    );
  }

  /// Показывает диалог для выбора категории-фильтра
  void _showFilterDialog(BuildContext context) {
    final categoryRepo = CategoryRepository();
    // Получаем текущий Cubit из контекста, чтобы изменять его состояние
    final shelvesCubit = context.read<ShelvesCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StreamBuilder<List<Category>>(
          stream: categoryRepo.getCategories(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const AlertDialog(content: Center(child: CircularProgressIndicator()));
            }
            final categories = snapshot.data!;
            return SimpleDialog(
              title: const Text('Фильтр по категории'),
              children: [
                // Опция для сброса фильтра ("Показать все")
                SimpleDialogOption(
                  onPressed: () {
                    shelvesCubit.setCategoryFilter(null);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Показать все'),
                ),
                // Генерируем опции для каждой существующей категории
                ...categories.map((category) {
                  return SimpleDialogOption(
                    onPressed: () {
                      shelvesCubit.setCategoryFilter(category.id);
                      Navigator.pop(dialogContext);
                    },
                    child: Text(category.name),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}

// Виджет для отображения списка книг, теперь зависит от состояния ShelvesCubit
class _BookListView extends StatelessWidget {
  final String shelf;
  const _BookListView({required this.shelf});

  @override
  Widget build(BuildContext context) {
    final bookRepository = BookRepository();

    // BlocBuilder слушает изменения в ShelvesCubit и перестраивает StreamBuilder
    // с новым параметром фильтра.
    return BlocBuilder<ShelvesCubit, ShelvesState>(
      builder: (context, state) {
        return StreamBuilder<List<Book>>(
          stream: bookRepository.getBooksFromShelf(
            shelf,
            categoryId: state.selectedCategoryId, // Передаем активный фильтр
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Произошла ошибка. Вероятно, требуется создать индекс в Firestore. Проверьте консоль отладки.\n\n${snapshot.error}'),
              ));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(state.selectedCategoryId == null ? 'На этой полке пока нет книг.' : 'Нет книг в данной категории.'));
            }

            final books = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: ListTile(
                    leading: BookCoverWidget(coverUrl: book.coverUrl, title: book.title),
                    title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(book.authors.join(', ')),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookDetailsScreen(bookId: book.id)));
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showBookActionsMenu(context, book),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Метод для показа меню действий с книгой (перемещение, удаление)
  void _showBookActionsMenu(BuildContext context, Book book) {
    final bookRepository = BookRepository();

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            // Не показываем опцию для перемещения на текущую полку
            if (shelf != 'reading')
              ListTile(
                leading: const Icon(Icons.import_contacts),
                title: const Text('Переместить в "Читаю"'),
                onTap: () async {
                  await bookRepository.moveBookToShelf(book.id, 'reading');
                  Navigator.of(ctx).pop();
                },
              ),
            if (shelf != 'read')
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Переместить в "Прочитано"'),
                onTap: () async {
                  await bookRepository.moveBookToShelf(book.id, 'read');
                  Navigator.of(ctx).pop();
                },
              ),
            if (shelf != 'wantToRead')
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('Переместить в "Хочу прочитать"'),
                onTap: () async {
                  await bookRepository.moveBookToShelf(book.id, 'wantToRead');
                  Navigator.of(ctx).pop();
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Удалить книгу', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Сначала закрываем нижнее меню
                Navigator.of(ctx).pop();
                // Затем показываем диалог подтверждения
                _showConfirmDeleteDialog(context, book);
              },
            ),
          ],
        );
      },
    );
  }

  /// Метод для показа диалога подтверждения удаления
  void _showConfirmDeleteDialog(BuildContext context, Book book) {
    final bookRepository = BookRepository();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Подтверждение'),
          content: Text('Вы уверены, что хотите удалить книгу "${book.title}"? Это действие необратимо.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Закрыть диалог
              },
            ),
            TextButton(
              child: const Text('УДАЛИТЬ', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Сначала закрываем диалог, потом выполняем асинхронную операцию
                Navigator.of(dialogContext).pop();
                bookRepository.deleteBook(book.id).then((_) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Книга удалена')));
                }).catchError((error) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text('Ошибка при удалении: $error')));
                });
              },
            ),
          ],
        );
      },
    );
  }
}