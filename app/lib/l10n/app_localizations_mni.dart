// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Manipuri (`mni`).
class AppLocalizationsMni extends AppLocalizations {
  AppLocalizationsMni([String locale = 'mni']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'দোকানগী মিং';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'অদোমগী মিং';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'হৌসি';

  @override
  String get requiredField => 'মসি মেনশিনবীয়ু';

  @override
  String get navChat => 'ৱারী';

  @override
  String get navStock => 'Stock';

  @override
  String get navUdhaar => 'লমন';

  @override
  String get navForecast => 'Forecast';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'Demo';

  @override
  String get changeShop => 'দোকান হোংদোকপা';

  @override
  String welcomeMessage(String name) {
    return 'খুরুমজরি $name! করি লাকপগে, করি য়োনবগে, কনানা ধার লৌবগে হায়বীয়ু। Mic পাইদুনা ঙাংবীয়ু।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'খুরুমজরি $name! হায়বীয়ু: করি লাকপগে, করি য়োনবগে, কনানা ধার লৌবগে। Mic নম্বীয়ু অমসুং ঙাংবীয়ু।';
  }

  @override
  String get recordingCancelled => 'থাদোক্লবা, cancel ওইরে';

  @override
  String get voiceTooShort => 'খরা কুয়ানা পাইদুনা ঙাংবীয়ু';

  @override
  String get micPermissionDenied =>
      'Voice note গীদমক Microphone গী অয়াবা দরকার ওই।';

  @override
  String get voiceNoteSent => '🎤 Voice note';

  @override
  String get photoSent => '📷 Shelf photo';

  @override
  String get typeMessageHint => 'মফমসিদা ইবীয়ু…';

  @override
  String get send => 'থাবা';

  @override
  String get thinking => 'খন্নরি…';

  @override
  String get networkError => 'Server ফংদে। অমুক হন্না হোৎনবীয়ু।';

  @override
  String get comingSoon => 'থুনা লাক্কদৌরে! Shelf scan থুনা য়াওরক্কনি।';

  @override
  String get scanFailed => 'Photo খঙবা ঙমদে, অমুক হন্না হোৎনবীয়ু।';

  @override
  String get imageTooLarge =>
      'Photo চাউরক্লে (8 MB হেনখ্রে)। খরা অপীকপা অমুক হোৎনবীয়ু।';

  @override
  String get stockTitle => 'Stock';

  @override
  String get lowStockBadge => 'ৱাৎলে';

  @override
  String reorderAt(String level) {
    return '$level দা অমুক থাবীয়ু';
  }

  @override
  String get emptyStock => 'হৌজিক stock লৈতে। করি লাকপগে হায়বীয়ু।';

  @override
  String get udhaarTitle => 'লমন';

  @override
  String get totalOutstanding => 'লৈহৌবা অপুনবা';

  @override
  String get emptyLedger =>
      'হৌজিক লমন অমত্তা লৈতে। “Gupta ji দা 350 গী ধার পীখ্রে” হায়বীয়ু।';

  @override
  String get forecastTitle => 'Forecast';

  @override
  String get legendHistory => 'হৌখিবা চয়োল';

  @override
  String get legendForecast => 'পানবা';

  @override
  String get legendBand => 'Range';

  @override
  String get orderReady => 'Order শেম্লে';

  @override
  String get shareWhatsapp => 'WhatsApp তা থাবীয়ু';

  @override
  String get copied => 'Copy তৌরবা';

  @override
  String get copy => 'Copy';

  @override
  String get retry => 'অমুক হন্না';

  @override
  String get loading => 'Loading…';

  @override
  String get errorLoading => 'পুথোকপা ঙমদে। চিংশিন্দুনা অমুক হোৎনবীয়ু।';

  @override
  String get tagline => 'ঙাংবীয়ু, লোইশিনগনি।';

  @override
  String get languageQuestion => 'Mitra না করম্বা লোলদা ঙাংগনি?';

  @override
  String get langSampleHindi => 'नमस्ते! আজ কি লাকপগে?';

  @override
  String get langSampleHinglish => 'Namaste! আজ কি লাকপগে?';

  @override
  String get langSampleEnglish => 'Hello! ঙসি করি লাকপগে?';

  @override
  String get fieldRequired => 'মসি মেনশিল্লু';

  @override
  String get dockPhoto => 'Shelf photo';

  @override
  String get dockType => 'ইবা';

  @override
  String get micLabel => 'নমদুনা ঙাংবীয়ু';

  @override
  String get recordingLabel => 'তারি… থাদোকপগা থাগনি';

  @override
  String get recordingCancelHint => 'Cancel তৌনবগীদমক খুৎ চাউথোকউ';

  @override
  String get confirmHeader => 'খঙলে · ইখ্রে';

  @override
  String get confirmTotalUdhaar => 'লমন · হৌজিক অপুনবা';

  @override
  String get confirmTotalStock => 'Stock · হৌজিক অপুনবা';

  @override
  String get confirmTotalSale => 'য়োনবা · ঙসিগী অপুনবা';

  @override
  String get askHeader => 'শেংদে';

  @override
  String askHeard(String text) {
    return 'অদোম্না “$text” হায়রে';
  }

  @override
  String get askStock => 'Stock তা হাপকদরা?';

  @override
  String get askUdhaar => 'লমন্ডা ইগদরা?';

  @override
  String get askSale => 'য়োনবদা ইগদরা?';

  @override
  String get askNo => 'নত্তে';

  @override
  String get askDeclined => 'য়ারে, ইদে।';

  @override
  String scanHeader(int count) {
    return 'Shelf য়েংলে · পোৎলম $count ফংলে';
  }

  @override
  String get scanQuestion => 'Stock অসিদা set তৌগদরা?';

  @override
  String get scanConfirmed => 'খঙলে · stock update তৌরে';

  @override
  String stockSubtitle(int count, String time) {
    return 'পোৎলম $count · update $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'পোৎলম $count ৱাৎলে',
      one: 'পোৎলম 1 ৱাৎলে',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'পুম্নমক চপ চারে';

  @override
  String get orderButton => 'Order শেম্বা';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'Order শেম্বা · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return 'মীওই $count · বহিখাতা';
  }

  @override
  String get balanceLabel => 'লৈহৌবা';

  @override
  String todayGiven(String amount) {
    return 'ঙসি পীবা +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'ঙসি লাকপা −₹$amount';
  }

  @override
  String get owedCaption => 'লৈহৌবা';

  @override
  String get settledBadge => 'লোইরে';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount লাক্লে';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'লমন হৌবা $date · entry $count';
  }

