// lib/app/bloc/auth_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth,
        super(const AuthState.unknown()) {
    // Подписываемся на поток изменений состояния аутентификации от Firebase
    _userSubscription = _firebaseAuth.authStateChanges().listen(
          (user) => add(AuthStateChanged(user)),
    );

    on<AuthStateChanged>(_onAuthStateChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      // Если пользователь есть - он аутентифицирован
      emit(AuthState.authenticated(event.user!));
    } else {
      // Если пользователя нет - он не аутентифицирован
      emit(const AuthState.unauthenticated());
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    // Просто вызываем метод выхода из Firebase Auth
    _firebaseAuth.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}