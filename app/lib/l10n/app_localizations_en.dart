// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get onboardingTitle => 'Set up your shop';

  @override
  String get onboardingSubtitle =>
      'Takes 20 seconds. You will never fill a form again.';

  @override
  String get shopNameLabel => 'Shop name';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'Your name';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get languageLabel => 'Reply language';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'Start';

  @override
  String get requiredField => 'Please fill this in';

  @override
  String get couldNotCreateShop =>
      'Could not reach the server. Starting in demo mode.';

  @override
  String get navChat => 'Chat';

  @override
  String get navStock => 'Stock';

  @override
  String get navUdhaar => 'Udhaar';

  @override
  String get navForecast => 'Forecast';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'Demo';

  @override
  String get changeShop => 'Change shop';

  @override
  String welcomeMessage(String name) {
    return 'Namaste $name! Tell me what came in, what sold, or who took udhaar. Hold the mic and speak.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'Namaste $name! Bolo: kya aaya, kya bika, kisko udhaar diya. Mic dabake rakho aur bolo.';
  }

  @override
  String get holdToTalk => 'Hold to talk';

  @override
  String get recording => 'Listening… release to send';

  @override
  String get slideToCancel => 'Slide away to cancel';

  @override
  String get recordingCancelled => 'Cancelled';

  @override
  String get voiceTooShort => 'Hold a bit longer and speak';

  @override
  String get micPermissionDenied =>
      'Microphone permission is needed for voice notes.';

  @override
  String get voiceNoteSent => '🎤 Voice note';

  @override
  String get photoSent => '📷 Shelf photo';

  @override
  String get typeMessageHint => 'Or type here…';

  @override
  String get send => 'Send';

  @override
  String get thinking => 'Thinking…';

  @override
  String get networkError => 'Couldn\'t reach the server. Try again.';

  @override
  String get comingSoon => 'Jaldi aa raha hai! Shelf scan is coming soon.';

  @override
  String get scanFailed => 'Photo samajh nahi aayi, phir se try karo.';

  @override
  String get imageTooLarge =>
      'Photo is too big (over 8 MB). Try a smaller one.';

  @override
  String get scanColItem => 'Item';

  @override
  String get scanColPack => 'Pack';

  @override
  String get scanColCount => 'Count';

  @override
  String get pickPhoto => 'Scan shelf photo';

  @override
  String get stockTitle => 'Stock';

  @override
  String get lowStockBadge => 'Kam hai';

  @override
  String reorderAt(String level) {
    return 'Reorder at $level';
  }

  @override
  String get emptyStock => 'No stock yet. Tell me what came in.';

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items low',
      one: '1 item low',
      zero: 'All good',
    );
    return '$_temp0';
  }

  @override
  String get udhaarTitle => 'Udhaar';

  @override
  String get totalOutstanding => 'Total outstanding';

  @override
  String customersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customers',
      one: '1 customer',
      zero: 'No customers',
    );
    return '$_temp0';
  }

  @override
  String lastEntry(String date) {
    return 'Last entry $date';
  }

  @override
  String get emptyLedger =>
      'No udhaar yet. Say \"Gupta ji ko 350 ka udhaar diya\".';

  @override
  String get forecastTitle => 'Forecast';

  @override
  String get legendHistory => 'Past weeks';

  @override
  String get legendForecast => 'Forecast';

  @override
  String get legendBand => 'Likely range';

  @override
  String onHand(String qty, String unit) {
    return 'On hand: $qty $unit';
  }

  @override
  String suggestedReorder(String qty, String unit) {
    return 'Suggested: $qty $unit';
  }

  @override
  String get reorderButton => 'Reorder';

  @override
  String get reorderPreparing => 'Preparing order…';

  @override
  String get orderReady => 'Order ready';

  @override
  String get shareWhatsapp => 'Send on WhatsApp';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading…';

  @override
  String get errorLoading => 'Couldn\'t load. Pull down to retry.';
}
