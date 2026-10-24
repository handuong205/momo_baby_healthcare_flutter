class ApiException implements Exception {
  final String message;
  final List<String> errors;
  final String? errorCode;
  final int? statusCode;

  ApiException({
    required this.message,
    this.errors = const [],
    this.errorCode,
    this.statusCode,
  });

  @override
  String toString() {
    return message;
  }
}