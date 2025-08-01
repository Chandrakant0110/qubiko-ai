/// Base exception class for all application exceptions
/// This provides a consistent way to handle and categorize errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.connectionFailed() {
    return const NetworkException(
      'Unable to connect to the server. Please check your internet connection.',
      code: 'NETWORK_CONNECTION_FAILED',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      'Request timed out. Please try again.',
      code: 'NETWORK_TIMEOUT',
    );
  }

  factory NetworkException.serverError(int statusCode) {
    return NetworkException(
      'Server error occurred (${statusCode}). Please try again later.',
      code: 'SERVER_ERROR_$statusCode',
    );
  }

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when API responses contain invalid data
class DataException extends AppException {
  const DataException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory DataException.invalidFormat() {
    return const DataException(
      'Invalid data format received from server.',
      code: 'DATA_INVALID_FORMAT',
    );
  }

  factory DataException.notFound() {
    return const DataException(
      'Requested data not found.',
      code: 'DATA_NOT_FOUND',
    );
  }

  factory DataException.parsingFailed(dynamic originalError) {
    return DataException(
      'Failed to parse response data.',
      code: 'DATA_PARSING_FAILED',
      originalError: originalError,
    );
  }

  @override
  String toString() => 'DataException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException(
    super.message, {
    super.code,
    this.fieldErrors = const {},
    super.originalError,
    super.stackTrace,
  });

  factory ValidationException.fieldRequired(String fieldName) {
    return ValidationException(
      '$fieldName is required.',
      code: 'VALIDATION_FIELD_REQUIRED',
      fieldErrors: {fieldName: '$fieldName is required.'},
    );
  }

  factory ValidationException.fieldTooLong(String fieldName, int maxLength) {
    return ValidationException(
      '$fieldName is too long. Maximum length is $maxLength characters.',
      code: 'VALIDATION_FIELD_TOO_LONG',
      fieldErrors: {
        fieldName: '$fieldName is too long. Maximum length is $maxLength characters.'
      },
    );
  }

  factory ValidationException.invalidSelection() {
    return const ValidationException(
      'Please make a valid selection to continue.',
      code: 'VALIDATION_INVALID_SELECTION',
    );
  }

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory StorageException.saveFailed() {
    return const StorageException(
      'Failed to save data. Please try again.',
      code: 'STORAGE_SAVE_FAILED',
    );
  }

  factory StorageException.loadFailed() {
    return const StorageException(
      'Failed to load data. Please try again.',
      code: 'STORAGE_LOAD_FAILED',
    );
  }

  @override
  String toString() => 'StorageException: $message';
}

/// Exception thrown when business logic rules are violated
class BusinessException extends AppException {
  const BusinessException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory BusinessException.invalidWorkflow() {
    return const BusinessException(
      'Invalid workflow configuration. Please check your settings.',
      code: 'BUSINESS_INVALID_WORKFLOW',
    );
  }

  factory BusinessException.stepNotAllowed(int currentStep, int requestedStep) {
    return BusinessException(
      'Cannot proceed to step $requestedStep from step $currentStep.',
      code: 'BUSINESS_STEP_NOT_ALLOWED',
    );
  }

  @override
  String toString() => 'BusinessException: $message';
}