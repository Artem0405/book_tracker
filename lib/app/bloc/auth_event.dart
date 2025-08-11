// lib/app/bloc/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Событие, которое мы отправим при запуске приложения, чтобы проверить статус
class AuthStateChanged extends AuthEvent {
  final User? user;

  const AuthStateChanged(this.user);

  @override
  List<Object> get props => [user ?? Object()];
}

// Событие для выхода из системы
class AuthLogoutRequested extends AuthEvent {}