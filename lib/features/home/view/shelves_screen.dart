// lib/features/home/view/shelves_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShelvesScreen extends StatelessWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем текущего пользователя из FirebaseAuth, используя RepositoryProvider,
    // который мы настроили в main.dart
    final user = context.read<FirebaseAuth>().currentUser;

    // Формируем приветственное имя. Используем displayName, если оно есть,
    // иначе - часть email до символа @.
    final String welcomeName = user?.displayName ??
        (user?.email?.split('@').first ?? 'Пользователь');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои полки'),
        // Можно добавить какие-то действия, например, кнопку для смены вида (список/сетка)
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              // TODO: Реализовать смену вида
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветственный заголовок
            Text(
              'Привет, $welcomeName!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Здесь будет логика отображения полок и книг
            // Пока что поставим заглушку
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shelves,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ваши книжные полки пока пусты.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Найдите и добавьте свою первую книгу!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}