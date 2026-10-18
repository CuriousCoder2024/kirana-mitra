// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sindhi (`sd`).
class AppLocalizationsSd extends AppLocalizations {
  AppLocalizationsSd([String locale = 'sd']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'دڪان جو نالو';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'توهان جو نالو';

  @override
  String get ownerNameHint => 'رميش گپتا';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'شروع ڪريو';

  @override
  String get requiredField => 'مهرباني ڪري هي ڀريو';

  @override
  String get navChat => 'ڳالهه ٻولهه';

  @override
  String get navStock => 'اسٽاڪ';

  @override
  String get navUdhaar => 'اڌار';

  @override
  String get navForecast => 'اندازو';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'ڊيمو';

  @override
  String get changeShop => 'دڪان بدلايو';

  @override
  String welcomeMessage(String name) {
    return 'نمستي $name! ٻڌايو ڇا آيو، ڇا وڪامي ويو، يا ڪنهن اڌار کنيو. مائيڪ دٻائي ڳالهايو.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'نمستي $name! ٻڌايو: ڇا آيو، ڇا وڪيو، ڪنهن کي اڌار ڏنو. مائيڪ دٻائي ڳالهايو.';
  }

  @override
  String get recordingCancelled => 'ڇڏي ڏيو، رد ٿي ويو';

  @override
  String get voiceTooShort => 'تھورو گھڻو دٻائي رکو ۽ ڳالهايو';

  @override
  String get micPermissionDenied =>
      'وائيس نوٽ لاءِ مائيڪرو فون جي اجازت گهربل آهي.';

  @override
  String get voiceNoteSent => '🎤 آواز جو نوٽ';

  @override
  String get photoSent => '📷 شيلف جو فوٽو';

  @override
  String get typeMessageHint => 'هتي لکو…';

  @override
  String get send => 'موڪليو';

  @override
  String get thinking => 'سوچيان پيو…';

  @override
  String get networkError => 'سرور سان رابطو نه ٿي سگهيو. وري ڪوشش ڪريو.';

  @override
  String get comingSoon => 'جلد اچي رهيو آهي! شيلف اسڪين جلد ايندو.';

  @override
  String get scanFailed => 'فوٽو سمجھ ۾ نه آيو، وري ڪوشش ڪريو.';

  @override
  String get imageTooLarge =>
      'فوٽو تمام وڏو آهي (8 MB کان وڌيڪ). ننڍو فوٽو موڪليو.';

  @override
  String get stockTitle => 'اسٽاڪ';

  @override
  String get lowStockBadge => 'گھٽ آهي';

  @override
  String reorderAt(String level) {
    return '$level تي وري گھرايو';
  }

  @override
  String get emptyStock => 'في الحال اسٽاڪ ناهي. ٻڌايو ڇا آيو.';

  @override
  String get udhaarTitle => 'اڌار';

  @override
  String get totalOutstanding => 'ڪل باقي';

  @override
  String get emptyLedger =>
      'في الحال ڪو اڌار ناهي. چئو ”گپتا جي کي 350 جو اڌار ڏنو“.';

  @override
  String get forecastTitle => 'اندازو';

  @override
  String get legendHistory => 'گذريل هفتي';

  @override
  String get legendForecast => 'اندازو';

  @override
  String get legendBand => 'حد';

  @override
  String get orderReady => 'آرڊر تيار';

  @override
  String get shareWhatsapp => 'WhatsApp تي موڪليو';

  @override
  String get copied => 'ڪاپي ٿي ويو';

  @override
  String get copy => 'ڪاپي';

  @override
  String get retry => 'وري ڪوشش ڪريو';

  @override
  String get loading => 'لوڊ پيو ٿئي…';

  @override
  String get errorLoading => 'لوڊ نه ٿي سگهيو. ٻيهر ڪرڻ لاءِ هيٺ ڇڪيو.';

  @override
  String get tagline => 'ڳالهايو، ٿي ويندو.';

  @override
  String get languageQuestion => 'Mitra ڪهڙي ٻوليءَ ۾ ڳالهائي؟';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'هي ڀريو';

  @override
  String get dockPhoto => 'شيلف جو فوٽو';

  @override
  String get dockType => 'لکو';

  @override
  String get micLabel => 'دٻائي ڳالهايو';

  @override
  String get recordingLabel => 'ٻڌان پيو… ڇڏيندئو ته هليو ويندو';

  @override
  String get recordingCancelHint => 'رد ڪرڻ لاءِ آڱر ٻاهر ڪڍو';

  @override
  String get confirmHeader => 'سمجھي ويس · لکي ڇڏيو';

  @override
  String get confirmTotalUdhaar => 'اڌار · هاڻي ڪل';

  @override
  String get confirmTotalStock => 'اسٽاڪ · هاڻي ڪل';

  @override
  String get confirmTotalSale => 'وڪرو · اڄ جو ڪل';

  @override
  String get askHeader => 'پڪ ناهي';

  @override
  String askHeard(String text) {
    return 'توهان چيو ”$text“';
  }

  @override
  String get askStock => 'اسٽاڪ ۾ وڌايان؟';

  @override
  String get askUdhaar => 'اڌار ۾ لکان؟';

  @override
  String get askSale => 'وڪري ۾ لکان؟';

  @override
  String get askNo => 'نه';

  @override
  String get askDeclined => 'ٺيڪ آهي، نه لکيو.';

  @override
  String scanHeader(int count) {
    return 'شيلف ڏٺو · $count شيون مليون';
  }

  @override
  String get scanQuestion => 'اسٽاڪ هي ئي سيٽ ڪري ڇڏيان؟';

  @override
  String get scanConfirmed => 'سمجھي ويس · اسٽاڪ اپڊيٽ ٿي ويو';

  @override
  String stockSubtitle(int count, String time) {
    return '$count شيون · اپڊيٽ $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شيون گھٽ آهن',
      one: '1 شيءِ گھٽ آهي',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'سڀ ٺيڪ آهي';

  @override
  String get orderButton => 'آرڊر ٺاهيو';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'آرڊر ٺاهيو · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count ڄڻا · و وهي کاتو';
  }

  @override
  String get balanceLabel => 'باقي';

  @override
  String todayGiven(String amount) {
    return 'اڄ ڏنو +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'اڄ آيو −₹$amount';
  }

  @override
  String get owedCaption => 'باقي';

  @override
  String get settledBadge => 'چڪتو';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount آيو';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'اڌار شروع $date · $count اندراج';
  }

