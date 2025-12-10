import 'package:advanced_banking_system/features/auth/data/datasources/login_remote_data_source.dart';
import 'package:advanced_banking_system/features/auth/data/models/login/login_response.dart';

import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../../../../core/networking/network_info.dart';
import '../models/login/login_request_body.dart';

class LoginRepo {
  final LoginRemoteDataSource loginRemoteDataSource;
  final NetworkInfo networkInfo;
  LoginRepo({required this.networkInfo, required this.loginRemoteDataSource});

  Future<LoginResponse> login(LoginRequestBody login) async {
    final LoginRequestBody loginModel = LoginRequestBody(
      // email: login.identifier,
      // password: login.password,
    );
    if (await networkInfo.isConnected) {
      try {
        final loginResponse = await loginRemoteDataSource.login(loginModel);
        return loginResponse;
      } catch (e) {
        final exception = NetworkExceptions.getException(e);
        throw exception;
      }
    } else {
      throw const NetworkExceptions.noInternetConnection();
    }
  }
}
