// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'ਦੁਕਾਨ ਦਾ ਨਾਂ';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'ਤੁਹਾਡਾ ਨਾਂ';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get requiredField => 'ਕਿਰਪਾ ਕਰਕੇ ਇਹ ਭਰੋ';

  @override
  String get navChat => 'ਗੱਲਬਾਤ';

  @override
  String get navStock => 'ਸਟਾਕ';

  @override
  String get navUdhaar => 'ਉਧਾਰ';

  @override
  String get navForecast => 'ਅੰਦਾਜ਼ਾ';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'ਡੈਮੋ';

  @override
  String get changeShop => 'ਦੁਕਾਨ ਬਦਲੋ';

  @override
  String welcomeMessage(String name) {
    return 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ $name! ਦੱਸੋ ਕੀ ਆਇਆ, ਕੀ ਵਿਕਿਆ, ਜਾਂ ਕਿਸਨੇ ਉਧਾਰ ਲਿਆ। ਮਾਈਕ ਦੱਬ ਕੇ ਬੋਲੋ।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ $name! ਬੋਲੋ: ਕੀ ਆਇਆ, ਕੀ ਵਿਕਿਆ, ਕਿਸਨੂੰ ਉਧਾਰ ਦਿੱਤਾ। ਮਾਈਕ ਦੱਬ ਕੇ ਰੱਖੋ ਤੇ ਬੋਲੋ।';
  }

  @override
  String get recordingCancelled => 'ਛੱਡ ਦਿੱਤਾ, ਕੈਂਸਲ ਹੋ ਗਿਆ';

  @override
  String get voiceTooShort => 'ਥੋੜ੍ਹਾ ਹੋਰ ਦੱਬ ਕੇ ਬੋਲੋ';

  @override
  String get micPermissionDenied =>
      'ਵੌਇਸ ਨੋਟ ਲਈ ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਦੀ ਮਨਜ਼ੂਰੀ ਚਾਹੀਦੀ ਹੈ।';

  @override
  String get voiceNoteSent => '🎤 ਵੌਇਸ ਨੋਟ';

  @override
  String get photoSent => '📷 ਸ਼ੈਲਫ਼ ਦੀ ਫ਼ੋਟੋ';

  @override
  String get typeMessageHint => 'ਇੱਥੇ ਲਿਖੋ…';

  @override
  String get send => 'ਭੇਜੋ';

  @override
  String get thinking => 'ਸੋਚ ਰਿਹਾ ਹਾਂ…';

  @override
  String get networkError => 'ਸਰਵਰ ਨਾਲ ਜੁੜ ਨਹੀਂ ਸਕਿਆ। ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get comingSoon => 'ਛੇਤੀ ਆ ਰਿਹਾ ਹੈ! ਸ਼ੈਲਫ਼ ਸਕੈਨ ਜਲਦ ਆਵੇਗਾ।';

  @override
  String get scanFailed => 'ਫ਼ੋਟੋ ਸਮਝ ਨਹੀਂ ਆਈ, ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get imageTooLarge =>
      'ਫ਼ੋਟੋ ਬਹੁਤ ਵੱਡੀ ਹੈ (8 MB ਤੋਂ ਵੱਧ)। ਛੋਟੀ ਫ਼ੋਟੋ ਲਵੋ।';

  @override
  String get stockTitle => 'ਸਟਾਕ';

  @override
  String get lowStockBadge => 'ਘੱਟ ਹੈ';

  @override
  String reorderAt(String level) {
    return '$level \'ਤੇ ਮੁੜ ਮੰਗਾਓ';
  }

  @override
  String get emptyStock => 'ਅਜੇ ਕੋਈ ਸਟਾਕ ਨਹੀਂ ਹੈ। ਬੋਲੋ ਕੀ ਆਇਆ।';

  @override
  String get udhaarTitle => 'ਉਧਾਰ';

  @override
  String get totalOutstanding => 'ਕੁੱਲ ਬਾਕੀ';

  @override
  String get emptyLedger =>
      'ਅਜੇ ਕੋਈ ਉਧਾਰ ਨਹੀਂ। ਬੋਲੋ \"ਗੁਪਤਾ ਜੀ ਨੂੰ 350 ਦਾ ਉਧਾਰ ਦਿੱਤਾ\"।';

  @override
  String get forecastTitle => 'ਅੰਦਾਜ਼ਾ';

  @override
  String get legendHistory => 'ਪਿਛਲੇ ਹਫ਼ਤੇ';

  @override
  String get legendForecast => 'ਅੰਦਾਜ਼ਾ';

  @override
  String get legendBand => 'ਰੇਂਜ';

  @override
  String get orderReady => 'ਆਰਡਰ ਤਿਆਰ';

  @override
  String get shareWhatsapp => 'WhatsApp \'ਤੇ ਭੇਜੋ';

  @override
  String get copied => 'ਕਾਪੀ ਹੋ ਗਿਆ';

  @override
  String get copy => 'ਕਾਪੀ';

  @override
  String get retry => 'ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get loading => 'ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get errorLoading => 'ਲੋਡ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਰੀਫ੍ਰੈਸ਼ ਕਰਨ ਲਈ ਹੇਠਾਂ ਖਿੱਚੋ।';

  @override
  String get tagline => 'ਬੋਲੋ, ਹੋ ਜਾਵੇਗਾ।';

  @override
  String get languageQuestion => 'ਮਿੱਤਰ ਕਿਸ ਭਾਸ਼ਾ ਵਿੱਚ ਬੋਲੇ?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'ਇਹ ਭਰੋ';

  @override
  String get dockPhoto => 'ਸ਼ੈਲਫ਼ ਫ਼ੋਟੋ';

  @override
  String get dockType => 'ਲਿਖੋ';

  @override
  String get micLabel => 'ਦੱਬ ਕੇ ਬੋਲੋ';

  @override
  String get recordingLabel => 'ਸੁਣ ਰਿਹਾ ਹਾਂ… ਛੱਡੋਗੇ ਤਾਂ ਭੇਜ ਦਿੱਤਾ ਜਾਵੇਗਾ';

  @override
  String get recordingCancelHint => 'ਕੈਂਸਲ ਕਰਨ ਲਈ ਉਂਗਲ ਬਾਹਰ ਖਿੱਚੋ';

  @override
  String get confirmHeader => 'ਸਮਝ ਗਿਆ · ਲਿਖ ਲਿਆ';

  @override
  String get confirmTotalUdhaar => 'ਉਧਾਰ · ਹੁਣ ਕੁੱਲ';

  @override
  String get confirmTotalStock => 'ਸਟਾਕ · ਹੁਣ ਕੁੱਲ';

  @override
  String get confirmTotalSale => 'ਵਿਕਰੀ · ਅੱਜ ਕੁੱਲ';

  @override
  String get askHeader => 'ਪੱਕਾ ਨਹੀਂ';

  @override
  String askHeard(String text) {
    return 'ਤੁਸੀਂ ਕਿਹਾ “$text”';
  }

  @override
  String get askStock => 'ਸਟਾਕ ਵਿੱਚ ਜੋੜਾਂ?';

  @override
  String get askUdhaar => 'ਉਧਾਰ ਵਿੱਚ ਲਿਖਾਂ?';

  @override
  String get askSale => 'ਵਿਕਰੀ ਵਿੱਚ ਲਿਖਾਂ?';

  @override
  String get askNo => 'ਨਹੀਂ';

  @override
  String get askDeclined => 'ਠੀਕ ਹੈ, ਨਹੀਂ ਲਿਖਿਆ।';

  @override
  String scanHeader(int count) {
    return 'ਸ਼ੈਲਫ਼ ਦੇਖੀ · $count ਚੀਜ਼ਾਂ ਮਿਲੀਆਂ';
  }

  @override
  String get scanQuestion => 'ਸਟਾਕ ਇਹੋ ਸੈੱਟ ਕਰ ਦੇਵਾਂ?';

  @override
  String get scanConfirmed => 'ਸਮਝ ਗਿਆ · ਸਟਾਕ ਅੱਪਡੇਟ ਹੋ ਗਿਆ';

  @override
  String stockSubtitle(int count, String time) {
    return '$count ਚੀਜ਼ਾਂ · ਅੱਪਡੇਟ $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਚੀਜ਼ਾਂ ਘੱਟ ਹਨ',
      one: '1 ਚੀਜ਼ ਘੱਟ ਹੈ',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'ਸਭ ਠੀਕ ਹੈ';

  @override
  String get orderButton => 'ਆਰਡਰ ਬਣਾਓ';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ਆਰਡਰ ਬਣਾਓ · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count ਗਾਹਕ · ਬਹੀ-ਖਾਤਾ';
  }

  @override
  String get balanceLabel => 'ਬਾਕੀ';

  @override
  String todayGiven(String amount) {
    return 'ਅੱਜ ਦਿੱਤਾ +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'ਅੱਜ ਆਇਆ −₹$amount';
  }

  @override
  String get owedCaption => 'ਬਾਕੀ';

  @override
  String get settledBadge => 'ਚੁਕਤਾ';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount ਆਇਆ';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'ਉਧਾਰ ਸ਼ੁਰੂ $date · $count ਐਂਟਰੀਆਂ';
  }

  @override
  String lastEntryAt(String time) {
    return 'ਆਖ਼ਰੀ: $time';
  }

  @override
  String get remindButton => 'ਯਾਦ ਦਿਵਾਓ';

  @override
  String get paidButton => 'ਪੈਸੇ ਆਏ';

  @override
  String get paidPrompt => 'ਕਿੰਨੇ ਆਏ? ਬੋਲੋ।';

  @override
  String get historyLabel => 'ਹਿਸਟਰੀ';

  @override
  String get entryGiven => 'ਉਧਾਰ ਲਿਆ';

  @override
  String get entryPaid => 'ਪੈਸੇ ਆਏ';

  @override
  String get entrySourceVoice => 'ਆਵਾਜ਼';

  @override
  String get entrySourceCash => 'ਨਕਦ';

  @override
  String get entrySourcePhoto => 'ਫ਼ੋਟੋ';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ $name ਜੀ, $shop ਵੱਲੋਂ। ਤੁਹਾਡੇ ₹$balance ਬਾਕੀ ਹਨ। ਧੰਨਵਾਦ!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'ਅਗਲੇ 4 ਹਫ਼ਤੇ · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'ਅਗਲੇ 4 ਹਫ਼ਤੇ';

  @override
  String perWeek(String unit) {
    return '$unit / ਹਫ਼ਤਾ';
  }

  @override
  String get forecastFuture => 'ਅੱਗੇ · ਅੰਦਾਜ਼ਾ';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'ਸਟਾਕ ਵਿੱਚ $onHand · ਮੰਗਾਓ $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count ਚੀਜ਼ਾਂ';
  }

  @override
  String get share => 'ਸ਼ੇਅਰ ਕਰੋ';

  @override
  String get hisaabTitle => 'ਅੱਜ ਦਾ ਹਿਸਾਬ';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count ਐਂਟਰੀਆਂ';
  }

  @override
  String hisaabDayChip(String time) {
    return 'ਦੁਕਾਨ ਬੰਦ · $time';
  }

  @override
  String get hisaabSales => 'ਅੱਜ ਦੀ ਵਿਕਰੀ';

  @override
  String get hisaabGiven => 'ਉਧਾਰ ਦਿੱਤਾ';

  @override
  String get hisaabReceived => 'ਉਧਾਰ ਆਇਆ';

  @override
  String get hisaabOutstanding => 'ਕੁੱਲ ਬਾਕੀ';

  @override
  String get hisaabLow => 'ਘੱਟ ਹੈ';

  @override
  String hisaabLowItems(String items) {
    return '$items ਕੱਲ੍ਹ ਮੰਗਾਓ।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks ਹਫ਼ਤੇ ਦੂਰ ਹੈ।';
  }

  @override
  String get hisaabOrderButton => 'ਕੱਲ੍ਹ ਦਾ ਆਰਡਰ ਬਣਾਓ';

  @override
  String get hisaabShareButton => 'ਘਰ WhatsApp ਕਰੋ';

  @override
  String todayChip(String date) {
    return 'ਅੱਜ · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'ਕੱਲ੍ਹ · $date';
  }

  @override
  String get demoNotice => 'ਸਰਵਰ ਨਹੀਂ ਮਿਲਿਆ। ਡੈਮੋ ਮੋਡ ਵਿੱਚ ਸ਼ੁਰੂ ਕਰ ਰਿਹਾ ਹਾਂ।';

  @override
  String get languageSheetTitle => 'ਮਿੱਤਰ ਕਿਸ ਭਾਸ਼ਾ ਵਿੱਚ ਬੋਲੇ?';

  @override
  String get backLabel => 'ਪਿੱਛੇ';

  @override
  String get voiceNoteLabel => 'ਵੌਇਸ ਨੋਟ';

  @override
  String get undo => 'ਵਾਪਸ';

  @override
  String get feedbackButton => 'ਫੀਡਬੈਕ';

  @override
  String get feedbackTitle => 'Kirana Mitra ਕਿਵੇਂ ਚੱਲ ਰਿਹਾ ਹੈ?';

  @override
  String get feedbackUp => 'ਵਧੀਆ';

  @override
  String get feedbackDown => 'ਠੀਕ ਨਹੀਂ';

  @override
  String get feedbackCommentHint => 'ਕੁਝ ਹੋਰ ਦੱਸਣਾ ਹੋਵੇ ਤਾਂ ਲਿਖੋ…';

  @override
  String get feedbackVoiceHint => 'ਜਾਂ ਦੱਬ ਕੇ ਬੋਲੋ';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'ਆਵਾਜ਼ ਤਿਆਰ · $seconds ਸਕਿੰਟ';
  }

  @override
  String get feedbackSend => 'ਭੇਜੋ';

  @override
  String get feedbackPickRating => 'ਪਹਿਲਾਂ ਵਧੀਆ ਜਾਂ ਠੀਕ ਨਹੀਂ ਚੁਣੋ';

  @override
  String get feedbackThanks => 'ਧੰਨਵਾਦ!';

  @override
  String get changeLanguage => 'ਭਾਸ਼ਾ ਬਦਲੋ';

  @override
  String get languageSearchHint => 'ਭਾਸ਼ਾ ਲੱਭੋ…';

  @override
  String get languageNoMatch => 'ਕੋਈ ਭਾਸ਼ਾ ਨਹੀਂ ਮਿਲੀ';

  @override
  String get topSellersTitle => 'ਸਭ ਤੋਂ ਵੱਧ ਵਿਕਣ ਵਾਲਾ';

  @override
  String get topSellersSubtitle => 'ਪਿਛਲੇ 2 ਹਫ਼ਤੇ · ਅਗਲੇ 2 ਹਫ਼ਤਿਆਂ ਦਾ ਅੰਦਾਜ਼ਾ';

  @override
  String get autoBadge => 'ਆਟੋ';

  @override
  String coverDays(String days) {
    return '$days ਦਿਨਾਂ ਦਾ ਸਟਾਕ';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 ਹਫ਼ਤੇ';
  }

  @override
  String get autoRestockTitle => 'ਵੱਧ ਵਿਕਣ ਵਾਲੀਆਂ ਚੀਜ਼ਾਂ ਆਟੋ-ਮੰਗਾਓ';

  @override
  String get autoRestockSubtitle =>
      'ਘੱਟ ਸਟਾਕ ਵਾਲੀਆਂ ਜ਼ਿਆਦਾ ਵਿਕਣ ਵਾਲੀਆਂ ਚੀਜ਼ਾਂ ਦਾ ਆਰਡਰ ਰਾਤ ਨੂੰ ਆਪਣੇ ਆਪ ਜਾਵੇਗਾ';

  @override
  String get distributorPhoneLabel => 'ਡਿਸਟ੍ਰੀਬਿਊਟਰ ਦਾ WhatsApp ਨੰਬਰ';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'ਸੇਵ ਕਰੋ';

  @override
  String get settingsSaved => 'ਸੇਵ ਹੋ ਗਿਆ';

  @override
  String get ordersTitle => 'ਆਰਡਰ';

  @override
  String get ordersEmpty => 'ਅਜੇ ਕੋਈ ਆਰਡਰ ਨਹੀਂ। ਅੰਦਾਜ਼ੇ ਤੋਂ ਆਰਡਰ ਬਣਾਓ।';

  @override
  String get orderAuto => 'ਆਟੋ';

  @override
  String get orderManual => 'ਮੈਨੂਅਲ';

  @override
  String get orderPlaced => 'ਭੇਜ ਦਿੱਤਾ';

  @override
  String get orderCancelled => 'ਕੈਂਸਲ ਹੋ ਗਿਆ';

  @override
  String get viewOrders => 'ਆਰਡਰ ਦੇਖੋ';

  @override
  String get newOrdersNotice => 'ਰਾਤ ਦਾ ਆਟੋ ਆਰਡਰ ਆਇਆ';
}
