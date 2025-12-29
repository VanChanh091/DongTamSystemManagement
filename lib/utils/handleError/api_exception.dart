class ApiException implements Exception {
  final int? status;
  final String? message;
  final String? errorCode;

  ApiException({required this.status, required this.message, required this.errorCode});
}
