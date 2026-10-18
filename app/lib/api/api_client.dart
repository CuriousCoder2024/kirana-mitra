import 'dart:typed_data';

import '../models/models.dart';

/// Bytes of a recorded voice note or a picked image, plus what to call them.
class UploadBlob {
  const UploadBlob({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;

  /// e.g. `audio/m4a`, `audio/webm`, `image/jpeg`.
  final String mimeType;
}

/// The v1 contract in docs/api-contract.md. Implemented by [DioApiClient]
/// (real backend) and [MockApiClient] (demo without a backend).
abstract class ApiClient {
  /// True when this client talks to a real backend.
  bool get isLive;

  Future<bool> healthz();

  Future<Shop> createShop({
    required String shopName,
    required String ownerName,
    required String language,
  });

  Future<ExtractionReply> chat({required String shopId, required String text});

  Future<ExtractionReply> voiceNote({
    required String shopId,
    required UploadBlob audio,
  });

  Future<ExtractionReply> confirm({
    required String shopId,
    required String messageId,
  });

  Future<UndoReply> undo({required String shopId, required String messageId});

  Future<StockResponse> stock(String shopId);

  Future<LedgerResponse> ledger(String shopId);

  Future<ShelfScanResponse> shelfScan({
    required String shopId,
    required UploadBlob image,
  });

  Future<ForecastResponse> forecast(String shopId);

  Future<ReorderResponse> reorder(String shopId);

  /// GET /summary/{shop_id}?date=YYYY-MM-DD (date defaults to today).
  Future<DaySummary> summary(String shopId, {String? date});

  // ---- v1.1 ----

  Future<LanguagesResponse> languages();

  /// PATCH /shops/{shop_id}; both fields optional.
  Future<Shop> updateShop(String shopId, {bool? autoRestock, String? distributorPhone});

  Future<TopItemsResponse> topItems(String shopId, {int weeks = 2});

  Future<OrdersResponse> orders(String shopId);

  /// Server-side bot messages (auto-order notices) created after [since].
  Future<MessagesResponse> messages(String shopId, {DateTime? since});

  Future<FeedbackReply> feedback({
    required String shopId,
    required String screen,
    required String rating,
    String? comment,
    required String appVersion,
    required String platform,
  });

  Future<FeedbackReply> feedbackVoice({
    required String shopId,
    required String screen,
    required String rating,
    required UploadBlob audio,
    required String appVersion,
    required String platform,
  });
}
