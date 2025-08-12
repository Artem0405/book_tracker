// lib/features/book_details/view/book_details_screen.dart
import 'package:book_tracker_app/data/model/book.dart';
import 'package:book_tracker_app/data/model/quote.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:flutter/material.dart';

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
                    if (book.coverUrl != null)
                      Image.network(book.coverUrl!, height: 150, width: 100, fit: BoxFit.cover),
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
                    ),
                  ],
                ),

                // Список цитат
                StreamBuilder<List<Quote>>(
                  stream: bookRepository.getQuotesForBook(bookId),
                  builder: (context, quoteSnapshot) {
                    if (quoteSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!quoteSnapshot.hasData || quoteSnapshot.data!.isEmpty) {
                      return const Center(child: Text('Добавьте свою первую цитату!'));
                    }
                    final quotes = quoteSnapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: quotes.length,
                      itemBuilder: (context, index) {
                        final quote = quotes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: 4,
              ),
              TextField(
                controller: pageController,
                decoration: const InputDecoration(labelText: 'Номер страницы (необязательно)'),
                keyboardType: TextInputType.number,
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
                final text = textController.text;
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