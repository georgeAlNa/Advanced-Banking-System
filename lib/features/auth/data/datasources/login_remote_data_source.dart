import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/networking/api_services_impl.dart';
import '../../../../core/networking/app_link_url.dart';
import '../../../../core/networking/error/failure.dart';
import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../../../../core/networking/resilient_fetcher.dart';
import '../models/login/login_request_body.dart';
import '../models/login/login_response.dart';

abstract class LoginRemoteDataSource {
  Future<LoginResponse> login(LoginRequestBody request);
}

class LoginRemoteDataSourceImp implements LoginRemoteDataSource {
  final ApiServicesImpl apiServicesImpl;

  LoginRemoteDataSourceImp({required this.apiServicesImpl});

  @override
  Future<LoginResponse> login(LoginRequestBody request) async {
    final result = await AppFetchers.auth.call<Map<String, dynamic>>(
      request: () async {
        try {
          final data = await apiServicesImpl.post(
            AppLinkUrl.login,
            body: request.toJson(),
          ) as Map<String, dynamic>;
          return Right(data);
        } on DioException catch (e) {
          return Left(ServerFailure(
            NetworkExceptions.getErrorMessage(NetworkExceptions.getException(e)),
          ));
        } catch (e) {
          return Left(ServerFailure(e.toString()));
        }
      },
      fallback:  Left(ServerFailure('خدمة تسجيل الدخول غير متاحة مؤقتاً')),
    );

    return result.fold(
      (failure) => throw NetworkExceptions.defaultError(failure.message),
      (data)    => LoginResponse.fromJson(data),
    );
  }
}