import 'package:advanced_banking_system/features/home/logic/cubit/home_cubit.dart';
import 'package:dio/dio.dart';

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/accounts/data/datasources/accounts_remote_data_source.dart';
import '../../features/accounts/data/repos/accounts_repo_impl.dart';
import '../../features/accounts/logic/cubit/accounts_cubit.dart';
import '../../features/accounts/logic/services/account_repo.dart';
import '../../features/auth/data/datasources/login_remote_data_source.dart';
import '../../features/auth/data/repos/login_repo.dart';
import '../../features/auth/logic/login/login_cubit.dart';
import '../../features/transfer_money/data/datasources/transfer_remote_data_source.dart';
import '../../features/transfer_money/data/repos/transfer_repo_impl.dart';
import '../../features/transfer_money/logic/cubit/transfer_money_cubit.dart';
import '../../features/transfer_money/logic/services/transfer_repo.dart';
import '../networking/api_services_impl.dart';
import '../networking/crud_dio.dart';
import '../networking/network_info.dart';

final getIt = GetIt.instance;

Future<void> setupGetit() async {
  // //! feature - login

  //cubit
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));
  //repo
  getIt.registerLazySingleton<LoginRepo>(
    () => LoginRepo(networkInfo: getIt(), loginRemoteDataSource: getIt()),
  );
  //data source
  getIt.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImp(apiServicesImpl: getIt()),
  );
  // //! feature - home

  //cubit
  getIt.registerFactory<HomeCubit>(() => HomeCubit());
  //repo
  // getIt.registerLazySingleton<LoginRepo>(
  //   () => LoginRepo(networkInfo: getIt(), loginRemoteDataSource: getIt()),
  // );
  //data source
  // getIt.registerLazySingleton<LoginRemoteDataSource>(
  //   () => LoginRemoteDataSourceImp(apiServicesImpl: getIt()),
  // );
  // //! feature - accounts

  //cubit
  getIt.registerFactory<AccountsCubit>(() => AccountsCubit(repo: getIt()));
  //repo
  getIt.registerLazySingleton<AccountRepo>(
    () => AccountRepoImpl(remote: getIt()),
  );
  //data source
  getIt.registerLazySingleton<AccountsRemoteDataSource>(
    () =>
        AccountsRemoteDataSourceMock(), //! TODO  : REPLACE WITH  RemoteDataSourceImpl
  );

  //! transfer_money

  //cubit
  getIt.registerFactory<TransferMoneyCubit>(
    () => TransferMoneyCubit(repo: getIt<TransferRepo>()),
  );

  //repo
  getIt.registerLazySingleton<TransferRepo>(
    () => TransferRepoImpl(remote: getIt()),
  );

  //data source
  getIt.registerLazySingleton<TransferRemoteDataSource>(
    () => TransferRemoteDataSourceMock(),
  );

  //! Core

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImp(internetConnectionChecker: getIt()),
  );

  getIt.registerLazySingleton(() => CrudDio());
  getIt.registerLazySingleton(() => ApiServicesImpl());

  //! External

  final sharedPreference = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreference);
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}
