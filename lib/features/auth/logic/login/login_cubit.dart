import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../../data/models/login/login_request_body.dart';
import '../../data/models/login/login_response.dart';
import '../../data/repos/login_repo.dart';

part 'login_state.dart';
part 'login_cubit.freezed.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  LoginCubit(this._loginRepo) : super(const LoginState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state is _Loading) return;

    emit(const LoginState.loading());
    try {
      final request = LoginRequestBody(
        email: email,
        password: password,
      );

      final response = await _loginRepo.login(request);
      emit(LoginState.success(response));
    } catch (e) {
      final exception = NetworkExceptions.getException(e);
      final message = NetworkExceptions.getErrorMessage(exception);
      emit(LoginState.error(message));
    }
  }
}
