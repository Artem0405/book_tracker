// lib/main.dart

import 'package:book_tracker_app/app/bloc/auth_bloc.dart';
import 'package:book_tracker_app/features/auth/view/login_screen.dart';
import 'package:book_tracker_app/features/home/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

void main() async {
  // Убеждаемся, что Flutter инициализирован перед асинхронными операциями
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Создаем экземпляры наших ключевых сервисов и BLoC'ов
  final firebaseAuth = FirebaseAuth.instance;
  final authBloc = AuthBloc(firebaseAuth: firebaseAuth);

  runApp(
    // RepositoryProvider делает один экземпляр объекта (в нашем случае FirebaseAuth)
    // доступным для всех своих дочерних виджетов. Это полезно для сервисов,
    // которые не имеют состояния, например, для работы с API.
    RepositoryProvider.value(
      value: firebaseAuth,
      child: MyApp(authBloc: authBloc),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    // BlocProvider делает один экземпляр BLoC/Cubit доступным для всех
    // дочерних виджетов. Мы используем .value, потому что создали BLoC
    // выше, в функции main.
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp(
        title: 'ArtTech Book Tracker',
        theme: ThemeData(
          // Выбираем приятную цветовую схему
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            // Стили для кнопок, чтобы они выглядели одинаково во всем приложении
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )
            )
        ),
        debugShowCheckedModeBanner: false, // Убираем дебаг-ленту
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // В зависимости от состояния аутентификации показываем нужный экран
            switch (state.status) {
              case AuthStatus.authenticated:
                return const HomeScreen(); // Пользователь вошел
              case AuthStatus.unauthenticated:
                return const LoginScreen(); // Пользователь не вошел
              case AuthStatus.unknown:
              // Пока статус неизвестен (приложение только что запустилось),
              // показываем индикатор загрузки.
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
            }
          },
        ),
      ),
    );
  }
}