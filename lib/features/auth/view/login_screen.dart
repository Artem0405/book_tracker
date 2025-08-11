// lib/features/auth/view/login_screen.dart

import 'package:book_tracker_app/features/auth/cubit/login_cubit.dart';
import 'package:book_tracker_app/features/auth/cubit/login_state.dart';
import 'package:book_tracker_app/features/auth/view/register_screen.dart';
import 'package:book_tracker_app/features/auth/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

// Этот виджет отвечает за предоставление Cubit'а дереву виджетов.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(context.read<FirebaseAuth>()),
      child: const LoginView(),
    );
  }
}

// Этот виджет отвечает за отображение UI.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      // BlocListener идеально подходит для действий, которые должны произойти один раз:
      // навигация, показ SnackBar, диалоговых окон и т.д.
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Ошибка входа'),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Иконка и приветствие
                  const Icon(Icons.menu_book, size: 100, color: Colors.deepPurple),
                  const SizedBox(height: 20),
                  const Text(
                    'Добро пожаловать!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Войдите, чтобы продолжить',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Поля ввода
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Пароль',
                    isPassword: true,
                    icon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 20),

                  // Кнопка входа
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Проверяем, не идет ли уже процесс входа
                          if (context.read<LoginCubit>().state.status.isInProgress) return;

                          context.read<LoginCubit>().logInWithCredentials(
                            _emailController.text.trim(), // Используем trim для удаления пробелов
                            _passwordController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // BlocBuilder перерисовывает только кнопку, а не весь экран.
                        child: BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            return state.status.isInProgress
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                                : const Text(
                              'Войти',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ссылка на регистрацию
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Еще нет аккаунта? Зарегистрироваться'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}