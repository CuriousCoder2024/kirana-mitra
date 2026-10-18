import 'package:flutter/foundation.dart';

/// Reported with feedback. Keep in step with pubspec.yaml `version`.
const String kAppVersion = '1.0.0+1';

String get kPlatformName {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'other',
  };
}
