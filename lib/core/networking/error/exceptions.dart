class OfflineException implements Exception {
  final String message;
  OfflineException([this.message = "No Internet Connection"]);
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = "Server Error"]);
}

class EmptyCacheException implements Exception {
  final String message;
  EmptyCacheException([this.message = "No data in cache"]);
}
