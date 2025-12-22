import 'package:advanced_banking_system/features/auth/data/datasources/signup_remote_data_source.dart';
import 'package:advanced_banking_system/features/auth/data/models/sinup/signup_request_body.dart';
import 'package:advanced_banking_system/features/auth/data/models/sinup/signup_response.dart';

import '../../../../core/networking/error/error_handler/network_exceptions.dart';
import '../../../../core/networking/network_info.dart';

class SignupRepo {
  final SignupRemoteDataSource signupRemoteDataSource;
  final NetworkInfo networkInfo;

  SignupRepo({
    required this.signupRemoteDataSource,
    required this.networkInfo,
  });

  Future<SignupResponse> signup(SignupRequestBody request) async {
    if (await networkInfo.isConnected) {
      try {
        return await signupRemoteDataSource.signup(request);
      } catch (e) {
        throw NetworkExceptions.getException(e);
      }
    } else {
      throw const NetworkExceptions.noInternetConnection();
    }
  }
}
