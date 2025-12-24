import 'package:advanced_banking_system/core/networking/api_services_impl.dart';
import 'package:advanced_banking_system/core/networking/app_link_url.dart';
import 'package:advanced_banking_system/core/networking/error/error_handler/network_exceptions.dart';
import 'package:advanced_banking_system/features/auth/data/models/otp/send_otp_request_body.dart';
import 'package:advanced_banking_system/features/auth/data/models/otp/send_otp_response.dart';
import 'package:dio/dio.dart';

abstract class OtpRemoteDataSource {
  Future<SendOtpResponse> sendOtp(SendOtpRequestBody request);
}

class OtpRemoteDataSourceImp implements OtpRemoteDataSource {
  final ApiServicesImpl apiServicesImpl;

  OtpRemoteDataSourceImp({required this.apiServicesImpl});

  @override
  Future<SendOtpResponse> sendOtp(SendOtpRequestBody request) async {
    try {
      final result = await apiServicesImpl.post(
        AppLinkUrl.sendOtp,
        body: request.toJson(),
      );

      return SendOtpResponse.fromJson(result);
    } on DioException catch (e) {
      throw NetworkExceptions.getException(e);
    } catch (e) {
      throw NetworkExceptions.getException(e);
    }
  }
}
