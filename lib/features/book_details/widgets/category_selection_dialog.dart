// lib/features/book_details/widgets/category_selection_dialog.dart
import 'package:book_tracker_app/data/model/category.dart';
import 'package:book_tracker_app/data/model/category_repository.dart';
import 'package:flutter/material.dart';

class CategorySelectionDialog extends StatefulWidget {
  final List<String> initialSelectedIds;
  const CategorySelectionDialog({super.key, required this.initialSelectedIds});

  @override
  State<CategorySelectionDialog> createState() => _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  final _categoryRepository = CategoryRepository();
  final _newCategoryController = TextEditingController();
  late Set<String> _selectedIds;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // При инициализации копируем начальные выбранные ID в локальное состояние
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _addNewCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    setState(() { _isCreating = true; });
    try {
      await _categoryRepository.createCategory(name);
      _newCategoryController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() { _isCreating = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите категории'),
      // Уменьшаем стандартные отступы, чтобы контент занимал больше места
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      content: SizedBox(
        width: double.maxFinite, // Занять всю доступную ширину
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Поле для добавления новой категории
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    decoration: const InputDecoration(
                      labelText: 'Новая категория',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isCreating ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add),
                  onPressed: _isCreating ? null : _addNewCategory,
                ),
              ],
            ),
            const Divider(height: 20),
            // Список существующих категорий
            Expanded(
              child: StreamBuilder<List<Category>>(
                stream: _categoryRepository.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final categories = snapshot.data!;
                  if (categories.isEmpty) return const Center(child: Text('Создайте свою первую категорию'));

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CheckboxListTile(
                        title: Text(category.name),
                        value: _selectedIds.contains(category.id),
                        onChanged: (isSelected) {
                          setState(() {
                            if (isSelected == true) {
                              _selectedIds.add(category.id);
                            } else {
                              _selectedIds.remove(category.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(), // Возвращаем null (отмена)
            child: const Text('Отмена')),
        ElevatedButton(
          onPressed: () {
            // Возвращаем итоговый список выбранных ID
            Navigator.of(context).pop(_selectedIds.toList());
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}