import 'package:dio/dio.dart';

import '../../../../core/networking/api_services_impl.dart';
import '../../../../core/networking/app_link_url.dart';
import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../models/login/login_request_body.dart';
import '../models/login/login_response.dart';

abstract class LoginRemoteDataSource {
  Future<LoginResponse> login(LoginRequestBody loginRequest);
}

class LoginRemoteDataSourceImp implements LoginRemoteDataSource {
  final ApiServicesImpl apiServicesImpl;

  LoginRemoteDataSourceImp({required this.apiServicesImpl});

  @override
  Future<LoginResponse> login(LoginRequestBody login) async {
    try {
      final result = await apiServicesImpl.post(
        AppLinkUrl.login,
        body: {
          // 'email': login.email,
          // 'password': login.password,
        },
      );

      // final response = LoginResponse.fromJson(result);

      return LoginResponse();
    } on DioException catch (e) {
      throw NetworkExceptions.getException(e);
    } catch (e) {
      throw NetworkExceptions.getException(e);
    }
  }
}
