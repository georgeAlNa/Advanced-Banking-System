import '../networking/error/failure.dart';
import '../constants/strings.dart';

String failureMessages(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure():
      return serverFailureString;
    case OfflineFailure():
      return offlineFailureString;
    default:
      return defaultMessageFailureString;
  }
}