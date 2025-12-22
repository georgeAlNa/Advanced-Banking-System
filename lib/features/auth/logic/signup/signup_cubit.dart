import 'package:advanced_banking_system/features/auth/data/models/sinup/signup_request_body.dart';
import 'package:advanced_banking_system/features/auth/data/models/sinup/signup_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../../data/repos/signup_repo.dart';

part 'signup_state.dart';
part 'signup_cubit.freezed.dart';

class SignupCubit extends Cubit<SignupState> {
  final SignupRepo _signupRepo;

  SignupCubit(this._signupRepo) : super(const SignupState.initial());

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (state is _Loading) return;

    emit(const SignupState.loading());

    try {
      final request = SignupRequestBody(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      final response = await _signupRepo.signup(request);
      emit(SignupState.success(response));
    } catch (e) {
      final exception = NetworkExceptions.getException(e);
      final message = NetworkExceptions.getErrorMessage(exception);
      emit(SignupState.error(message));
    }
  }
}
