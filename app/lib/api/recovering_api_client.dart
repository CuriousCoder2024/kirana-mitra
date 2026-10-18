import '../models/models.dart';
import 'api_client.dart';

/// Wraps the live client: when a call fails with 404 `not_found` for the
/// shop (the backend keeps shops in memory and forgets them on restart),
/// re-registers the shop through [recover] and retries the call once with
/// the new shop_id.
class RecoveringApiClient implements ApiClient {
  RecoveringApiClient(this.inner, {required this.recover});

  final ApiClient inner;

  /// Re-registers the shop and returns the new id, or null to give up.
  final Future<String?> Function() recover;

  DateTime? _lastRecovery;

  bool _isShopGone(ApiException e) =>
      e.status == 404 && e.code == 'not_found' && e.message.toLowerCase().contains('shop');

  Future<T> _guard<T>(String shopId, Future<T> Function(String shopId) call) async {
    try {
      return await call(shopId);
    } on ApiException catch (e) {
      if (!_isShopGone(e)) rethrow;
      // Never loop: one recovery per 30 s.
      final now = DateTime.now();
      if (_lastRecovery != null && now.difference(_lastRecovery!) < const Duration(seconds: 30)) rethrow;
      _lastRecovery = now;
      final newId = await recover();
      if (newId == null || newId == shopId) rethrow;
      return call(newId);
    }
  }

  @override
  bool get isLive => inner.isLive;

  @override
  Future<bool> healthz() => inner.healthz();

  @override
  Future<Shop> createShop({required String shopName, required String ownerName, required String language}) =>
      inner.createShop(shopName: shopName, ownerName: ownerName, language: language);

  @override
  Future<ExtractionReply> chat({required String shopId, required String text}) =>
      _guard(shopId, (id) => inner.chat(shopId: id, text: text));

  @override
  Future<ExtractionReply> voiceNote({required String shopId, required UploadBlob audio}) =>
      _guard(shopId, (id) => inner.voiceNote(shopId: id, audio: audio));

  @override
  Future<ExtractionReply> confirm({required String shopId, required String messageId}) =>
      _guard(shopId, (id) => inner.confirm(shopId: id, messageId: messageId));

  @override
  Future<UndoReply> undo({required String shopId, required String messageId}) =>
      _guard(shopId, (id) => inner.undo(shopId: id, messageId: messageId));

  @override
  Future<StockResponse> stock(String shopId) => _guard(shopId, inner.stock);

  @override
  Future<LedgerResponse> ledger(String shopId) => _guard(shopId, inner.ledger);

  @override
  Future<ShelfScanResponse> shelfScan({required String shopId, required UploadBlob image}) =>
      _guard(shopId, (id) => inner.shelfScan(shopId: id, image: image));

  @override
  Future<ForecastResponse> forecast(String shopId) => _guard(shopId, inner.forecast);

  @override
  Future<ReorderResponse> reorder(String shopId) => _guard(shopId, inner.reorder);

  @override
  Future<DaySummary> summary(String shopId, {String? date}) =>
      _guard(shopId, (id) => inner.summary(id, date: date));

  @override
  Future<LanguagesResponse> languages() => inner.languages();

  @override
  Future<Shop> updateShop(String shopId, {bool? autoRestock, String? distributorPhone}) =>
      _guard(shopId, (id) => inner.updateShop(id, autoRestock: autoRestock, distributorPhone: distributorPhone));

  @override
  Future<TopItemsResponse> topItems(String shopId, {int weeks = 2}) =>
      _guard(shopId, (id) => inner.topItems(id, weeks: weeks));

  @override
  Future<OrdersResponse> orders(String shopId) => _guard(shopId, inner.orders);

  @override
  Future<MessagesResponse> messages(String shopId, {DateTime? since}) =>
      _guard(shopId, (id) => inner.messages(id, since: since));

  @override
  Future<FeedbackReply> feedback({
    required String shopId,
    required String screen,
    required String rating,
    String? comment,
    required String appVersion,
    required String platform,
  }) =>
      _guard(
        shopId,
        (id) => inner.feedback(
          shopId: id,
          screen: screen,
          rating: rating,
          comment: comment,
          appVersion: appVersion,
          platform: platform,
        ),
      );

  @override
  Future<FeedbackReply> feedbackVoice({
    required String shopId,
    required String screen,
    required String rating,
    required UploadBlob audio,
    required String appVersion,
    required String platform,
  }) =>
      _guard(
        shopId,
        (id) => inner.feedbackVoice(
          shopId: id,
          screen: screen,
          rating: rating,
          audio: audio,
          appVersion: appVersion,
          platform: platform,
        ),
      );
}