  @override
  String lastEntryAt(String time) {
    return 'অরোইবা: $time';
  }

  @override
  String get remindButton => 'নীংশিংবা';

  @override
  String get paidButton => 'পৈশা লাক্লে';

  @override
  String get paidPrompt => 'কয়া লাকপগে? হায়বীয়ু।';

  @override
  String get historyLabel => 'History';

  @override
  String get entryGiven => 'ধার লৌরে';

  @override
  String get entryPaid => 'পৈশা লাক্লে';

  @override
  String get entrySourceVoice => 'voice';

  @override
  String get entrySourceCash => 'cash';

  @override
  String get entrySourcePhoto => 'photo';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'খুরুমজরি $name ji, $shop দগীনি। অদোমগী ₹$balance লৈহৌরি। থাগৎচরি!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'লাক্কদৌরিবা চয়োল 4 · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'লাক্কদৌরিবা চয়োল 4';

  @override
  String perWeek(String unit) {
    return '$unit / চয়োল';
  }

  @override
  String get forecastFuture => 'তুংদা · forecast';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'Stock তা $onHand লৈ · $qty $unit কৌজিল্লু';
  }

  @override
  String orderItemCount(int count) {
    return 'পোৎলম $count';
  }

  @override
  String get share => 'Share';

  @override
  String get hisaabTitle => 'ঙসিগী হিসাব';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · entry $count';
  }

  @override
  String hisaabDayChip(String time) {
    return 'দোকান থিংলে · $time';
  }

  @override
  String get hisaabSales => 'ঙসি য়োনখিবা';

  @override
  String get hisaabGiven => 'ধার পীবা';

  @override
  String get hisaabReceived => 'ধার লাকপা';

  @override
  String get hisaabOutstanding => 'লৈহৌবা অপুনবা';

  @override
  String get hisaabLow => 'ৱাৎলে';

  @override
  String hisaabLowItems(String items) {
    return '$items হায়াং কৌজিল্লু।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival ফংনবা চয়োল $weeks ৱাৎলি।';
  }

  @override
  String get hisaabOrderButton => 'হায়াংগী order শেম্বা';

  @override
  String get hisaabShareButton => 'য়ুমদা WhatsApp তৌবীয়ু';

  @override
  String todayChip(String date) {
    return 'ঙসি · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'ঙরাং · $date';
  }

  @override
  String get demoNotice => 'Server ফংদে। Demo mode দা হৌদোক্লি।';

  @override
  String get languageSheetTitle => 'Mitra না করম্বা লোলদা ঙাংগনি?';

  @override
  String get backLabel => 'হন্দোকপা';

  @override
  String get voiceNoteLabel => 'Voice note';

  @override
  String get undo => 'হন্দোকউ';

  @override
  String get feedbackButton => 'Feedback';

  @override
  String get feedbackTitle => 'Kirana Mitra করম তৌরি?';

  @override
  String get feedbackUp => 'ফৈ';

  @override
  String get feedbackDown => 'ফত্তে';

  @override
  String get feedbackCommentHint => 'অতোপ্পা হায়নিংবা লৈরবদি ইবীয়ু…';

  @override
  String get feedbackVoiceHint => 'নত্রগা নম্বীয়ু অমসুং ঙাংবীয়ু';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'খোনজেল শেম্লে · ${seconds}s';
  }

  @override
  String get feedbackSend => 'থাবীয়ু';

  @override
  String get feedbackPickRating => 'হান্না ফৈ নত্রগা ফত্তে খনবীয়ু';

  @override
  String get feedbackThanks => 'থাগৎচরি!';

  @override
  String get changeLanguage => 'লোল হোংবা';

  @override
  String get languageSearchHint => 'লোল থিবীয়ু…';

  @override
  String get languageNoMatch => 'লোল অমত্তা ফংদে';

  @override
  String get topSellersTitle => 'খ্বাইদগী য়োনবা';

  @override
  String get topSellersSubtitle =>
      'হৌখিবা চয়োল 2 · লাক্কদৌরিবা চয়োল 2 গী পানবা';

  @override
  String get autoBadge => 'Auto';

  @override
  String coverDays(String days) {
    return 'নুমিৎ $days গী stock';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / চয়োল 2';
  }

  @override
  String get autoRestockTitle => 'Top sellers মশানা restock তৌবা';

  @override
  String get autoRestockSubtitle =>
      'ৱাৎলবা top sellers গী order নুমিদাংদা মশামক চৎখিগনি';

  @override
  String get distributorPhoneLabel => 'Distributor গী WhatsApp number';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'Save তৌবীয়ু';

  @override
  String get settingsSaved => 'Save তৌরে';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersEmpty =>
      'হৌজিক order অমত্তা লৈতে। Forecast তগী Order শেম্বীয়ু।';

  @override
  String get orderAuto => 'Auto';

  @override
  String get orderManual => 'Manual';

  @override
  String get orderPlaced => 'থাখ্রে';

  @override
  String get orderCancelled => 'Cancel তৌখ্রে';

  @override
  String get viewOrders => 'Orders য়েংবা';

  @override
  String get newOrdersNotice => 'নুমিদাংগী auto order লাক্লে';
}
