import 'dart:core';

import 'package:advanced_banking_system/features/auth/data/models/otp/send_otp_request_body.dart';
import 'package:advanced_banking_system/features/auth/data/models/sinup/signup_request_body.dart';
import 'package:advanced_banking_system/features/auth/data/models/sinup/signup_response.dart';
import 'package:advanced_banking_system/features/auth/data/repos/otp_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../../data/repos/signup_repo.dart';

part 'signup_state.dart';
part 'signup_cubit.freezed.dart';
class SignupCubit extends Cubit<SignupState> {
  final SignupRepo _signupRepo;
  final OtpRepo _otpRepo;

  SignupCubit(this._signupRepo, this._otpRepo)
      : super(const SignupState.initial());

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(const SignupState.loading());

    try {
      final signupRequest = SignupRequestBody(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      await _signupRepo.signup(signupRequest);

      final otpResponse = await _otpRepo.sendOtp(
        SendOtpRequestBody(
          email: email,
          purpose: 'email_verification',
        ),
      );

      emit(
        SignupState.otpSent(
        ),
      );
    } catch (e) {
      final exception = NetworkExceptions.getException(e);
      emit(SignupState.error(
          NetworkExceptions.getErrorMessage(exception)));
    }
  }
}
