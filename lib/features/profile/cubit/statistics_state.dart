// lib/features/profile/cubit/statistics_state.dart
import 'package:equatable/equatable.dart';

enum StatisticsStatus { initial, loading, success, failure }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final int totalBooksRead;
  final int totalPagesRead;
  final Map<int, int> booksPerMonth; // {1: 5, 2: 3, ...} -> {Январь: 5 книг, Февраль: 3 книги, ...}

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.totalBooksRead = 0,
    this.totalPagesRead = 0,
    this.booksPerMonth = const {},
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    int? totalBooksRead,
    int? totalPagesRead,
    Map<int, int>? booksPerMonth,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
      totalPagesRead: totalPagesRead ?? this.totalPagesRead,
      booksPerMonth: booksPerMonth ?? this.booksPerMonth,
    );
  }

  @override
  List<Object> get props => [status, totalBooksRead, totalPagesRead, booksPerMonth];
}