  @override
  String lastEntryAt(String time) {
    return 'آخري: $time';
  }

  @override
  String get remindButton => 'ياد ڏياريو';

  @override
  String get paidButton => 'پئسا آيا';

  @override
  String get paidPrompt => 'ڪيترا آيا؟ ٻڌايو.';

  @override
  String get historyLabel => 'تاريخ';

  @override
  String get entryGiven => 'اڌار ورتو';

  @override
  String get entryPaid => 'پئسا آيا';

  @override
  String get entrySourceVoice => 'آواز';

  @override
  String get entrySourceCash => 'روڪ';

  @override
  String get entrySourcePhoto => 'فوٽو';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'نمستي $name جي، $shop مان. توهان جا ₹$balance باقي آهن. مهرباني!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'ايندڙ 4 هفتا · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'ايندڙ 4 هفتا';

  @override
  String perWeek(String unit) {
    return '$unit / هفتو';
  }

  @override
  String get forecastFuture => 'اڳتي · اندازو';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'اسٽاڪ ۾ $onHand · گھرايو $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count شيون';
  }

  @override
  String get share => 'شيئر';

  @override
  String get hisaabTitle => 'اڄ جو حساب';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count اندراج';
  }

  @override
  String hisaabDayChip(String time) {
    return 'دڪان بند · $time';
  }

  @override
  String get hisaabSales => 'اڄ جو وڪرو';

  @override
  String get hisaabGiven => 'اڌار ڏنو';

  @override
  String get hisaabReceived => 'اڌار مان آيو';

  @override
  String get hisaabOutstanding => 'ڪل باقي';

  @override
  String get hisaabLow => 'گھٽ آهي';

  @override
  String hisaabLowItems(String items) {
    return '$items سڀاڻي گھرايو.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks هفتا پري آهي.';
  }

  @override
  String get hisaabOrderButton => 'سڀاڻي جو آرڊر ٺاهيو';

  @override
  String get hisaabShareButton => 'گھر تي WhatsApp ڪريو';

  @override
  String todayChip(String date) {
    return 'اڄ · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'ڪالهه · $date';
  }

  @override
  String get demoNotice => 'سرور نه مليو. ڊيمو موڊ ۾ شروع ڪري رهيو آهيان.';

  @override
  String get languageSheetTitle => 'Mitra ڪهڙي ٻوليءَ ۾ ڳالهائي؟';

  @override
  String get backLabel => 'واپس';

  @override
  String get voiceNoteLabel => 'وائيس نوٽ';

  @override
  String get undo => 'واپس آڻيو';

  @override
  String get feedbackButton => 'راءِ';

  @override
  String get feedbackTitle => 'Kirana Mitra ڪيئن هلي رهيو آهي؟';

  @override
  String get feedbackUp => 'سٺو';

  @override
  String get feedbackDown => 'ٺيڪ ناهي';

  @override
  String get feedbackCommentHint => 'ڪجهه ٻيو ٻڌائڻو هجي ته لکو…';

  @override
  String get feedbackVoiceHint => 'يا دٻائي ڳالهايو';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'آواز تيار · $seconds سيڪنڊ';
  }

  @override
  String get feedbackSend => 'موڪليو';

  @override
  String get feedbackPickRating => 'پهرين سٺو يا ٺيڪ ناهي چونڊيو';

  @override
  String get feedbackThanks => 'مهرباني!';

  @override
  String get changeLanguage => 'ٻولي بدلايو';

  @override
  String get languageSearchHint => 'ٻولي ڳوليو…';

  @override
  String get languageNoMatch => 'ڪابه ٻولي نه ملي';

  @override
  String get topSellersTitle => 'گهڻو وڪامندڙ';

  @override
  String get topSellersSubtitle => 'گذريل 2 هفتا · ايندڙ 2 هفتن جو اندازو';

  @override
  String get autoBadge => 'پاڻمرادو';

  @override
  String coverDays(String days) {
    return '$days ڏينهن جو اسٽاڪ';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 هفتا';
  }

  @override
  String get autoRestockTitle => 'ٽاپ وڪرو پاڻمرادو ڀريو';

  @override
  String get autoRestockSubtitle =>
      'گهٽ اسٽاڪ واري ٽاپ وڪري جو آرڊر رات جو پاڻ ئي هليو ويندو';

  @override
  String get distributorPhoneLabel => 'ڊسٽريبيوٽر جو WhatsApp نمبر';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'محفوظ ڪريو';

  @override
  String get settingsSaved => 'محفوظ ٿي ويو';

  @override
  String get ordersTitle => 'آرڊر';

  @override
  String get ordersEmpty => 'في الحال ڪو آرڊر ناهي. اندازي مان آرڊر ٺاهيو.';

  @override
  String get orderAuto => 'پاڻمرادو';

  @override
  String get orderManual => 'پاڻ ٺاهيل';

  @override
  String get orderPlaced => 'موڪليو ويو';

  @override
  String get orderCancelled => 'رد ٿي ويو';

  @override
  String get viewOrders => 'آرڊر ڏسو';

  @override
  String get newOrdersNotice => 'رات جو پاڻمرادو آرڊر آيو';
}
