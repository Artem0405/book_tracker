// lib/features/auth/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final IconData? icon;
  final TextInputType? keyboardType; // Параметр для типа клавиатуры

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.icon,
    this.keyboardType, // Добавлен в конструктор
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Локальное состояние для отслеживания видимости пароля
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Инициализируем состояние на основе пропса isPassword
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText, // Используем локальное состояние
        keyboardType: widget.keyboardType, // Используем переданный тип клавиатуры
        decoration: InputDecoration(
          labelText: widget.labelText,
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          // Добавляем иконку-переключатель только если это поле для пароля
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              // Меняем иконку в зависимости от состояния
              _obscureText ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              // При нажатии меняем состояние на противоположное
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null, // Если не пароль, иконки нет
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}