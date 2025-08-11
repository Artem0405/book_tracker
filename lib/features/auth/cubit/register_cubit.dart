// lib/features/auth/cubit/register_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:book_tracker_app/features/auth/cubit/register_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formz/formz.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final FirebaseAuth _firebaseAuth;

  RegisterCubit(this._firebaseAuth) : super(const RegisterState());

  Future<void> signUpWithCredentials({
    required String email,
    required String password,
  }) async {
    if (state.status.isInProgress) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Создаем пользователя в Firebase Authentication
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Если успешно, сообщаем UI
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on FirebaseAuthException catch (e) {
      // Обрабатываем специфичные ошибки Firebase
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Пароль слишком слабый.';
          break;
        case 'email-already-in-use':
          message = 'Этот email уже используется.';
          break;
        case 'invalid-email':
          message = 'Некорректный формат email.';
          break;
        default:
          message = 'Произошла ошибка регистрации.';
      }
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Произошла непредвиденная ошибка.',
      ));
    }
  }
}