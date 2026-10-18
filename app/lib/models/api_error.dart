/// Error shape from the v1 contract: `{ "error": { "code", "message" } }`.
class ApiException implements Exception {
  ApiException({required this.code, required this.message, this.status});

  final String code;
  final String message;
  final int? status;

  bool get isNotImplemented => status == 501 || code == 'not_implemented';
  bool get isNetwork => code == 'network';

  @override
  String toString() => 'ApiException($code, $status): $message';
}
