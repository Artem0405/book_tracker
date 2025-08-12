// lib/features/home/cubit/shelves_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:book_tracker_app/features/home/cubit/shelves_state.dart';

class ShelvesCubit extends Cubit<ShelvesState> {
  ShelvesCubit() : super(const ShelvesState());

  /// Устанавливает новую категорию для фильтра или сбрасывает его.
  void setCategoryFilter(String? categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }
}