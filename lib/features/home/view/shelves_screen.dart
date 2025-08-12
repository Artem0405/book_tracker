// lib/features/home/view/shelves_screen.dart

import 'package:book_tracker_app/data/model/book.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/features/book_details/view/book_details_screen.dart';
import 'package:flutter/material.dart';

class ShelvesScreen extends StatelessWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем TabController для управления вкладками.
    // Оборачиваем Scaffold в DefaultTabController.
    return DefaultTabController(
      length: 3, // У нас будет 3 полки
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мои полки'),
          // 'bottom' AppBar - идеальное место для TabBar.
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Хочу прочитать'),
              Tab(text: 'Читаю'),
              Tab(text: 'Прочитано'),
            ],
          ),
        ),
        // TabBarView отображает контент для каждой вкладки.
        // Порядок дочерних элементов должен соответствовать порядку вкладок в TabBar.
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

// Переиспользуемый виджет для отображения списка книг с одной полки.
// Мы вынесли его в отдельный виджет, чтобы не дублировать код.
class _BookListView extends StatelessWidget {
  final String shelf;
  const _BookListView({required this.shelf});

  @override
  Widget build(BuildContext context) {
    // Создаем экземпляр репозитория для доступа к данным.
    final bookRepository = BookRepository();

    return StreamBuilder<List<Book>>(
      // Подписываемся на поток книг с конкретной полки.
      stream: bookRepository.getBooksFromShelf(shelf),
      builder: (context, snapshot) {
        // Пока данные загружаются, показываем индикатор.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Если произошла ошибка, показываем ее.
        if (snapshot.hasError) {
          return Center(child: Text('Произошла ошибка: ${snapshot.error}'));
        }
        // Если данных нет или список пуст, показываем заглушку.
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'На этой полке пока нет книг.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final books = snapshot.data!;

        // Если данные есть, строим список.
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: ListTile(
                leading: book.coverUrl != null
                    ? Image.network(book.coverUrl!, width: 50, fit: BoxFit.cover)
                    : const Icon(Icons.book_online, size: 50),
                title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(book.authors.join(', ')),
                onTap: () {
                  // Навигация на экран деталей книги с передачей ID книги.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookDetailsScreen(bookId: book.id),
                    ),
                  );
                },
                // Кнопка с тремя точками для вызова меню действий.
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showMoveBookMenu(context, book),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Метод для показа меню действий с книгой (нижнее всплывающее окно).
  void _showMoveBookMenu(BuildContext context, Book book) {
    final bookRepository = BookRepository();

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        // Wrap позволяет виджетам переноситься, если они не помещаются.
        return Wrap(
          children: <Widget>[
            // Динамически показываем опции, кроме той, где книга уже находится.
            if (shelf != 'reading')
              ListTile(
                leading: const Icon(Icons.import_contacts),
                title: const Text('Переместить в "Читаю"'),
                onTap: () async {
                  await bookRepository.moveBookToShelf(book.id, 'reading');
                  Navigator.of(ctx).pop(); // Закрываем bottom sheet
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
            // TODO: Можно добавить опцию "Удалить книгу"
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Отмена'),
              onTap: () => Navigator.of(ctx).pop(),
            )
          ],
        );
      },
    );
  }
}