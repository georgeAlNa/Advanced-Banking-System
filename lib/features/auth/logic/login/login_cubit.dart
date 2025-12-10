import 'package:flutter/material.dart';
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
  LoginCubit(this._loginRepo) : super(LoginState.initial());

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (passwordController.text.length < 8) {
      emit(LoginState.error(error: "Password Should Be at Least 8 Characters"));
      return;
    }

    emit(LoginState.loading());

    try {
      final request = LoginRequestBody(
        // email: emailController.text,
        // password: passwordController.text,
      );

      final response = await _loginRepo.login(request);

      emit(LoginState.success(response));
    } catch (e) {
      final exception = NetworkExceptions.getException(e);
      final message = NetworkExceptions.getErrorMessage(exception);
      emit(LoginState.error(error: message));
    }
  }
}
