// lib/features/home/view/shelves_screen.dart

import 'package:book_tracker_app/common_widgets/book_cover_widget.dart';
import 'package:book_tracker_app/data/model/book.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/features/book_details/view/book_details_screen.dart';
import 'package:flutter/material.dart';

class ShelvesScreen extends StatelessWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем TabController для управления вкладками
    return DefaultTabController(
      length: 3, // У нас будет 3 полки
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мои полки'),
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
            // Передаем каждой вкладке виджет с нужным типом полки
            _BookListView(shelf: 'wantToRead'),
            _BookListView(shelf: 'reading'),
            _BookListView(shelf: 'read'),
          ],
        ),
      ),
    );
  }
}

// Переиспользуемый виджет для отображения списка книг с одной полки
class _BookListView extends StatelessWidget {
  final String shelf;
  const _BookListView({required this.shelf});

  @override
  Widget build(BuildContext context) {
    final bookRepository = BookRepository();

    return StreamBuilder<List<Book>>(
      stream: bookRepository.getBooksFromShelf(shelf),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Произошла ошибка: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('На этой полке пока нет книг.'));
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
                leading: BookCoverWidget(
                  coverUrl: book.coverUrl,
                  title: book.title,
                ),
                title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(book.authors.join(', ')),
                onTap: () {
                  // Переход на экран деталей книги
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookDetailsScreen(bookId: book.id),
                    ),
                  );
                },
                // Добавляем меню для перемещения и удаления книги
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
  }

  // Метод для показа меню действий с книгой
  void _showBookActionsMenu(BuildContext context, Book book) {
    final bookRepository = BookRepository();

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            // Не показываем кнопку для текущей полки
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
                Navigator.of(ctx).pop();
                _showConfirmDeleteDialog(context, book);
              },
            ),
          ],
        );
      },
    );
  }

  // Метод для показа диалога подтверждения удаления
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
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('УДАЛИТЬ', style: TextStyle(color: Colors.red)),
              onPressed: () {
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