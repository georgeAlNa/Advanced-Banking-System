import 'package:advanced_banking_system/features/auth/data/models/sinup/signup_request_body.dart';
import 'package:advanced_banking_system/features/auth/data/models/sinup/signup_response.dart';
import 'package:dio/dio.dart';

import '../../../../core/networking/api_services_impl.dart';
import '../../../../core/networking/app_link_url.dart';
import '../../../../core/networking/error/error_handler/network_exceptions.dart';

abstract class SignupRemoteDataSource {
  Future<SignupResponse> signup(SignupRequestBody request);
}

class SignupRemoteDataSourceImp implements SignupRemoteDataSource {
  final ApiServicesImpl apiServicesImpl;

  SignupRemoteDataSourceImp({required this.apiServicesImpl});

  @override
  Future<SignupResponse> signup(SignupRequestBody request) async {
    try {
      final result = await apiServicesImpl.post(
        AppLinkUrl.signup,
        body: request.toJson(),
      );

      return SignupResponse.fromJson(result);
    } on DioException catch (e) {
      throw NetworkExceptions.getException(e);
    } catch (e) {
      throw NetworkExceptions.getException(e);
    }
  }
}
