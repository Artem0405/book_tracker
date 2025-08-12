// lib/features/home/view/shelves_screen.dart
import 'package:book_tracker_app/data/model/book.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShelvesScreen extends StatelessWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Мы могли бы создать Cubit, но для простой демонстрации
    // можно использовать репозиторий напрямую.
    final bookRepository = BookRepository();
    final user = context.read<FirebaseAuth>().currentUser;
    final String welcomeName = user?.displayName ?? (user?.email?.split('@').first ?? 'Пользователь');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои полки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Привет, $welcomeName!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // TODO: Добавить переключатель полок (Tabs: Хочу прочитать, Читаю, Прочитано)
            const Text(
              'Хочу прочитать', // Пока заголовок одной полки
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Используем StreamBuilder для отображения книг в реальном времени
            Expanded(
              child: StreamBuilder<List<Book>>(
                stream: bookRepository.getBooksFromShelf('wantToRead'),
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

                  // Отображаем книги в виде списка
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: book.coverUrl != null
                              ? Image.network(book.coverUrl!, width: 50, fit: BoxFit.cover)
                              : const Icon(Icons.book_online, size: 50),
                          title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(book.authors.join(', ')),
                          onTap: () {
                            // TODO: Переход на экран деталей книги
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}