// lib/features/profile/view/profile_screen.dart

import 'package:book_tracker_app/app/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем текущего пользователя. Это безопасно, так как этот экран
    // доступен только аутентифицированным пользователям.
    final user = context.read<FirebaseAuth>().currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Секция с информацией о пользователе
          Row(
            children: [
              // Аватар
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                // Если у пользователя есть фото профиля, показываем его
                backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                // Если фото нет, показываем иконку
                child: user.photoURL == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              // Имя и Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Без имени',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? 'Email не указан',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(),

          // Секция со статистикой (пока заглушка)
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Статистика'),
            subtitle: const Text('Прочитанные книги, страницы и т.д.'),
            onTap: () {
              // TODO: Навигация на экран статистики
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('Достижения'),
            subtitle: const Text('Ваши "ачивки" за чтение'),
            onTap: () {
              // TODO: Навигация на экран достижений
            },
          ),
          const Divider(),
          const SizedBox(height: 20),

          // Кнопка выхода
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Отправляем событие выхода в наш главный AuthBloc
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Выйти', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}