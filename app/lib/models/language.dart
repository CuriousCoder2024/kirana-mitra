import '../l10n/languages.dart';

/// Response of GET /languages.
class LanguagesResponse {
  const LanguagesResponse({required this.languages});

  final List<KmLanguage> languages;

  factory LanguagesResponse.fromJson(Map<String, dynamic> json) => LanguagesResponse(
        languages: (json['languages'] as List? ?? const [])
            .map((e) => KmLanguage.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
