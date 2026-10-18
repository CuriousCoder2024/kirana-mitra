// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'دکان کا نام';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'آپ کا نام';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'شروع کریں';

  @override
  String get requiredField => 'براہ کرم یہ لکھیں';

  @override
  String get navChat => 'بات';

  @override
  String get navStock => 'اسٹاک';

  @override
  String get navUdhaar => 'ادھار';

  @override
  String get navForecast => 'اندازہ';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'ڈیمو';

  @override
  String get changeShop => 'دکان بدلیں';

  @override
  String welcomeMessage(String name) {
    return 'سلام $name! بتائیں کیا آیا، کیا بکا، یا کس کو ادھار دیا۔ مائیک دبا کر بولیں۔';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'سلام $name! بولیں: کیا آیا، کیا بکا، کس کو ادھار دیا۔ مائیک دبا کر بولیں۔';
  }

  @override
  String get recordingCancelled => 'چھوڑ دیا، کینسل ہو گیا';

  @override
  String get voiceTooShort => 'تھوڑی دیر دبا کر بولیں';

  @override
  String get micPermissionDenied =>
      'وائس نوٹ کے لیے مائیکروفون کی اجازت چاہیے۔';

  @override
  String get voiceNoteSent => '🎤 وائس نوٹ';

  @override
  String get photoSent => '📷 شیلف کی تصویر';

  @override
  String get typeMessageHint => 'یہاں لکھیں…';

  @override
  String get send => 'بھیجیں';

  @override
  String get thinking => 'سوچ رہا ہوں…';

  @override
  String get networkError => 'سرور سے رابطہ نہ ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get comingSoon => 'جلد آ رہا ہے! شیلف اسکین جلد دستیاب ہوگا۔';

  @override
  String get scanFailed => 'تصویر سمجھ نہیں آئی، دوبارہ کوشش کریں۔';

  @override
  String get imageTooLarge =>
      'تصویر بہت بڑی ہے (8 MB سے زیادہ)۔ چھوٹی تصویر لیں۔';

  @override
  String get stockTitle => 'اسٹاک';

  @override
  String get lowStockBadge => 'کم ہے';

  @override
  String reorderAt(String level) {
    return '$level پر منگوائیں';
  }

  @override
  String get emptyStock => 'ابھی اسٹاک نہیں ہے۔ بتائیں کیا آیا۔';

  @override
  String get udhaarTitle => 'ادھار';

  @override
  String get totalOutstanding => 'کل باقی';

  @override
  String get emptyLedger =>
      'ابھی کوئی ادھار نہیں۔ بولیں \"گپتا جی کو 350 کا ادھار دیا\"۔';

  @override
  String get forecastTitle => 'اندازہ';

  @override
  String get legendHistory => 'پچھلے ہفتے';

  @override
  String get legendForecast => 'اندازہ';

  @override
  String get legendBand => 'رینج';

  @override
  String get orderReady => 'آرڈر تیار ہے';

  @override
  String get shareWhatsapp => 'WhatsApp پر بھیجیں';

  @override
  String get copied => 'کاپی ہو گیا';

  @override
  String get copy => 'کاپی';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get loading => 'لوڈ ہو رہا ہے…';

  @override
  String get errorLoading => 'لوڈ نہیں ہو سکا۔ نیچے کھینچ کر دوبارہ کوشش کریں۔';

  @override
  String get tagline => 'بولیں، ہو جائے گا۔';

  @override
  String get languageQuestion => 'Mitra کس زبان میں بولے؟';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'یہ بھریں';

  @override
  String get dockPhoto => 'شیلف کی تصویر';

  @override
  String get dockType => 'لکھیں';

  @override
  String get micLabel => 'دبا کر بولیں';

  @override
  String get recordingLabel => 'سن رہا ہوں… چھوڑیں گے تو جائے گا';

  @override
  String get recordingCancelHint => 'کینسل کے لیے انگلی باہر سرکائیں';

  @override
  String get confirmHeader => 'سمجھ گیا · لکھ دیا';

  @override
  String get confirmTotalUdhaar => 'ادھار · اب کل';

  @override
  String get confirmTotalStock => 'اسٹاک · اب کل';

  @override
  String get confirmTotalSale => 'بکری · آج کل';

  @override
  String get askHeader => 'پکا نہیں';

  @override
  String askHeard(String text) {
    return 'آپ نے کہا “$text”';
  }

  @override
  String get askStock => 'اسٹاک میں جوڑوں؟';

  @override
  String get askUdhaar => 'ادھار میں لکھوں؟';

  @override
  String get askSale => 'بکری میں لکھوں؟';

  @override
  String get askNo => 'نہیں';

  @override
  String get askDeclined => 'ٹھیک ہے، نہیں لکھا۔';

  @override
  String scanHeader(int count) {
    return 'شیلف دیکھا · $count چیزیں ملیں';
  }

  @override
  String get scanQuestion => 'اسٹاک یہی سیٹ کر دوں؟';

  @override
  String get scanConfirmed => 'سمجھ گیا · اسٹاک اپ ڈیٹ ہو گیا';

  @override
  String stockSubtitle(int count, String time) {
    return '$count چیزیں · اپ ڈیٹ $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count چیزیں کم ہیں',
      one: '1 چیز کم ہے',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'سب ٹھیک ہے';

  @override
  String get orderButton => 'آرڈر بنائیں';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'آرڈر بنائیں · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count لوگ · کھاتہ';
  }

  @override
  String get balanceLabel => 'باقی';

  @override
  String todayGiven(String amount) {
    return 'آج دیا +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'آج آیا −₹$amount';
  }

  @override
  String get owedCaption => 'باقی';

  @override
  String get settledBadge => 'چکتا';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount آیا';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'ادھار شروع $date · $count اندراجات';
  }

  @override
  String lastEntryAt(String time) {
    return 'آخری: $time';
  }

  @override
  String get remindButton => 'یاد دلائیں';

  @override
  String get paidButton => 'پیسہ آیا';

  @override
  String get paidPrompt => 'کتنا آیا؟ بولیں۔';

  @override
  String get historyLabel => 'ہسٹری';

  @override
  String get entryGiven => 'ادھار لیا';

  @override
  String get entryPaid => 'پیسہ آیا';

  @override
  String get entrySourceVoice => 'آواز';

  @override
  String get entrySourceCash => 'نقد';

  @override
  String get entrySourcePhoto => 'تصویر';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'سلام $name جی، $shop سے۔ آپ کا ₹$balance باقی ہے۔ شکریہ!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'اگلے 4 ہفتے · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'اگلے 4 ہفتے';

  @override
  String perWeek(String unit) {
    return '$unit / ہفتہ';
  }

  @override
  String get forecastFuture => 'آگے · اندازہ';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'اسٹاک میں $onHand · منگوائیں $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count چیزیں';
  }

  @override
  String get share => 'شیئر کریں';

  @override
  String get hisaabTitle => 'آج کا حساب';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count اندراجات';
  }

  @override
  String hisaabDayChip(String time) {
    return 'دکان بند · $time';
  }

  @override
  String get hisaabSales => 'آج کی بکری';

  @override
  String get hisaabGiven => 'ادھار دیا';

  @override
  String get hisaabReceived => 'ادھار آیا';

  @override
  String get hisaabOutstanding => 'کل باقی';

  @override
  String get hisaabLow => 'کم ہے';

  @override
  String hisaabLowItems(String items) {
    return '$items کل منگوائیں۔';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival میں $weeks ہفتے باقی ہیں۔';
  }

  @override
  String get hisaabOrderButton => 'کل کا آرڈر بنائیں';

  @override
  String get hisaabShareButton => 'گھر پر WhatsApp کریں';

  @override
  String todayChip(String date) {
    return 'آج · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'کل · $date';
  }

  @override
  String get demoNotice => 'سرور نہیں ملا۔ ڈیمو موڈ میں شروع کر رہا ہوں۔';

  @override
  String get languageSheetTitle => 'Mitra کس زبان میں بولے؟';

  @override
  String get backLabel => 'پیچھے';

  @override
  String get voiceNoteLabel => 'وائس نوٹ';

  @override
  String get undo => 'واپس لیں';

  @override
  String get feedbackButton => 'رائے';

  @override
  String get feedbackTitle => 'Kirana Mitra کیسا چل رہا ہے؟';

  @override
  String get feedbackUp => 'اچھا';

  @override
  String get feedbackDown => 'ٹھیک نہیں';

  @override
  String get feedbackCommentHint => 'کچھ اور بتانا ہو تو لکھیں…';

  @override
  String get feedbackVoiceHint => 'یا دبا کر بولیں';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'آواز تیار ہے · ${seconds}s';
  }

  @override
  String get feedbackSend => 'بھیجیں';

  @override
  String get feedbackPickRating => 'پہلے اچھا یا ٹھیک نہیں منتخب کریں';

  @override
  String get feedbackThanks => 'شکریہ!';

  @override
  String get changeLanguage => 'زبان بدلیں';

  @override
  String get languageSearchHint => 'زبان تلاش کریں…';

  @override
  String get languageNoMatch => 'کوئی زبان نہیں ملی';

  @override
  String get topSellersTitle => 'ٹاپ سیلرز';

  @override
  String get topSellersSubtitle => 'پچھلے 2 ہفتے · اگلے 2 ہفتے کا اندازہ';

  @override
  String get autoBadge => 'آٹو';

  @override
  String coverDays(String days) {
    return '$days دن کا اسٹاک';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 ہفتے';
  }

  @override
  String get autoRestockTitle => 'ٹاپ سیلرز آٹو ری اسٹاک';

  @override
  String get autoRestockSubtitle =>
      'کم اسٹاک والے ٹاپ سیلرز کا آرڈر رات کو خود بخود جائے گا';

  @override
  String get distributorPhoneLabel => 'ڈسٹری بیوٹر کا WhatsApp نمبر';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get settingsSaved => 'محفوظ ہو گیا';

  @override
  String get ordersTitle => 'آرڈرز';

  @override
  String get ordersEmpty => 'ابھی کوئی آرڈر نہیں۔ اندازہ سے آرڈر بنائیں۔';

  @override
  String get orderAuto => 'آٹو';

  @override
  String get orderManual => 'مینول';

  @override
  String get orderPlaced => 'بھیج دیا';

  @override
  String get orderCancelled => 'کینسل ہو گیا';

  @override
  String get viewOrders => 'آرڈرز دیکھیں';

  @override
  String get newOrdersNotice => 'رات کا آٹو آرڈر آیا';
}
