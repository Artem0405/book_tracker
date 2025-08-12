// lib/features/home/cubit/shelves_state.dart
import 'package:equatable/equatable.dart';

class ShelvesState extends Equatable {
  // ID категории, которая выбрана для фильтрации. null - значит "показать все".
  final String? selectedCategoryId;

  const ShelvesState({
    this.selectedCategoryId,
  });

  ShelvesState copyWith({
    // Используем обертку, чтобы можно было передать null
    dynamic selectedCategoryId,
  }) {
    return ShelvesState(
      selectedCategoryId: selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [selectedCategoryId];
}