import 'package:advanced_banking_system/core/networking/error/error_handler/network_exceptions.dart';
import 'package:advanced_banking_system/core/networking/network_info.dart';
import 'package:advanced_banking_system/features/auth/data/datasources/otp_remote_data_source.dart';
import 'package:advanced_banking_system/features/auth/data/models/otp/send_otp_request_body.dart';
import 'package:advanced_banking_system/features/auth/data/models/otp/send_otp_response.dart';

class OtpRepo {
  final OtpRemoteDataSource otpRemoteDataSource;
  final NetworkInfo networkInfo;

  OtpRepo({
    required this.otpRemoteDataSource,
    required this.networkInfo,
  });

  Future<SendOtpResponse> sendOtp(SendOtpRequestBody request) async {
    if (await networkInfo.isConnected) {
      return await otpRemoteDataSource.sendOtp(request);
    } else {
      throw const NetworkExceptions.noInternetConnection();
    }
  }
}
