// lib/common_widgets/book_cover_widget.dart
import 'package:flutter/material.dart';

class BookCoverWidget extends StatelessWidget {
  final String? coverUrl;
  final String title;
  final double? width;
  final double? height;

  const BookCoverWidget({
    super.key,
    required this.coverUrl,
    required this.title,
    this.width = 50,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Если есть URL обложки, показываем Image.network
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return Image.network(
        coverUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        // Добавляем обработку ошибок загрузки
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        // Показываем индикатор во время загрузки
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    // Если URL нет, показываем заглушку
    return _buildPlaceholder();
  }

  // Метод для создания виджета-заглушки
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          // Берем первую букву названия, если оно есть
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: (width ?? 50) / 2, // Размер шрифта зависит от размера виджета
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}