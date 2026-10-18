// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'দোকানের নাম';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'আপনার নাম';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'শুরু করুন';

  @override
  String get requiredField => 'এটা পূরণ করুন';

  @override
  String get navChat => 'কথা';

  @override
  String get navStock => 'Stock';

  @override
  String get navUdhaar => 'বাকি';

  @override
  String get navForecast => 'Forecast';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'Demo';

  @override
  String get changeShop => 'দোকান বদলান';

  @override
  String welcomeMessage(String name) {
    return 'নমস্কার $name! কী এলো, কী বিক্রি হলো বা কে বাকি নিলো বলুন। মাইক চেপে ধরে বলুন।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'নমস্কার $name! বলুন: কী এলো, কী বিক্রি হলো, কাকে বাকি দিলেন। মাইক চেপে ধরে বলুন।';
  }

  @override
  String get recordingCancelled => 'ছেড়ে দিন, বাতিল হয়েছে';

  @override
  String get voiceTooShort => 'একটু বেশি সময় চেপে ধরে বলুন';

  @override
  String get micPermissionDenied =>
      'ভয়েস নোটের জন্য মাইক্রোফোনের অনুমতি প্রয়োজন।';

  @override
  String get voiceNoteSent => '🎤 ভয়েস নোট';

  @override
  String get photoSent => '📷 তাকের ছবি';

  @override
  String get typeMessageHint => 'এখানে লিখুন…';

  @override
  String get send => 'পাঠান';

  @override
  String get thinking => 'ভাবছি…';

  @override
  String get networkError => 'সার্ভারে যোগাযোগ করা গেল না। আবার চেষ্টা করুন।';

  @override
  String get comingSoon => 'শীঘ্রই আসছে! তাক স্ক্যান খুব জলদি চালু হবে।';

  @override
  String get scanFailed => 'ছবিটি বোঝা যায়নি, আবার চেষ্টা করুন।';

  @override
  String get imageTooLarge => 'ছবিটি বড্ড বড় (8 MB-র বেশি)। ছোট ছবি দিন।';

  @override
  String get stockTitle => 'Stock';

  @override
  String get lowStockBadge => 'কম আছে';

  @override
  String reorderAt(String level) {
    return '$level হলে আবার অর্ডার করুন';
  }

  @override
  String get emptyStock => 'এখন কোনো স্টক নেই। কী মাল এলো বলুন।';

  @override
  String get udhaarTitle => 'বাকি';

  @override
  String get totalOutstanding => 'মোট বাকি';

  @override
  String get emptyLedger =>
      'এখন কোনো বাকি নেই। বলুন \"গুপ্তাজিকে ৩৫০ টাকার বাকি দিয়েছি\"।';

  @override
  String get forecastTitle => 'Forecast';

  @override
  String get legendHistory => 'গত সপ্তাহে';

  @override
  String get legendForecast => 'অনুমান';

  @override
  String get legendBand => 'পরিসীমা';

  @override
  String get orderReady => 'অর্ডার তৈরি';

  @override
  String get shareWhatsapp => 'WhatsApp-এ পাঠান';

  @override
  String get copied => 'কপি হয়েছে';

  @override
  String get copy => 'কপি';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get loading => 'লোড হচ্ছে…';

  @override
  String get errorLoading => 'লোড করা যায়নি। টান দিয়ে আবার চেষ্টা করুন।';

  @override
  String get tagline => 'বলুন, হয়ে যাবে।';

  @override
  String get languageQuestion => 'মিত্র কোন ভাষায় কথা বলবে?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'এটা লিখুন';

  @override
  String get dockPhoto => 'তাকের ছবি';

  @override
  String get dockType => 'লিখুন';

  @override
  String get micLabel => 'চেপে ধরে বলুন';

  @override
  String get recordingLabel => 'শুনছি… ছেড়ে দিলে পাঠানো হবে';

  @override
  String get recordingCancelHint => 'বাতিল করতে আঙুল বাইরে সরান';

  @override
  String get confirmHeader => 'বুঝেছি · লিখে নিয়েছি';

  @override
  String get confirmTotalUdhaar => 'বাকি · এখন মোট';

  @override
  String get confirmTotalStock => 'স্টক · এখন মোট';

  @override
  String get confirmTotalSale => 'বিক্রি · আজ মোট';

  @override
  String get askHeader => 'নিশ্চিত নই';

  @override
  String askHeard(String text) {
    return 'আপনি বললেন “$text”';
  }

  @override
  String get askStock => 'স্টকে যোগ করব?';

  @override
  String get askUdhaar => 'বাকিতে লিখব?';

  @override
  String get askSale => 'বিক্রিতে লিখব?';

  @override
  String get askNo => 'না';

  @override
  String get askDeclined => 'ঠিক আছে, লিখিনি।';

  @override
  String scanHeader(int count) {
    return 'তাক দেখেছে · $countটি জিনিস পাওয়া গেছে';
  }

  @override
  String get scanQuestion => 'স্টক এটাই সেট করব?';

  @override
  String get scanConfirmed => 'বুঝেছি · স্টক আপডেট হয়েছে';

  @override
  String stockSubtitle(int count, String time) {
    return '$countটি জিনিস · আপডেট $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি জিনিস কম আছে',
      one: '1টি জিনিস কম আছে',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'সব ঠিক আছে';

  @override
  String get orderButton => 'অর্ডার বানাও';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'অর্ডার বানাও · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count জন · খাতা';
  }

  @override
  String get balanceLabel => 'বাকি';

  @override
  String todayGiven(String amount) {
    return 'আজ দেওয়া +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'আজ জমা −₹$amount';
  }

  @override
  String get owedCaption => 'বাকি';

  @override
  String get settledBadge => 'মিটে গেছে';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount জমা';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'বাকি শুরু $date · $countটি হিসাব';
  }

  @override
  String lastEntryAt(String time) {
    return 'শেষ: $time';
  }

  @override
  String get remindButton => 'মনে করান';

  @override
  String get paidButton => 'টাকা এলো';

  @override
  String get paidPrompt => 'কত টাকা এলো? বলুন।';

  @override
  String get historyLabel => 'হিসাব';

  @override
  String get entryGiven => 'বাকি নিয়েছে';

  @override
  String get entryPaid => 'টাকা এলো';

  @override
  String get entrySourceVoice => 'ভয়েস';

  @override
  String get entrySourceCash => 'নগদ';

  @override
  String get entrySourcePhoto => 'ছবি';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'নমস্কার $name বাবু, $shop থেকে বলছি। আপনার ₹$balance বাকি আছে। ধন্যবাদ!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'পরের 4 সপ্তাহ · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'পরের 4 সপ্তাহ';

  @override
  String perWeek(String unit) {
    return '$unit / সপ্তাহ';
  }

  @override
  String get forecastFuture => 'সামনে · forecast';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'স্টকে আছে $onHand · আনান $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$countটি জিনিস';
  }

  @override
  String get share => 'শেয়ার';

  @override
  String get hisaabTitle => 'আজকের হিসেব';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $countটি হিসাব';
  }

  @override
  String hisaabDayChip(String time) {
    return 'দোকান বন্ধ · $time';
  }

  @override
  String get hisaabSales => 'আজকের বিক্রি';

  @override
  String get hisaabGiven => 'বাকি দেওয়া';

  @override
  String get hisaabReceived => 'বাকি আদায়';

  @override
  String get hisaabOutstanding => 'মোট বাকি';

  @override
  String get hisaabLow => 'কম আছে';

  @override
  String hisaabLowItems(String items) {
    return '$items কাল আনিয়ে নিন।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks সপ্তাহ বাকি।';
  }

  @override
  String get hisaabOrderButton => 'কালের অর্ডার বানান';

  @override
  String get hisaabShareButton => 'বাড়িতে WhatsApp করুন';

  @override
  String todayChip(String date) {
    return 'আজ · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'গতকাল · $date';
  }

  @override
  String get demoNotice => 'সার্ভার পাওয়া যায়নি। ডেমো মোডে শুরু হচ্ছে।';

  @override
  String get languageSheetTitle => 'মিত্র কোন ভাষায় বলবে?';

  @override
  String get backLabel => 'পেছনে';

  @override
  String get voiceNoteLabel => 'ভয়েস নোট';

  @override
  String get undo => 'ফেরত নিন';

  @override
  String get feedbackButton => 'মতামত';

  @override
  String get feedbackTitle => 'Kirana Mitra কেমন চলছে?';

  @override
  String get feedbackUp => 'ভালো';

  @override
  String get feedbackDown => 'ঠিক নেই';

  @override
  String get feedbackCommentHint => 'আর কিছু জানানোর থাকলে লিখুন…';

  @override
  String get feedbackVoiceHint => 'বা চেপে ধরে বলুন';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'ভয়েস তৈরি · $seconds সেকেণ্ড';
  }

  @override
  String get feedbackSend => 'পাঠান';

  @override
  String get feedbackPickRating => 'আগে ভালো বা ঠিক নেই বাছুন';

  @override
  String get feedbackThanks => 'ধন্যবাদ!';

  @override
  String get changeLanguage => 'ভাষা বদলান';

  @override
  String get languageSearchHint => 'ভাষা খুঁজুন…';

  @override
  String get languageNoMatch => 'কোনো ভাষা পাওয়া যায়নি';

  @override
  String get topSellersTitle => 'বেশি বিক্রির জিনিস';

  @override
  String get topSellersSubtitle => 'গত 2 সপ্তাহ · পরের 2 সপ্তাহের অনুমান';

  @override
  String get autoBadge => 'অটো';

  @override
  String coverDays(String days) {
    return '$days দিনের স্টক';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 সপ্তাহ';
  }

  @override
  String get autoRestockTitle => 'বেশি বিক্রির জিনিস অটো-রিস্টক';

  @override
  String get autoRestockSubtitle =>
      'কম স্টকের বেশি বিক্রির জিনিসের অর্ডার রাতে নিজে থেকেই চলে যাবে';

  @override
  String get distributorPhoneLabel => 'ডিস্ট্রিবিউটরের WhatsApp নম্বর';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'সেভ করুন';

  @override
  String get settingsSaved => 'সেভ হয়েছে';

  @override
  String get ordersTitle => 'অর্ডার';

  @override
  String get ordersEmpty =>
      'এখন কোনো অর্ডার নেই। Forecast থেকে অর্ডার তৈরি করুন।';

  @override
  String get orderAuto => 'অটো';

  @override
  String get orderManual => 'ম্যানুয়াল';

  @override
  String get orderPlaced => 'পাঠানো হয়েছে';

  @override
  String get orderCancelled => 'বাতিল হয়েছে';

  @override
  String get viewOrders => 'অর্ডার দেখুন';

  @override
  String get newOrdersNotice => 'রাতের অটো অর্ডার এসেছে';

  @override
  String get shopReRegistered =>
      'Server restart hua, dukaan phir se register ki.';
}
