import 'item_photos.dart';

/// Asset path of the bundled thumb for an item, or null when none matches.
/// Keyed by item_id first; backends that mint their own ids fall back to a
/// name match against the catalogue names (prefix, then first word).
String? itemPhotoAsset(String itemId, String name) {
  if (kItemPhotoNames.containsKey(itemId)) return 'assets/items/$itemId.jpg';
  final n = _norm(name);
  if (n.isEmpty) return null;
  String? byPrefix;
  String? byWord;
  final word = n.split(' ').first;
  for (final e in kItemPhotoNames.entries) {
    final c = _norm(e.value);
    if (n.startsWith(c) || c.startsWith(n)) {
      byPrefix ??= e.key;
    } else if (c.split(' ').first == word) {
      byWord ??= e.key;
    }
  }
  final id = byPrefix ?? byWord;
  return id == null ? null : 'assets/items/$id.jpg';
}

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
