import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'api_client.dart';

/// Talks to the FastAPI backend. Base URL comes from
/// `--dart-define API_BASE_URL=...`; the default is localhost:8080, or
/// 10.0.2.2:8080 on an Android emulator (which is how the emulator reaches
/// the host machine).
class DioApiClient implements ApiClient {
  DioApiClient({String? baseUrl, Dio? dio})
      : baseUrl = baseUrl ?? defaultBaseUrl(),
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = this.baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 60)
      ..headers = {'Accept': 'application/json'};
  }

  static const _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String defaultBaseUrl() {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  final String baseUrl;
  final Dio _dio;

  @override
  bool get isLive => true;

  /// Probes `GET /health`. Not `/healthz`: on Cloud Run the *.run.app edge
  /// answers `/healthz` itself with an HTML 404 that never reaches the backend.
  @override
  Future<bool> healthz() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
        ),
      );
      return res.data?['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _run(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final res = await call();
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return data.cast<String, dynamic>();
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    if (body is Map && body['error'] is Map) {
      final err = (body['error'] as Map).cast<String, dynamic>();
      return ApiException(
        code: err['code'] as String? ?? 'error',
        message: err['message'] as String? ?? e.message ?? 'Request failed',
        status: status,
      );
    }
    if (status == 501) {
      return ApiException(
        code: 'not_implemented',
        message: 'Not implemented yet',
        status: status,
      );
    }
    if (status != null) {
      return ApiException(
        code: 'http_$status',
        message: e.message ?? 'Request failed',
        status: status,
      );
    }
    return ApiException(
      code: 'network',
      message: e.message ?? 'Could not reach the server',
    );
  }

  @override
  Future<Shop> createShop({
    required String shopName,
    required String ownerName,
    required String language,
  }) async {
    final json = await _run(() => _dio.post('/shops', data: {
          'shop_name': shopName,
          'owner_name': ownerName,
          'language': language,
        }));
    return Shop.fromJson(json);
  }

  @override
  Future<ExtractionReply> chat({
    required String shopId,
    required String text,
  }) async {
    final json = await _run(
        () => _dio.post('/chat', data: {'shop_id': shopId, 'text': text}));
    return ExtractionReply.fromJson(json);
  }

  MultipartFile _multipart(UploadBlob blob) {
    final parts = blob.mimeType.split('/');
    return MultipartFile.fromBytes(
      blob.bytes,
      filename: blob.filename,
      contentType: parts.length == 2 ? DioMediaType(parts[0], parts[1]) : null,
    );
  }

  @override
  Future<ExtractionReply> voiceNote({
    required String shopId,
    required UploadBlob audio,
  }) async {
    final form = FormData.fromMap({
      'shop_id': shopId,
      'audio': _multipart(audio),
    });
    final json = await _run(() => _dio.post('/voice-note', data: form));
    return ExtractionReply.fromJson(json);
  }

  @override
  Future<ExtractionReply> confirm({
    required String shopId,
    required String messageId,
  }) async {
    final json = await _run(() => _dio.post('/confirm',
        data: {'shop_id': shopId, 'message_id': messageId}));
    return ExtractionReply.fromJson(json);
  }

  @override
  Future<UndoReply> undo({
    required String shopId,
    required String messageId,
  }) async {
    final json = await _run(() => _dio
        .post('/undo', data: {'shop_id': shopId, 'message_id': messageId}));
    return UndoReply.fromJson(json);
  }

  @override
  Future<StockResponse> stock(String shopId) async {
    final json = await _run(() => _dio.get('/stock/$shopId'));
    return StockResponse.fromJson(json);
  }

  @override
  Future<LedgerResponse> ledger(String shopId) async {
    final json = await _run(() => _dio.get('/ledger/$shopId'));
    return LedgerResponse.fromJson(json);
  }

  @override
  Future<ShelfScanResponse> shelfScan({
    required String shopId,
    required UploadBlob image,
  }) async {
    final form = FormData.fromMap({
      'shop_id': shopId,
      'image': _multipart(image),
    });
    final json = await _run(() => _dio.post('/shelf-scan', data: form));
    return ShelfScanResponse.fromJson(json);
  }

  @override
  Future<ForecastResponse> forecast(String shopId) async {
    final json = await _run(() => _dio.get('/forecast/$shopId'));
    return ForecastResponse.fromJson(json);
  }

  @override
  Future<ReorderResponse> reorder(String shopId) async {
    final json = await _run(() => _dio.post('/reorder/$shopId'));
    return ReorderResponse.fromJson(json);
  }

  @override
  Future<DaySummary> summary(String shopId, {String? date}) async {
    final json = await _run(() => _dio.get(
          '/summary/$shopId',
          queryParameters: date == null ? null : {'date': date},
        ));
    return DaySummary.fromJson(json);
  }
}
