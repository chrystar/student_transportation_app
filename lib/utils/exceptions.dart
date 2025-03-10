class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class LocationException extends AppException {
  LocationException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class PermissionException extends AppException {
  PermissionException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class ValidationException extends AppException {
  ValidationException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class DatabaseException extends AppException {
  DatabaseException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class StorageException extends AppException {
  StorageException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class NotificationException extends AppException {
  NotificationException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class BookingException extends AppException {
  BookingException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class TripException extends AppException {
  TripException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class VehicleException extends AppException {
  VehicleException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class MessageException extends AppException {
  MessageException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}
