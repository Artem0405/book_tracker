// lib/features/auth/view/register_screen.dart

import 'package:book_tracker_app/features/auth/cubit/register_cubit.dart';
import 'package:book_tracker_app/features/auth/cubit/register_state.dart';
import 'package:book_tracker_app/features/auth/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

// Виджет-провайдер для Cubit
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(context.read<FirebaseAuth>()),
      child: const RegisterView(),
    );
  }
}

// Виджет для отображения UI
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    // Проверяем, не идет ли уже процесс
    if (context.read<RegisterCubit>().state.status.isInProgress) return;

    // Простая проверка на совпадение паролей
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Пароли не совпадают'),
            backgroundColor: Colors.orange,
          ),
        );
      return;
    }

    // Вызываем метод Cubit'а
    context.read<RegisterCubit>().signUpWithCredentials(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Ошибка регистрации'),
                backgroundColor: Colors.red,
              ),
            );
        }
        // <<< ИЗМЕНЕНИЕ ЗДЕСЬ >>>
        // Если регистрация прошла успешно...
        if (state.status.isSuccess) {
          // ...закрываем экран регистрации.
          // Пользователь увидит HomeScreen, который уже был загружен "под ним"
          // благодаря нашему главному AuthBloc.
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Создание аккаунта'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Присоединяйтесь к нам!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

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
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Повторите пароль',
                  isPassword: true,
                  icon: Icons.lock_person_outlined,
                ),
                const SizedBox(height: 20),

                // Кнопка регистрации
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: BlocBuilder<RegisterCubit, RegisterState>(
                        builder: (context, state) {
                          return state.status.isInProgress
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                              : const Text(
                            'Зарегистрироваться',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}