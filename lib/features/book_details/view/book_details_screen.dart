// lib/features/book_details/view/book_details_screen.dart

import 'package:book_tracker_app/common_widgets/book_cover_widget.dart';
import 'package:book_tracker_app/data/model/book.dart';
import 'package:book_tracker_app/data/model/category.dart';
import 'package:book_tracker_app/data/model/quote.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/data/model/category_repository.dart';
import 'package:book_tracker_app/features/book_details/widgets/category_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
                    Hero(
                      tag: 'book_cover_${book.id}',
                      child: BookCoverWidget(
                        coverUrl: book.coverUrl,
                        title: book.title,
                        height: 150,
                        width: 100,
                      ),
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

                // Секция оценки
                if (book.shelf == 'read') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Ваша оценка', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: RatingBar.builder(
                      initialRating: book.rating,
                      minRating: 0.5,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        bookRepository.updateBookRating(book.id, rating);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Секция прогресса чтения
                if (book.pageCount != null && book.pageCount! > 0) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Прогресс чтения', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _BookProgress(book: book),
                  const SizedBox(height: 16),
                ],

                // Секция с категориями
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Категории', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final List<String>? selectedIds = await showDialog<List<String>>(
                          context: context,
                          builder: (_) => CategorySelectionDialog(initialSelectedIds: book.categoryIds),
                        );
                        if (selectedIds != null) {
                          await bookRepository.updateBookCategories(book.id, selectedIds);
                        }
                      },
                      tooltip: 'Изменить категории',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BookCategories(categoryIds: book.categoryIds),
                const SizedBox(height: 16),
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
                      return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                    }
                    if (!quoteSnapshot.hasData || quoteSnapshot.data!.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Text('Добавьте свою первую цитату!')));
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            title: Text('"${quote.text}"', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                            subtitle: quote.pageNumber != null
                                ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('— стр. ${quote.pageNumber}', style: TextStyle(color: Colors.grey.shade600)),
                              ),
                            )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showQuoteActions(context, bookId, quote),
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

  /// Диалог для добавления или редактирования цитаты
  void _showAddQuoteDialog(BuildContext context, String bookId, {Quote? quoteToEdit}) {
    final bookRepository = BookRepository();
    final textController = TextEditingController(text: quoteToEdit?.text);
    final pageController = TextEditingController(text: quoteToEdit?.pageNumber?.toString() ?? '');
    final isEditing = quoteToEdit != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Редактировать цитату' : 'Добавить цитату'),
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  final page = int.tryParse(pageController.text);
                  if (isEditing) {
                    bookRepository.updateQuote(bookId, quoteToEdit.id, text, newPageNumber: page);
                  } else {
                    bookRepository.addQuoteForBook(bookId, text, pageNumber: page);
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(isEditing ? 'Сохранить' : 'Добавить'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает меню действий для конкретной цитаты
  void _showQuoteActions(BuildContext context, String bookId, Quote quote) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showAddQuoteDialog(context, bookId, quoteToEdit: quote);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _showConfirmDeleteQuoteDialog(context, bookId, quote.id);
              },
            ),
          ],
        );
      },
    );
  }

  /// Диалог подтверждения удаления цитаты
  void _showConfirmDeleteQuoteDialog(BuildContext context, String bookId, String quoteId) {
    final bookRepository = BookRepository();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить цитату?'),
          content: const Text('Это действие нельзя будет отменить.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                bookRepository.deleteQuote(bookId, quoteId);
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class _BookProgress extends StatelessWidget {
  final Book book;
  const _BookProgress({required this.book});

  @override
  Widget build(BuildContext context) {
    // Убеждаемся, что pageCount не null и не 0, чтобы избежать деления на ноль
    final pageCount = book.pageCount ?? 1;
    final currentPage = book.currentPage;
    final progress = (currentPage / pageCount).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Прочитано $currentPage из $pageCount страниц (${(progress * 100).toStringAsFixed(0)}%)',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () => _showUpdateProgressDialog(context, book),
            child: const Text('Обновить прогресс'),
          ),
        ),
      ],
    );
  }

  /// Диалог для обновления прогресса
  void _showUpdateProgressDialog(BuildContext context, Book book) {
    final pageController = TextEditingController(text: book.currentPage.toString());
    final bookRepository = BookRepository();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Обновить прогресс'),
          content: TextField(
            controller: pageController,
            decoration: InputDecoration(labelText: 'Прочитано страниц (из ${book.pageCount})'),
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPage = int.tryParse(pageController.text);
                if (newPage != null && newPage >= 0 && newPage <= (book.pageCount ?? 0)) {
                  bookRepository.updateBookProgress(book.id, newPage);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('Введите число от 0 до ${book.pageCount}!'),
                      backgroundColor: Colors.red,
                    ));
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}

class _BookCategories extends StatelessWidget {
  final List<String> categoryIds;
  const _BookCategories({required this.categoryIds});

  @override
  Widget build(BuildContext context) {
    if (categoryIds.isEmpty) {
      return const Text(
        'Категории не выбраны. Нажмите "Изменить", чтобы добавить.',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    // Используем FutureBuilder, так как нам нужно один раз загрузить имена категорий по их ID.
    return FutureBuilder<List<Category>>(
      future: CategoryRepository().getCategoriesByIds(categoryIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          // Это может произойти, если категории были удалены, а у книги остались старые ID
          return const Text('Не удалось загрузить категории.', style: TextStyle(color: Colors.red));
        }
        final categories = snapshot.data!;

        // Wrap автоматически переносит виджеты на новую строку, если они не помещаются
        return Wrap(
          spacing: 8.0, // Горизонтальный отступ между чипами
          runSpacing: 4.0, // Вертикальный отступ между рядами чипов
          children: categories.map((category) {
            return Chip(
              label: Text(category.name),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
            );
          }).toList(),
        );
      },
    );
  }
}