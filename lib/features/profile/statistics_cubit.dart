// lib/features/profile/cubit/statistics_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/features/profile/cubit/statistics_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final BookRepository _bookRepository;

  StatisticsCubit(this._bookRepository) : super(const StatisticsState());

  Future<void> loadStatistics() async {
    emit(state.copyWith(status: StatisticsStatus.loading));

    try {
      // 1. Получаем все прочитанные книги
      final books = await _bookRepository.getFinishedBooks();

      // 2. Считаем простые метрики
      final totalBooks = books.length;
      final totalPages = books.fold<int>(0, (sum, book) => sum + (book.pageCount ?? 0));

      // 3. Считаем книги по месяцам за текущий год
      final booksPerMonth = <int, int>{};
      final currentYear = DateTime.now().year;

      // Инициализируем карту нулями для всех 12 месяцев
      for (int i = 1; i <= 12; i++) {
        booksPerMonth[i] = 0;
      }

      // Получаем документы с полями finishedAt
      final finishedBooksDocs = await FirebaseFirestore.instance
          .collection('user_books')
          .where('userId', isEqualTo: _bookRepository.getUserId)
          .where('shelf', isEqualTo: 'read')
          .get();

      for (var doc in finishedBooksDocs.docs) {
        final data = doc.data();
        if (data.containsKey('finishedAt') && data['finishedAt'] is Timestamp) {
          final finishedDate = (data['finishedAt'] as Timestamp).toDate();
          if (finishedDate.year == currentYear) {
            booksPerMonth[finishedDate.month] = (booksPerMonth[finishedDate.month] ?? 0) + 1;
          }
        }
      }

      // 4. Отправляем успешное состояние в UI
      emit(state.copyWith(
        status: StatisticsStatus.success,
        totalBooksRead: totalBooks,
        totalPagesRead: totalPages,
        booksPerMonth: booksPerMonth,
      ));
    } catch (_) {
      emit(state.copyWith(status: StatisticsStatus.failure));
    }
  }
}