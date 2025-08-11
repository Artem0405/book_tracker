// lib/app/bloc/auth_state.dart
part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
  });

  // Состояние, когда мы еще не знаем, вошел ли пользователь
  const AuthState.unknown() : this._();

  // Состояние, когда пользователь успешно аутентифицирован
  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  // Состояние, когда пользователь не аутентифицирован
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}