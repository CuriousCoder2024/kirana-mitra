// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class AppLocalizationsAs extends AppLocalizations {
  AppLocalizationsAs([String locale = 'as']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'দোকানৰ নাম';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'আপোনাৰ নাম';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'আৰম্ভ কৰক';

  @override
  String get requiredField => 'অনুগ্ৰহ কৰি এইটো পূৰণ কৰক';

  @override
  String get navChat => 'কথা';

  @override
  String get navStock => 'ষ্টক';

  @override
  String get navUdhaar => 'বাকী';

  @override
  String get navForecast => 'পূৰ্বাভাস';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'ডেমো';

  @override
  String get changeShop => 'দোকান সলনি কৰক';

  @override
  String welcomeMessage(String name) {
    return 'নমস্কাৰ $name! কি সামগ্ৰী আহিল, কি বিক্ৰী হ\'ল বা কোনে বাকী ল\'লে কওক। মাইক টিপি ধৰি কওক।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'নমস্কাৰ $name! কওক: কি আহিল, কি বিক্ৰী হ\'ল, কাক বাকী দিলে। মাইক টিপি ধৰি কওক।';
  }

  @override
  String get recordingCancelled => 'এৰি দিয়ক, বাতিল কৰা হ\'ল';

  @override
  String get voiceTooShort => 'অলপ বেছি সময় টিপি ধৰি কওক';

  @override
  String get micPermissionDenied =>
      'ভয়েচ টোকাৰ বাবে মাইক্ৰ\'ফোনৰ অনুমতি লাগিব।';

  @override
  String get voiceNoteSent => '🎤 ভয়েচ টোকা';

  @override
  String get photoSent => '📷 শ্বেল্ফৰ ফটো';

  @override
  String get typeMessageHint => 'ইয়াত লিখক…';

  @override
  String get send => 'পঠিয়াওক';

  @override
  String get thinking => 'ভাবি থকা হৈছে…';

  @override
  String get networkError => 'চাৰ্ভাৰ পোৱা নগ\'ল। পুনৰ চেষ্টা কৰক।';

  @override
  String get comingSoon => 'শীঘ্ৰেই আহি আছে! শ্বেল্ফ স্কেন সোনকালেই আহিব।';

  @override
  String get scanFailed => 'ফটোখন বুজিব পৰা নগ\'ল, পুনৰ চেষ্টা কৰক।';

  @override
  String get imageTooLarge => 'ফটোখন বহুত ডাঙৰ (8 MB-তকৈ বেছি)। সৰু ফটো দিয়ক।';

  @override
  String get stockTitle => 'ষ্টক';

  @override
  String get lowStockBadge => 'কম আছে';

  @override
  String reorderAt(String level) {
    return '$level-ত পুনৰ অৰ্ডাৰ কৰক';
  }

  @override
  String get emptyStock => 'এতিয়া ষ্টক নাই। কি সামগ্ৰী আহিল কওক।';

  @override
  String get udhaarTitle => 'বাকী';

  @override
  String get totalOutstanding => 'মুঠ বাকী';

  @override
  String get emptyLedger =>
      'এতিয়া কোনো বাকী নাই। কওক \"Gupta ji-ক 350 টকাৰ বাকী দিলোঁ\"।';

  @override
  String get forecastTitle => 'পূৰ্বাভাস';

  @override
  String get legendHistory => 'যোৱা সপ্তাহ';

  @override
  String get legendForecast => 'অনুমান';

  @override
  String get legendBand => 'ৰেঞ্জ';

  @override
  String get orderReady => 'অৰ্ডাৰ সাজু';

  @override
  String get shareWhatsapp => 'WhatsApp-ত পঠিয়াওক';

  @override
  String get copied => 'কপি হ\'ল';

  @override
  String get copy => 'কপি কৰক';

  @override
  String get retry => 'পুনৰ চেষ্টা কৰক';

  @override
  String get loading => 'লোড হৈ আছে…';

  @override
  String get errorLoading => 'লোড নহ\'ল। তললৈ টানি পুনৰ চেষ্টা কৰক।';

  @override
  String get tagline => 'কওক, হৈ যাব।';

  @override
  String get languageQuestion => 'Mitra-ই কোন ভাষাত কওক?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'এইটো পূৰণ কৰক';

  @override
  String get dockPhoto => 'শ্বেল্ফৰ ফটো';

  @override
  String get dockType => 'লিখক';

  @override
  String get micLabel => 'টিপি ধৰি কওক';

  @override
  String get recordingLabel => 'শুনি আছোঁ… এৰি দিলে পঠিয়াব';

  @override
  String get recordingCancelHint => 'বাতিল কৰিবলৈ আঙুলি বাহিৰলৈ নিয়ক';

  @override
  String get confirmHeader => 'বুজিলোঁ · লিখি ল\'লোঁ';

  @override
  String get confirmTotalUdhaar => 'বাকী · এতিয়া মুঠ';

  @override
  String get confirmTotalStock => 'ষ্টক · এতিয়া মুঠ';

  @override
  String get confirmTotalSale => 'বিক্ৰী · আজি মুঠ';

  @override
  String get askHeader => 'নিশ্চিত নহয়';

  @override
  String askHeard(String text) {
    return 'আপুনি ক\'লে “$text”';
  }

  @override
  String get askStock => 'ষ্টকত যোগ কৰিম নেকি?';

  @override
  String get askUdhaar => 'বাকীত লিখিম নেকি?';

  @override
  String get askSale => 'বিক্ৰীত লিখিম নেকি?';

  @override
  String get askNo => 'নহয়';

  @override
  String get askDeclined => 'ঠিক আছে, লিখা নহ\'ল।';

  @override
  String scanHeader(int count) {
    return 'শ্বেল্ফ চালোঁ · $count বিধ বস্তু পালোঁ';
  }

  @override
  String get scanQuestion => 'ষ্টক ইয়াতেই ছেট কৰিম নেকি?';

  @override
  String get scanConfirmed => 'বুজিলোঁ · ষ্টক আপডেট হ\'ল';

  @override
  String stockSubtitle(int count, String time) {
    return '$count বিধ বস্তু · আপডেট $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বিধ বস্তু কম আছে',
      one: '1 বিধ বস্তু কম আছে',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'সকলো ঠিক আছে';

  @override
  String get orderButton => 'অৰ্ডাৰ বনাওক';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'অৰ্ডাৰ বনাওক · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count জন ব্যক্তি · খাতা';
  }

  @override
  String get balanceLabel => 'বাকী';

  @override
  String todayGiven(String amount) {
    return 'আজি দিয়া হ\'ল +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'আজি পোৱা গ\'ল −₹$amount';
  }

  @override
  String get owedCaption => 'বাকী';

  @override
  String get settledBadge => 'পৰিশোধিত';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount আহিল';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'বাকী আৰম্ভ $date · $count টা এন্ট্ৰি';
  }

  @override
  String lastEntryAt(String time) {
    return 'শেষবাৰ: $time';
  }

  @override
  String get remindButton => 'মনত পেলাই দিয়ক';

  @override
  String get paidButton => 'পইচা পালে';

  @override
  String get paidPrompt => 'কিমান পালে? কওক।';

  @override
  String get historyLabel => 'ইতিহাস';

  @override
  String get entryGiven => 'বাকী নিলে';

  @override
  String get entryPaid => 'পইচা আহিল';

  @override
  String get entrySourceVoice => 'voice';

  @override
  String get entrySourceCash => 'cash';

  @override
  String get entrySourcePhoto => 'photo';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'নমস্কাৰ $name ডাঙৰীয়া, $shopৰ পৰা। আপোনাৰ ₹$balance বাকী আছে। ধন্যবাদ!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'অহা 4 সপ্তাহ · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'অহা 4 সপ্তাহ';

  @override
  String perWeek(String unit) {
    return '$unit / সপ্তাহ';
  }

  @override
  String get forecastFuture => 'ভৱিষ্যত · পূৰ্বাভাস';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'ষ্টকত $onHand · অৰ্ডাৰ কৰক $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count বিধ বস্তু';
  }

  @override
  String get share => 'শ্বেয়াৰ';

  @override
  String get hisaabTitle => 'আজিৰ হিচাপ';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count টা এন্ট্ৰি';
  }

  @override
  String hisaabDayChip(String time) {
    return 'দোকান বন্ধ · $time';
  }

  @override
  String get hisaabSales => 'আজিৰ বিক্ৰী';

  @override
  String get hisaabGiven => 'বাকী দিয়া হ\'ল';

  @override
  String get hisaabReceived => 'বাকী আদায় হ\'ল';

  @override
  String get hisaabOutstanding => 'মুঠ বাকী';

  @override
  String get hisaabLow => 'কম আছে';

  @override
  String hisaabLowItems(String items) {
    return '$items কাইলৈ আনক।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festivalলৈ $weeks সপ্তাহ বাকী।';
  }

  @override
  String get hisaabOrderButton => 'কাইলৈৰ অৰ্ডাৰ বনাওক';

  @override
  String get hisaabShareButton => 'ঘৰলৈ WhatsApp কৰক';

  @override
  String todayChip(String date) {
    return 'আজি · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'কালি · $date';
  }

  @override
  String get demoNotice => 'চাৰ্ভাৰ পোৱা নগ\'ল। ডেমো ম\'ডত আৰম্ভ কৰা হৈছে।';

  @override
  String get languageSheetTitle => 'Mitra-ই কোন ভাষাত কওক?';

  @override
  String get backLabel => 'উভতি যাওক';

  @override
  String get voiceNoteLabel => 'ভয়েচ টোকা';

  @override
  String get undo => 'পূৰ্বৰ অৱস্থালৈ';

  @override
  String get feedbackButton => 'মতামত';

  @override
  String get feedbackTitle => 'Kirana Mitra কেনে চলিছে?';

  @override
  String get feedbackUp => 'ভাল';

  @override
  String get feedbackDown => 'ভাল নহয়';

  @override
  String get feedbackCommentHint => 'আৰু কিবা ক\'বলগীয়া থাকিলে লিখক…';

  @override
  String get feedbackVoiceHint => 'বা টিপি ধৰি কওক';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'শব্দ সাজু · ${seconds}s';
  }

  @override
  String get feedbackSend => 'পঠিয়াওক';

  @override
  String get feedbackPickRating => 'প্ৰথমে ভাল বা ভাল নহয় বাচক';

  @override
  String get feedbackThanks => 'ধন্যবাদ!';

  @override
  String get changeLanguage => 'ভাষা সলনি কৰক';

  @override
  String get languageSearchHint => 'ভাষা বিচাৰক…';

  @override
  String get languageNoMatch => 'কোনো ভাষা পোৱা নগ\'ল';

  @override
  String get topSellersTitle => 'Top sellers';

  @override
  String get topSellersSubtitle => 'যোৱা 2 সপ্তাহ · অহা 2 সপ্তাহৰ অনুমান';

  @override
  String get autoBadge => 'অটো';

  @override
  String coverDays(String days) {
    return '$days দিনৰ ষ্টক';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 সপ্তাহ';
  }

  @override
  String get autoRestockTitle => 'Top sellers-ৰ অটো-ৰিষ্টক';

  @override
  String get autoRestockSubtitle =>
      'কম ষ্টক থকা top sellers-ৰ অৰ্ডাৰ ৰাতি নিজে নিজে যাব';

  @override
  String get distributorPhoneLabel => 'ডিষ্ট্ৰিবিউটৰৰ WhatsApp নম্বৰ';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'ছেভ কৰক';

  @override
  String get settingsSaved => 'ছেভ হ\'ল';

  @override
  String get ordersTitle => 'অৰ্ডাৰসমূহ';

  @override
  String get ordersEmpty =>
      'এতিয়া কোনো অৰ্ডাৰ নাই। পূৰ্বাভাসৰ পৰা অৰ্ডাৰ বনাওক।';

  @override
  String get orderAuto => 'অটো';

  @override
  String get orderManual => 'মেনুৱেল';

  @override
  String get orderPlaced => 'পঠিওৱা হ\'ল';

  @override
  String get orderCancelled => 'বাতিল হ\'ল';

  @override
  String get viewOrders => 'অৰ্ডাৰ চাওক';

  @override
  String get newOrdersNotice => 'ৰাতিৰ অটো অৰ্ডাৰ আহিল';

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
