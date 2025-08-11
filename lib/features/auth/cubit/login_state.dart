// lib/features/auth/cubit/login_state.dart
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class LoginState extends Equatable {
  final FormzSubmissionStatus status;
  final String? errorMessage;

  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}