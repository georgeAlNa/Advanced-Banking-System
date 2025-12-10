import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_services.dart';
import 'app_link_url.dart';

late Map<String, dynamic> _headers;

Future<void> setHeaders({String? token}) async {
  _headers = {
    "Accept": Headers.jsonContentType,
    "Accept-Timezone": DateTime.now().timeZoneName,
  };

  if (token != null && token.isNotEmpty) {
    _headers["Authorization"] = "Bearer $token";
  }
}

dynamic _parseJsonResponse(Response<dynamic> response) {
  // final responseAsJson = jsonDecode(response.data ?? "{}");
  // return responseAsJson;
  if (response.data is String) {
    return jsonDecode(response.data);
  } else if (response.data is Map<String, dynamic>) {
    return response.data;
  } else {
    return {};
  }
}

class ApiServicesImpl implements ApiServices {
  final Dio _dio = GetIt.I.get<Dio>();

  ApiServicesImpl() {
    _dio.options
      ..baseUrl =
          AppLinkUrl
              .baseUrl // Put here your base Url
      ..responseType = ResponseType.plain
      ..sendTimeout = const Duration(minutes: 1)
      ..receiveTimeout = const Duration(minutes: 1)
      ..connectTimeout = const Duration(minutes: 1)
      ..followRedirects = true;

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          requestHeader: true,
          responseHeader: true,
          request: true,
          responseBody: true,
        ),
      );
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      await setHeaders(token: token);
      final response = await _dio.delete(
        path,
        queryParameters: queryParams,
        data: body,
        options: Options(headers: _headers),
      );
      return _parseJsonResponse(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    String? token,
  }) async {
    try {
      await setHeaders(token: token);
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: Options(headers: _headers),
      );
      return _parseJsonResponse(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    FormData? formData,
    String? token,
  }) async {
    try {
      await setHeaders(token: token);

      final response = await _dio.post(
        path,
        queryParameters: queryParams,
        data: formData ?? body,
        options: Options(
          headers: _headers,
          contentType: Headers.jsonContentType,
        ),
      );
      return _parseJsonResponse(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    FormData? formData,
    String? token,
  }) async {
    try {
      await setHeaders(token: token);
      final response = await _dio.put(
        path,
        queryParameters: queryParams,
        data: formData ?? body,
        options: Options(
          headers: _headers,
          contentType: Headers.jsonContentType,
        ),
      );
      return _parseJsonResponse(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    FormData? formData,
    // bool? hasToken,
    String? token,
  }) async {
    try {
      await setHeaders(token: token);
      final response = await _dio.patch(
        path,
        queryParameters: queryParams,
        data: formData ?? body,
        options: Options(
          headers: _headers,
          contentType: Headers.jsonContentType,
        ),
      );
      return _parseJsonResponse(response);
    } catch (error) {
      rethrow;
    }
  }
}
