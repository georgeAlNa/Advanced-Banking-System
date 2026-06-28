import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/logging/audit_logger.dart';
import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../../../../core/security/jwt_service.dart';
import '../../../../core/security/secure_storage.dart';
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
      final request  = LoginRequestBody(email: email, password: password);
      final response = await _loginRepo.login(request);

      final verification = JwtService.instance.verify(response.token);

      switch (verification) {
        case JwtExpired():
          await AuditLogger.instance.log(
            AuditEvent.loginExpiredToken,
            overrideUserId: email,
            details: {'expiredAt': verification.expiredAt.toIso8601String()},
          );
          emit(const LoginState.error('انتهت صلاحية الجلسة، حاول مجدداً'));
          return;

        case JwtMalformed():
          await AuditLogger.instance.log(
            AuditEvent.loginFailed,
            overrideUserId: email,
            details: {'reason': verification.reason},
          );
          emit(const LoginState.error('خطأ في بيانات الجلسة'));
          return;

        case JwtValid():
          await SecureStorage.instance.saveToken(response.token);

          await AuditLogger.instance.log(
            AuditEvent.loginSuccess,
            details: {'role': verification.claims.role},
          );

          emit(LoginState.success(response));
      }
    } catch (e) {
      final exception = NetworkExceptions.getException(e);
      final message   = NetworkExceptions.getErrorMessage(exception);

      await AuditLogger.instance.log(
        AuditEvent.loginFailed,
        overrideUserId: email,
        details: {'error': message},
      );

      emit(LoginState.error(message));
    }
  }
}