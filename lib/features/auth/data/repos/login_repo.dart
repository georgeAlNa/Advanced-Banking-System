import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../../../../core/networking/network_info.dart';

import '../datasources/login_remote_data_source.dart';
import '../models/login/login_request_body.dart';
import '../models/login/login_response.dart';

class LoginRepo {
  final LoginRemoteDataSource loginRemoteDataSource;
  final NetworkInfo networkInfo;

  LoginRepo({
    required this.loginRemoteDataSource,
    required this.networkInfo,
  });

  Future<LoginResponse> login(LoginRequestBody request) async {
    if (await networkInfo.isConnected) {
      try {
        return await loginRemoteDataSource.login(request);
      } catch (e) {
        throw NetworkExceptions.getException(e);
      }
    } else {
      throw const NetworkExceptions.noInternetConnection();
    }
  }
}
