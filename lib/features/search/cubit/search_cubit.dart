// lib/features/search/cubit/search_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:book_tracker_app/data/api/google_books_api_service.dart';
import 'package:book_tracker_app/features/search/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final GoogleBooksApiService _apiService;

  SearchCubit(this._apiService) : super(const SearchState());

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(status: SearchStatus.initial, books: []));
      return;
    }
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final books = await _apiService.searchBooks(query);
      emit(state.copyWith(status: SearchStatus.success, books: books));
    } catch (e) {
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
    }
  }
}