// lib/features/search/cubit/search_state.dart
import 'package:book_tracker_app/data/model/book.dart';
import 'package:equatable/equatable.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<Book> books;
  final String errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.books = const [],
    this.errorMessage = '',
  });

  SearchState copyWith({
    SearchStatus? status,
    List<Book>? books,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      books: books ?? this.books,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, books, errorMessage];
}