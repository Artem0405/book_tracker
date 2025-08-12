// lib/features/profile/view/profile_screen.dart

import 'package:book_tracker_app/app/bloc/auth_bloc.dart';
import 'package:book_tracker_app/data/repository/book_repository.dart';
import 'package:book_tracker_app/features/profile/cubit/statistics_cubit.dart';
import 'package:book_tracker_app/features/profile/cubit/statistics_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Без имени',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? 'Email не указан',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(),

          // Секция со статистикой
          BlocProvider(
            create: (context) => StatisticsCubit(
              // Cubit получает BookRepository из вышестоящего RepositoryProvider
              context.read<BookRepository>(),
            )..loadStatistics(), // ..loadStatistics() сразу запускает загрузку данных
            child: const _StatisticsSection(),
          ),

          const Divider(),
          const SizedBox(height: 20),

          // Кнопка выхода
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
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

// Виджет для секции статистики
class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        if (state.status == StatisticsStatus.loading || state.status == StatisticsStatus.initial) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
        }
        if (state.status == StatisticsStatus.failure) {
          return const Center(child: Text('Не удалось загрузить статистику'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Статистика чтения', style: Theme.of(context).textTheme.titleLarge),
            ),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Книг прочитано', value: state.totalBooksRead.toString())),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(title: 'Страниц прочитано', value: state.totalPagesRead.toString())),
              ],
            ),
            const SizedBox(height: 24),
            Text('Книг прочитано в этом году', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                _createChartData(state.booksPerMonth, context),
              ),
            ),
          ],
        );
      },
    );
  }

  // Метод для создания данных и стилей для графика
  BarChartData _createChartData(Map<int, int> booksPerMonth, BuildContext context) {
    const List<String> months = ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'];
    final double maxY = (booksPerMonth.values.isEmpty ? 2 : booksPerMonth.values.reduce((a, b) => a > b ? a : b) + 2).toDouble();

    return BarChartData(
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              final style = TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              );
              return SideTitleWidget(
                meta: meta, // <<< ПЕРЕДАЕМ ВЕСЬ ОБЪЕКТ META
                child: Text(months[value.toInt() - 1], style: style),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(12, (index) {
        final month = index + 1;
        return BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: (booksPerMonth[month] ?? 0).toDouble(),
              color: Theme.of(context).primaryColor,
              width: 16,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        );
      }),
    );
  }
}

// Виджет для карточки со статистикой
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}