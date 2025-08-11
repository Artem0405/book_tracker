// lib/features/auth/cubit/login_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:book_tracker_app/features/auth/cubit/login_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formz/formz.dart';

class LoginCubit extends Cubit<LoginState> {
  final FirebaseAuth _firebaseAuth;

  LoginCubit(this._firebaseAuth) : super(const LoginState());

  Future<void> logInWithCredentials(String email, String password) async {
    // Если уже в процессе - ничего не делаем
    if (state.status.isInProgress) return;

    // Сообщаем UI, что начался процесс входа
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Вызываем метод Firebase
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Если все успешно - сообщаем UI
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on FirebaseAuthException catch (e) {
      // Если Firebase вернул ошибку, обрабатываем ее
      String message;
      if (e.code == 'user-not-found') {
        message = 'Пользователь с таким email не найден.';
      } else if (e.code == 'wrong-password') {
        message = 'Неверный пароль.';
      } else {
        message = 'Произошла ошибка. Попробуйте снова.';
      }
      // Сообщаем UI об ошибке
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: message,
      ));
    } catch (_) {
      // Ловим любые другие ошибки
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Произошла непредвиденная ошибка.',
      ));
    }
  }
}