abstract class BaseException implements Exception{
  final String message;

  BaseException(this.message);

  @override
  String toString() {
    return message ?? '';
  }
}

class NoInternetException extends BaseException{
  NoInternetException() : super("No Internet Connection");
}


class ServerException extends BaseException{
  ServerException([String message]) : super(message);
}

class CacheException extends BaseException{
  CacheException([String message]) : super(message);
}