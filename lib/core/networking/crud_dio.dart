import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'app_link_url.dart';
import 'error/failure.dart';
import 'dart:io';

class CrudDio {
  late Dio dio;

  CrudDio() {
    BaseOptions options = BaseOptions(
      baseUrl: AppLinkUrl.baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<Either<Failure, Map<String, dynamic>>> dioGetMethod({
    required String endPoint,
    @required String? token,
    @required Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers.addAll({'Authorization': 'Bearer $token'});
      }
      if (kDebugMode) {
        printRequest(
          method: "GET",
          endPoint: AppLinkUrl.baseUrl + endPoint,
          headers: headers,
          token: token,
          queryParameters: queryParameters,
        );
      }
      var response = await dio.get(
        endPoint,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      if (kDebugMode) {
        print('Status Code : ${response.statusCode}');
        print("🔍 Response body: ${response.data}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseBody = response.data;
        return Right(responseBody);
      } else {
        String errorMessage =
            'Request failed\nStatus Code: ${response.statusCode}\nResponse: ${response.data}';
        if (kDebugMode) print(errorMessage);
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      String errorMessage = 'Exception occurred: $e';
      if (kDebugMode) print(errorMessage);
      return Left(ServerFailure(errorMessage));
    }
  }

  Future<Either<Failure, dynamic>> dioPostMethod({
    required String endPoint,
    required Map data,
    @required String? token,
    @required Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers.addAll({'Authorization': 'Bearer $token'});
      }
      if (kDebugMode) {
        printRequest(
          method: "POST",
          endPoint: AppLinkUrl.baseUrl + endPoint,
          headers: headers,
          token: token,
          data: data,
          queryParameters: queryParameters,
        );
      }
      var response = await dio.post(
        endPoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responsebody = response.data;
        printResponse(responsebody, response.statusCode);
        return Right(responsebody);
      } else {
        String errorMessage =
            'Request failed\nStatus Code: ${response.statusCode}\nResponse: ${response.data}';
        if (kDebugMode) print(errorMessage);
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      String errorMessage = 'Exception occurred: $e';
      if (kDebugMode) print(errorMessage);
      return Left(ServerFailure(errorMessage));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> dioPutMethod({
    required String endPoint,
    @required Map? data,
    @required String? token,
    @required Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers.addAll({'Authorization': 'Bearer $token'});
      }

      if (kDebugMode) {
        printRequest(
          method: "PUT",
          endPoint: AppLinkUrl.baseUrl + endPoint,
          headers: headers,
          token: token,
          data: data,
          queryParameters: queryParameters,
        );
      }

      var response = await dio.put(
        endPoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseBody = response.data;
        return Right(responseBody);
      } else {
        String errorMessage =
            'Request failed\nStatus Code: ${response.statusCode}\nResponse: ${response.data}';
        if (kDebugMode) print(errorMessage);
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      String errorMessage = 'Exception occurred: $e';
      if (kDebugMode) print(errorMessage);
      return Left(ServerFailure(errorMessage));
    }
  }

  Future<Either<Failure, List>> dioPatchMethod({
    required String endPoint,
    @required Map? data,
    @required String? token,
    @required Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers.addAll({'Authorization': 'Bearer $token'});
      }
      if (kDebugMode) {
        printRequest(
          method: "PATCH",
          endPoint: AppLinkUrl.baseUrl + endPoint,
          headers: headers,
          token: token,
          data: data,
          queryParameters: queryParameters,
        );
      }
      var response = await dio.patch(
        endPoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        List responsebody = response.data;
        return Right(responsebody);
      } else {
        String errorMessage =
            'Request failed\nStatus Code: ${response.statusCode}\nResponse: ${response.data}';
        if (kDebugMode) print(errorMessage);
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      String errorMessage = 'Exception occurred: $e';
      if (kDebugMode) print(errorMessage);
      return Left(ServerFailure(errorMessage));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> dioDeleteMethod({
    required String endPoint,
    @required Map? data,
    @required String? token,
    @required Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers.addAll({'Authorization': 'Bearer $token'});
      }
      if (kDebugMode) {
        printRequest(
          method: "DELETE",
          endPoint: AppLinkUrl.baseUrl + endPoint,
          headers: headers,
          token: token,
          data: data,
          queryParameters: queryParameters,
        );
      }

      var response = await dio.delete(
        endPoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseBody = response.data;
        return Right(responseBody);
      } else {
        String errorMessage =
            'Request failed\nStatus Code: ${response.statusCode}\nResponse: ${response.data}';
        if (kDebugMode) print(errorMessage);
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      String errorMessage = 'Exception occurred: $e';
      if (kDebugMode) print(errorMessage);
      return Left(ServerFailure(errorMessage));
    }
  }

  void printRequest({
    required String method,
    required String endPoint,
    required Map<String, String> headers,
    Map? data,
    String? token,
    Map<String, dynamic>? queryParameters,
  }) {
    if (kDebugMode) {
      final prettyBody =
          data != null ? JsonEncoder.withIndent('  ').convert(data) : 'No Body';
      print('''
╔════════════════════════════════════════════════╗
║              🌐 $method Request               ║
╠════════════════════════════════════════════════╣
║ 🔗 URL: $endPoint
║ 🏷 Token: ${token ?? 'No Token'}
║ 📌 Headers: ${jsonEncode(headers)}
║ 🔍 Query Params: ${jsonEncode(queryParameters ?? {})}
╠════════════════════════════════════════════════╣
║ 📦 Body:
$prettyBody
╚════════════════════════════════════════════════╝
    ''');
    }
  }

  void printResponse(Map<String, dynamic> responseBody, int? statusCode) {
    final prettyJson = const JsonEncoder.withIndent("  ").convert(responseBody);
    if (kDebugMode) {
      print('''
╔════════════════════════════════════════════════╗
║            ✅ Response Received               ║
╠════════════════════════════════════════════════╣
status code : $statusCode
$prettyJson
╚════════════════════════════════════════════════╝
  ''');
    }
  }
}
