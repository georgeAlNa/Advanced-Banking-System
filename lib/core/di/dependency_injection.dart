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


  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));
  
  getIt.registerLazySingleton<LoginRepo>(
    () => LoginRepo(networkInfo: getIt(), loginRemoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImp(apiServicesImpl: getIt()),
  );


  getIt.registerFactory<HomeCubit>(() => HomeCubit());


  getIt.registerFactory<AccountsCubit>(() => AccountsCubit(repo: getIt()));

  getIt.registerLazySingleton<AccountRepo>(
    () => AccountRepoImpl(remote: getIt()),
  );

  getIt.registerLazySingleton<AccountsRemoteDataSource>(
    () => AccountsRemoteDataSourceMock(),
  );


  getIt.registerFactory<TransferMoneyCubit>(
    () => TransferMoneyCubit(repo: getIt<TransferRepo>()),
  );

  getIt.registerLazySingleton<TransferRepo>(
    () => TransferRepoImpl(remote: getIt()),
  );

  getIt.registerLazySingleton<TransferRemoteDataSource>(
    () => TransferRemoteDataSourceMock(),
  );


  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImp(internetConnectionChecker: getIt()),
  );

  getIt.registerLazySingleton(() => CrudDio());
  getIt.registerLazySingleton(() => ApiServicesImpl());


  final sharedPreference = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreference);
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}