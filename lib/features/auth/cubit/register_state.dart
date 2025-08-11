// lib/features/auth/cubit/register_state.dart
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class RegisterState extends Equatable {
  final FormzSubmissionStatus status;
  final String? errorMessage;

  const RegisterState({
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  RegisterState copyWith({
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}