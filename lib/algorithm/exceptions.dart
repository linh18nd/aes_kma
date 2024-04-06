import 'dart:io';

class AesCryptException implements Exception {
  final String message;
  const AesCryptException(this.message);

  @override
  String toString() => message;
}

class AesCryptArgumentError extends ArgumentError {
  AesCryptArgumentError(String message) : super(message);
  static void checkNullOrEmpty(Object? argument, String message) {
    if (argument == null ||
        ((argument is String) ? argument.isEmpty : false) ||
        ((argument is Iterable) ? argument.isEmpty : false)) {
      throw AesCryptArgumentError(message);
    }
  }
}

class AesCryptFsException extends FileSystemException {
  const AesCryptFsException(String message,
      [String? path = '', OSError? osError])
      : super(message, path, osError);
}

class AesCryptDataException implements Exception {
  final String message;

  const AesCryptDataException(this.message);

  @override
  String toString() => message;
}
