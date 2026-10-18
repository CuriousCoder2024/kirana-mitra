// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'ಅಂಗಡಿಯ ಹೆಸರು';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'ನಿಮ್ಮ ಹೆಸರು';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'ಶುರು ಮಾಡಿ';

  @override
  String get requiredField => 'ದಯವಿಟ್ಟು ಇದನ್ನು ಭರ್ತಿ ಮಾಡಿ';

  @override
  String get navChat => 'ಮಾತು';

  @override
  String get navStock => 'ಸ್ಟಾಕ್';

  @override
  String get navUdhaar => 'ಉದ್ದರಿ';

  @override
  String get navForecast => 'ಅಂದಾಜು';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'ಡೆಮೊ';

  @override
  String get changeShop => 'ಅಂಗಡಿ ಬದಲಾಯಿಸಿ';

  @override
  String welcomeMessage(String name) {
    return 'ನಮಸ್ಕಾರ $name! ಏನು ಬಂತು, ಏನು ಮಾರಾಟವಾಯ್ತು ಅಥವಾ ಯಾರು ಉದ್ದರಿ ತಗೊಂಡ್ರು ಹೇಳಿ. ಮೈಕ್ ಒತ್ತಿ ಹಿಡಿದು ಮಾತನಾಡಿ.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'ನಮಸ್ಕಾರ $name! ಏನು ಬಂತು, ಏನು ಮಾರಾಟವಾಯ್ತು, ಯಾರಿಗೆ ಉದ್ದರಿ ಕೊಟ್ರಿ ಹೇಳಿ. ಮೈಕ್ ಒತ್ತಿ ಹಿಡಿದು ಮಾತನಾಡಿ.';
  }

  @override
  String get recordingCancelled => 'ಬಿಟ್ಟುಬಿಡಿ, ಕ್ಯಾನ್ಸಲ್ ಆಯ್ತು';

  @override
  String get voiceTooShort => 'ಸ್ವಲ್ಪ ಹೊತ್ತು ಒತ್ತಿ ಹಿಡಿದು ಮಾತನಾಡಿ';

  @override
  String get micPermissionDenied => 'ವಾಯ್ಸ್ ನೋಟ್‌ಗಾಗಿ ಮೈಕ್ರೋಫೋನ್ ಅನುಮತಿ ಬೇಕು.';

  @override
  String get voiceNoteSent => '🎤 ವಾಯ್ಸ್ ನೋಟ್';

  @override
  String get photoSent => '📷 ಶೆಲ್ಫ್ ಫೋಟೋ';

  @override
  String get typeMessageHint => 'ಇಲ್ಲಿ ಬರೆಯಿರಿ…';

  @override
  String get send => 'ಕಳುಹಿಸಿ';

  @override
  String get thinking => 'ಯೋಚಿಸುತ್ತಿದೆ…';

  @override
  String get networkError => 'ಸರ್ವರ್ ಸಂಪರ್ಕ ಸಿಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get comingSoon => 'ಬೇಗ ಬರ್ತಿದೆ! ಶೆಲ್ಫ್ ಸ್ಕ್ಯಾನ್ ಸದ್ಯದಲ್ಲೇ ಬರಲಿದೆ.';

  @override
  String get scanFailed => 'ಫೋಟೋ ಅರ್ಥವಾಗಲಿಲ್ಲ, ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get imageTooLarge =>
      'ಫೋಟೋ ತುಂಬಾ ದೊಡ್ಡದಿದೆ (8 MB ಗಿಂತ ಹೆಚ್ಚು). ಸಣ್ಣ ಫೋಟೋ ಬಳಸಿ.';

  @override
  String get stockTitle => 'ಸ್ಟಾಕ್';

  @override
  String get lowStockBadge => 'ಕಡಿಮೆ ಇದೆ';

  @override
  String reorderAt(String level) {
    return '$level ತಲುಪಿದಾಗ ಆರ್ಡರ್ ಮಾಡಿ';
  }

  @override
  String get emptyStock => 'ಇನ್ನೂ ಸ್ಟಾಕ್ ಇಲ್ಲ. ಏನು ಬಂತು ಅಂತ ಹೇಳಿ.';

  @override
  String get udhaarTitle => 'ಉದ್ದರಿ';

  @override
  String get totalOutstanding => 'ಒಟ್ಟು ಬಾಕಿ';

  @override
  String get emptyLedger =>
      'ಯಾವುದೇ ಉದ್ದರಿ ಇಲ್ಲ. \"ಗುಪ್ತಾಜಿಗೆ 350 ಉದ್ದರಿ ಕೊಟ್ಟೆ\" ಅಂತ ಹೇಳಿ.';

  @override
  String get forecastTitle => 'ಅಂದಾಜು';

  @override
  String get legendHistory => 'ಕಳೆದ ವಾರ';

  @override
  String get legendForecast => 'ಅಂದಾಜು';

  @override
  String get legendBand => 'ವ್ಯಾಪ್ತಿ';

  @override
  String get orderReady => 'ಆರ್ಡರ್ ರೆಡಿ';

  @override
  String get shareWhatsapp => 'WhatsApp ನಲ್ಲಿ ಕಳಿಸಿ';

  @override
  String get copied => 'ಕಾಪಿ ಆಯ್ತು';

  @override
  String get copy => 'ಕಾಪಿ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get loading => 'ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get errorLoading => 'ಲೋಡ್ ಆಗಲಿಲ್ಲ. ಕೆಳಗೆ ಎಳೆದು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get tagline => 'ಹೇಳಿ ಸಾಕು, ಕೆಲಸ ಆಗುತ್ತೆ.';

  @override
  String get languageQuestion => 'ಮಿತ್ರ ಯಾವ ಭಾಷೆಯಲ್ಲಿ ಮಾತನಾಡಲಿ?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'ಇದನ್ನು ಭರ್ತಿ ಮಾಡಿ';

  @override
  String get dockPhoto => 'ಶೆಲ್ಫ್ ಫೋಟೋ';

  @override
  String get dockType => 'ಬರೆಯಿರಿ';

  @override
  String get micLabel => 'ಒತ್ತಿ ಮಾತನಾಡಿ';

  @override
  String get recordingLabel => 'ಕೇಳ್ತಾ ಇದ್ದೀನಿ… ಬಿಟ್ರೆ ಕಳುಹಿಸುತ್ತೆ';

  @override
  String get recordingCancelHint => 'ಕ್ಯಾನ್ಸಲ್ ಮಾಡಲು ಬೆರಳು ಹೊರಗೆ ಸರಿಸಿ';

  @override
  String get confirmHeader => 'ಅರ್ಥವಾಯ್ತು · ಬರೆದಾಯ್ತು';

  @override
  String get confirmTotalUdhaar => 'ಉದ್ದರಿ · ಈಗಿನ ಒಟ್ಟು';

  @override
  String get confirmTotalStock => 'ಸ್ಟಾಕ್ · ಈಗಿನ ಒಟ್ಟು';

  @override
  String get confirmTotalSale => 'ಮಾರಾಟ · ಇಂದಿನ ಒಟ್ಟು';

  @override
  String get askHeader => 'ಖಚಿತವಿಲ್ಲ';

  @override
  String askHeard(String text) {
    return 'ನೀವು “$text” ಎಂದಿರಿ';
  }

  @override
  String get askStock => 'ಸ್ಟಾಕ್‌ಗೆ ಸೇರಿಸಲೇ?';

  @override
  String get askUdhaar => 'ಉದ್ದರಿಯಲ್ಲಿ ಬರೆಯಲೇ?';

  @override
  String get askSale => 'ಮಾರಾಟದಲ್ಲಿ ಬರೆಯಲೇ?';

  @override
  String get askNo => 'ಬೇಡ';

  @override
  String get askDeclined => 'ಸರಿ, ಬರೆದಿಲ್ಲ.';

  @override
  String scanHeader(int count) {
    return 'ಶೆಲ್ಫ್ ನೋಡಿದೆ · $count ಐಟಂಗಳು ಸಿಕ್ಕವು';
  }

  @override
  String get scanQuestion => 'ಸ್ಟಾಕ್ ಹೀಗೇ ಸೆಟ್ ಮಾಡಲೇ?';

  @override
  String get scanConfirmed => 'ಅರ್ಥವಾಯ್ತು · ಸ್ಟಾಕ್ ಅಪ್ಡೇಟ್ ಆಯ್ತು';

  @override
  String stockSubtitle(int count, String time) {
    return '$count ಐಟಂಗಳು · ಅಪ್ಡೇಟ್ $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಐಟಂಗಳು ಕಡಿಮೆ ಇವೆ',
      one: '1 ಐಟಂ ಕಡಿಮೆ ಇದೆ',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'ಎಲ್ಲ ಸರಿಯಾಗಿದೆ';

  @override
  String get orderButton => 'ಆರ್ಡರ್ ಮಾಡಿ';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ಆರ್ಡರ್ ಮಾಡಿ · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count ಜನ · ಲೆಕ್ಕದ ಪುಸ್ತಕ';
  }

  @override
  String get balanceLabel => 'ಬಾಕಿ';

  @override
  String todayGiven(String amount) {
    return 'ಇಂದು ಕೊಟ್ಟಿದ್ದು +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'ಇಂದು ಬಂದಿದ್ದು −₹$amount';
  }

  @override
  String get owedCaption => 'ಬಾಕಿ';

  @override
  String get settledBadge => 'ಚುಕ್ತಾ';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount ಬಂತು';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'ಉದ್ದರಿ ಶುರು $date · $count ನಮೂದುಗಳು';
  }

  @override
  String lastEntryAt(String time) {
    return 'ಕೊನೆಯದ್ದು: $time';
  }

  @override
  String get remindButton => 'ನೆನಪಿಸಿ';

  @override
  String get paidButton => 'ಹಣ ಬಂತು';

  @override
  String get paidPrompt => 'ಎಷ್ಟು ಬಂತು? ಹೇಳಿ.';

  @override
  String get historyLabel => 'ಹಿಂದಿನ ವಿವರ';

  @override
  String get entryGiven => 'ಉದ್ದರಿ ಕೊಟ್ಟಿದ್ದು';

  @override
  String get entryPaid => 'ಹಣ ಬಂತು';

  @override
  String get entrySourceVoice => 'ಧ್ವನಿ';

  @override
  String get entrySourceCash => 'ನಗದು';

  @override
  String get entrySourcePhoto => 'ಫೋಟೋ';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'ನಮಸ್ಕಾರ $name ಅವರೇ, $shop ಕಡೆಯಿಂದ. ನಿಮ್ಮ ₹$balance ಬಾಕಿ ಇದೆ. ಧನ್ಯವಾದಗಳು!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'ಮುಂದಿನ 4 ವಾರ · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'ಮುಂದಿನ 4 ವಾರ';

  @override
  String perWeek(String unit) {
    return '$unit / ವಾರ';
  }

  @override
  String get forecastFuture => 'ಮುಂದೆ · ಅಂದಾಜು';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'ಸ್ಟಾಕ್‌ನಲ್ಲಿ $onHand ಇದೆ · $qty $unit ತರಿಸಿ';
  }

  @override
  String orderItemCount(int count) {
    return '$count ಐಟಂಗಳು';
  }

  @override
  String get share => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get hisaabTitle => 'ಇಂದಿನ ಲೆಕ್ಕ';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count ನಮೂದುಗಳು';
  }

  @override
  String hisaabDayChip(String time) {
    return 'ಅಂಗಡಿ ಮುಚ್ಚಿದ್ದು · $time';
  }

  @override
  String get hisaabSales => 'ಇಂದಿನ ಮಾರಾಟ';

  @override
  String get hisaabGiven => 'ಉದ್ದರಿ ಕೊಟ್ಟಿದ್ದು';

  @override
  String get hisaabReceived => 'ಉದ್ದರಿ ವಸೂಲಿ';

  @override
  String get hisaabOutstanding => 'ಒಟ್ಟು ಬಾಕಿ';

  @override
  String get hisaabLow => 'ಕಡಿಮೆ ಇದೆ';

  @override
  String hisaabLowItems(String items) {
    return '$items ನಾಳೆ ತರಿಸಿ.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival ಹಬ್ಬಕ್ಕೆ $weeks ವಾರ ಬಾಕಿ ಇದೆ.';
  }

  @override
  String get hisaabOrderButton => 'ನಾಳಿನ ಆರ್ಡರ್ ಮಾಡಿ';

  @override
  String get hisaabShareButton => 'ಮನೆಗೆ WhatsApp ಮಾಡಿ';

  @override
  String todayChip(String date) {
    return 'ಇಂದು · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'ನಿನ್ನೆ · $date';
  }

  @override
  String get demoNotice => 'ಸರ್ವರ್ ಸಿಗಲಿಲ್ಲ. ಡೆಮೊ ಮೋಡ್‌ನಲ್ಲಿ ಶುರುವಾಗುತ್ತಿದೆ.';

  @override
  String get languageSheetTitle => 'ಮಿತ್ರ ಯಾವ ಭಾಷೆಯಲ್ಲಿ ಮಾತನಾಡಲಿ?';

  @override
  String get backLabel => 'ಹಿಂದಕ್ಕೆ';

  @override
  String get voiceNoteLabel => 'ವಾಯ್ಸ್ ನೋಟ್';

  @override
  String get undo => 'ರದ್ದುಮಾಡಿ';

  @override
  String get feedbackButton => 'ಅಭಿಪ್ರಾಯ';

  @override
  String get feedbackTitle => 'Kirana Mitra ಹೇಗೆ ನಡೀತಿದೆ?';

  @override
  String get feedbackUp => 'ಚೆನ್ನಾಗಿದೆ';

  @override
  String get feedbackDown => 'ಸರಿಯಿಲ್ಲ';

  @override
  String get feedbackCommentHint => 'ಇನ್ನೇನಾದರೂ ಹೇಳುವುದಿದ್ದರೆ ಬರೆಯಿರಿ…';

  @override
  String get feedbackVoiceHint => 'ಅಥವಾ ಒತ್ತಿ ಮಾತನಾಡಿ';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'ಧ್ವನಿ ಸಿದ್ಧವಾಗಿದೆ · $secondsಸೆ';
  }

  @override
  String get feedbackSend => 'ಕಳುಹಿಸಿ';

  @override
  String get feedbackPickRating => 'ಮೊದಲು ಚೆನ್ನಾಗಿದೆ ಅಥವಾ ಸರಿಯಿಲ್ಲ ಎಂದು ಆರಿಸಿ';

  @override
  String get feedbackThanks => 'ಧನ್ಯವಾದಗಳು!';

  @override
  String get changeLanguage => 'ಭಾಷೆ ಬದಲಾಯಿಸಿ';

  @override
  String get languageSearchHint => 'ಭಾಷೆ ಹುಡುಕಿ…';

  @override
  String get languageNoMatch => 'ಯಾವ ಭಾಷೆಯೂ ಸಿಗಲಿಲ್ಲ';

  @override
  String get topSellersTitle => 'ಹೆಚ್ಚು ಮಾರಾಟವಾದವು';

  @override
  String get topSellersSubtitle => 'ಕಳೆದ 2 ವಾರ · ಮುಂದಿನ 2 ವಾರದ ಅಂದಾಜು';

  @override
  String get autoBadge => 'ಆಟೋ';

  @override
  String coverDays(String days) {
    return '$days ದಿನದ ಸ್ಟಾಕ್';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 ವಾರ';
  }

  @override
  String get autoRestockTitle => 'ಟಾಪ್ ಸರಕುಗಳ ಆಟೋ-ರೀಸ್ಟಾಕ್';

  @override
  String get autoRestockSubtitle =>
      'ಕಡಿಮೆ ಸ್ಟಾಕ್ ಇರುವ ಟಾಪ್ ಸರಕುಗಳ ಆರ್ಡರ್ ರಾತ್ರಿ ತಾನಾಗಿಯೇ ಹೋಗುತ್ತದೆ';

  @override
  String get distributorPhoneLabel => 'ಡಿಸ್ಟ್ರಿಬ್ಯೂಟರ್ WhatsApp ನಂಬರ್';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get settingsSaved => 'ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get ordersTitle => 'ಆರ್ಡರ್‌ಗಳು';

  @override
  String get ordersEmpty => 'ಯಾವುದೇ ಆರ್ಡರ್ ಇಲ್ಲ. ಅಂದಾಜಿನಿಂದ ಆರ್ಡರ್ ಮಾಡಿ.';

  @override
  String get orderAuto => 'ಆಟೋ';

  @override
  String get orderManual => 'ಮ್ಯಾನುವಲ್';

  @override
  String get orderPlaced => 'ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get orderCancelled => 'ಕ್ಯಾನ್ಸಲ್ ಆಗಿದೆ';

  @override
  String get viewOrders => 'ಆರ್ಡರ್‌ಗಳನ್ನು ನೋಡಿ';

  @override
  String get newOrdersNotice => 'ರಾತ್ರಿಯ ಆಟೋ ಆರ್ಡರ್ ಬಂದಿದೆ';

  @override
  String get shopReRegistered =>
      'Server restart hua, dukaan phir se register ki.';

  @override
  String get imageCredits => 'Image credits';

  @override
  String get sampleShelf => 'Sample shelf';

  @override
  String get takePhoto => 'Camera';

  @override
  String get sampleShelfTitle => 'Sample shelf';

  @override
  String get sampleShelfHint =>
      'Koi ek shelf chuno; photo waise hi scan hogi jaise camera se.';
}
