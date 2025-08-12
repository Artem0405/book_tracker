// lib/features/book_details/view/book_details_screen.dart

import 'package:book_tracker_app/common_widgets/book_cover_widget.dart';
import 'package:book_tracker_app/data/model/book.dart';
import 'package:book_tracker_app/data/model/quote.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookId;
  const BookDetailsScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final bookRepository = BookRepository();

    return StreamBuilder<Book?>(
      stream: bookRepository.getBookDetails(bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text('Ошибка: ${snapshot.error}')));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Книга не найдена.')));
        }

        final book = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(book.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Секция с информацией о книге
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCoverWidget(
                      coverUrl: book.coverUrl,
                      title: book.title,
                      height: 150,
                      width: 100,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(book.authors.join(', '), style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 8),
                          if (book.pageCount != null) Text('${book.pageCount} страниц'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),

                // Секция с цитатами
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Цитаты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () => _showAddQuoteDialog(context, bookId),
                      tooltip: 'Добавить цитату',
                    ),
                  ],
                ),

                // Список цитат
                StreamBuilder<List<Quote>>(
                  stream: bookRepository.getQuotesForBook(bookId),
                  builder: (context, quoteSnapshot) {
                    if (quoteSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (!quoteSnapshot.hasData || quoteSnapshot.data!.isEmpty) {
                      return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Text('Добавьте свою первую цитату!'),
                          )
                      );
                    }
                    final quotes = quoteSnapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true, // Важно для вложенных списков
                      physics: const NeverScrollableScrollPhysics(), // Отключаем скролл
                      itemCount: quotes.length,
                      itemBuilder: (context, index) {
                        final quote = quotes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('"${quote.text}"', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                                if (quote.pageNumber != null) ...[
                                  const SizedBox(height: 8),
                                  Text('— стр. ${quote.pageNumber}', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade600)),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Диалог для добавления цитаты
  void _showAddQuoteDialog(BuildContext context, String bookId) {
    final bookRepository = BookRepository();
    final textController = TextEditingController();
    final pageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить цитату'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: 'Текст цитаты'),
                autofocus: true,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pageController,
                decoration: const InputDecoration(labelText: 'Номер страницы (необязательно)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Разрешаем ввод только цифр
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  final page = int.tryParse(pageController.text);
                  bookRepository.addQuoteForBook(bookId, text, pageNumber: page);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }
}