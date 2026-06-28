import 'package:dartz/dartz.dart';

import '../../../../core/networking/error/failure.dart';
import '../../../../core/networking/resilient_fetcher.dart';
import '../../../../core/networking/crud_dio.dart';
import '../models/transfer_request_model.dart';
import '../models/transfer_response_model.dart';

abstract class TransferRemoteDataSource {
  Future<double> getAccountBalance(String accountId);
  Future<double> getRemainingDailyLimit(String accountId);
  Future<TransferResponseModel> processTransfer(TransferRequestModel request);
  Future<void> debitAccount(String accountId, double amount);   // ← جديد
  Future<void> creditAccount(String accountId, double amount);  // ← جديد
}

// ── Mock ─────────────────────────────────────────────────────────────────────
// يستخدم in-memory balance لتشغيل الـ 2PC demo بشكل كامل

class TransferRemoteDataSourceMock implements TransferRemoteDataSource {
  // محاكاة أرصدة الحسابات في الذاكرة
  final _balances = <String, double>{
    'ACC-001': 5000.0,
    'ACC-002': 3000.0,
    'ACC-003': 8000.0,
    'ACC-004': 1500.0,
  };

  final _dailyLimits = <String, double>{
    'ACC-001': 2000.0,
    'ACC-002': 2000.0,
    'ACC-003': 2000.0,
    'ACC-004': 2000.0,
  };

  @override
  Future<double> getAccountBalance(String accountId) async =>
      _balances[accountId] ?? 5000.0;

  @override
  Future<double> getRemainingDailyLimit(String accountId) async =>
      _dailyLimits[accountId] ?? 2000.0;

  @override
  Future<TransferResponseModel> processTransfer(TransferRequestModel request) async {
    return const TransferResponseModel(
      transactionId: 'TX-1001',
      status: 'success',
      message: 'Transfer completed successfully',
    );
  }

  // ── 2PC participants يستدعون هذين ─────────────────────────────────────────

  @override
  Future<void> debitAccount(String accountId, double amount) async {
    final current = _balances[accountId] ?? 0.0;
    _balances[accountId] = current - amount;
  }

  @override
  Future<void> creditAccount(String accountId, double amount) async {
    final current = _balances[accountId] ?? 0.0;
    _balances[accountId] = current + amount;
  }
}

// ── Real Implementation ───────────────────────────────────────────────────────

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final CrudDio _crudDio;
  final String? _token;

  static const _balanceFallback = 0.0;
  static const _limitFallback   = 0.0;

  TransferRemoteDataSourceImpl({
    required CrudDio crudDio,
    String? token,
  }) : _crudDio = crudDio,
       _token   = token;

  @override
  Future<double> getAccountBalance(String accountId) async {
    final result = await AppFetchers.transfer.call<Map<String, dynamic>>(
      request: () async {
        final either = await _crudDio.dioGetMethod(
          endPoint: '/accounts/$accountId/balance',
          token: _token,
          queryParameters: null,
        );
        return either.fold((f) => Left(f), (d) => Right(d as Map<String, dynamic>));
      },
      fallback: Left(ServerFailure('الرصيد غير متاح مؤقتاً')),
    );
    return result.fold((_) => _balanceFallback,
        (data) => (data['balance'] as num).toDouble());
  }

  @override
  Future<double> getRemainingDailyLimit(String accountId) async {
    final result = await AppFetchers.transfer.call<Map<String, dynamic>>(
      request: () async {
        final either = await _crudDio.dioGetMethod(
          endPoint: '/accounts/$accountId/daily-limit',
          token: _token,
          queryParameters: null,
        );
        return either.fold((f) => Left(f), (d) => Right(d as Map<String, dynamic>));
      },
      fallback: Left(ServerFailure('حد التحويل غير متاح مؤقتاً')),
    );
    return result.fold((_) => _limitFallback,
        (data) => (data['remaining'] as num).toDouble());
  }

  @override
  Future<TransferResponseModel> processTransfer(TransferRequestModel request) async {
    final result = await AppFetchers.transfer.call<Map<String, dynamic>>(
      request: () async {
        final either = await _crudDio.dioPostMethod(
          endPoint: '/transfers',
          data: request.toJson(),
          token: _token,
          queryParameters: null,
        );
        return either.fold((f) => Left(f), (d) => Right(d as Map<String, dynamic>));
      },
      fallback: Left(ServerFailure('خدمة التحويل غير متاحة مؤقتاً')),
    );
    return result.fold(
      (failure) => throw failure,
      (data) => TransferResponseModel.fromJson(data),
    );
  }

  @override
  Future<void> debitAccount(String accountId, double amount) async {
    await _crudDio.dioPostMethod(
      endPoint: '/accounts/$accountId/debit',
      data: {'amount': amount},
      token: _token,
      queryParameters: null,
    );
  }

  @override
  Future<void> creditAccount(String accountId, double amount) async {
    await _crudDio.dioPostMethod(
      endPoint: '/accounts/$accountId/credit',
      data: {'amount': amount},
      token: _token,
      queryParameters: null,
    );
  }
}