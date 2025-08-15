abstract class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class WebSocketException extends AppException {
  const WebSocketException(super.message);
}

class WebSocketConnectionException extends WebSocketException {
  const WebSocketConnectionException(super.message);
}

class WebSocketAuthenticationException extends WebSocketException {
  const WebSocketAuthenticationException(super.message);
}

class WebSocketTimeoutException extends WebSocketException {
  const WebSocketTimeoutException(super.message);
}