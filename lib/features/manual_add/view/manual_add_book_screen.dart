// lib/features/manual_add/view/manual_add_book_screen.dart
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/features/auth/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class ManualAddBookScreen extends StatefulWidget {
  const ManualAddBookScreen({super.key});

  @override
  State<ManualAddBookScreen> createState() => _ManualAddBookScreenState();
}

class _ManualAddBookScreenState extends State<ManualAddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _bookRepository = BookRepository();

  bool _isLoading = false;
  String _selectedShelf = 'wantToRead'; // Полка по умолчанию

  Future<void> _saveBook() async {
    if (_titleController.text.trim().isEmpty || _authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Название и автор обязательны!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Вызываем упрощенный метод, без imageFile
      await _bookRepository.addManualBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        pageCount: int.tryParse(_pageCountController.text),
        shelf: _selectedShelf,
      );

      // Закрываем экран после успешного добавления
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Книга успешно добавлена!')),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить книгу вручную')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Поля ввода
            CustomTextField(controller: _titleController, labelText: 'Название*'),
            CustomTextField(controller: _authorController, labelText: 'Автор*'),
            CustomTextField(
              controller: _pageCountController,
              labelText: 'Количество страниц',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Выбор полки
            DropdownButtonFormField<String>(
              value: _selectedShelf,
              onChanged: (value) {
                if (value != null) {
                  setState(() { _selectedShelf = value; });
                }
              },
              items: const [
                DropdownMenuItem(value: 'wantToRead', child: Text('Хочу прочитать')),
                DropdownMenuItem(value: 'reading', child: Text('Читаю')),
                DropdownMenuItem(value: 'read', child: Text('Прочитано')),
              ],
              decoration: const InputDecoration(labelText: 'Выберите полку'),
            ),
            const SizedBox(height: 30),

            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveBook,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}