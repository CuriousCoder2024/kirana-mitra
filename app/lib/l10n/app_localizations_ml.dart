// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'കടയുടെ പേര്';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'നിങ്ങളുടെ പേര്';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'തുടങ്ങാം';

  @override
  String get requiredField => 'ഇത് പൂരിപ്പിക്കൂ';

  @override
  String get navChat => 'സംസാരം';

  @override
  String get navStock => 'സ്റ്റോക്ക്';

  @override
  String get navUdhaar => 'കടം';

  @override
  String get navForecast => 'കണക്കുകൂട്ടൽ';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'ഡെമോ';

  @override
  String get changeShop => 'കട മാറ്റുക';

  @override
  String welcomeMessage(String name) {
    return 'നമസ്കാരം $name! സാധനങ്ങൾ വന്നതോ, വിറ്റതോ, കടം കൊടുത്തതോ പറയൂ. മൈക്ക് അമർത്തിപ്പിടിച്ച് സംസാരിക്കൂ.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'നമസ്കാരം $name! സാധനങ്ങൾ വന്നതോ, വിറ്റതോ, ആർക്കൊക്കെ കടം കൊടുത്തതോ പറയൂ. മൈക്ക് അമർത്തിപ്പിടിച്ച് സംസാരിക്കൂ.';
  }

  @override
  String get recordingCancelled => 'വേണ്ട, ക്യാൻസൽ ചെയ്തു';

  @override
  String get voiceTooShort => 'കുറച്ചുകൂടി നേരം അമർത്തിപ്പിടിച്ച് പറയൂ';

  @override
  String get micPermissionDenied =>
      'വോയ്‌സ് റെക്കോർഡ് ചെയ്യാൻ മൈക്രോഫോൺ അനുമതി വേണം.';

  @override
  String get voiceNoteSent => '🎤 വോയ്‌സ് നോട്ട്';

  @override
  String get photoSent => '📷 ഷെൽഫ് ഫോട്ടോ';

  @override
  String get typeMessageHint => 'ഇവിടെ എഴുതുക…';

  @override
  String get send => 'അയക്കുക';

  @override
  String get thinking => 'ആലോചിക്കുന്നു…';

  @override
  String get networkError => 'കണക്റ്റ് ചെയ്യാനായില്ല. വീണ്ടും ശ്രമിക്കൂ.';

  @override
  String get comingSoon => 'ഉടൻ വരുന്നു! ഷെൽഫ് സ്കാൻ ഉടൻ ലഭ്യമാകും.';

  @override
  String get scanFailed => 'ഫോട്ടോ വ്യക്തമല്ല, വീണ്ടും ശ്രമിക്കൂ.';

  @override
  String get imageTooLarge =>
      'ഫോട്ടോ വളരെ വലുതാണ് (8 MB-യിൽ കൂടുതൽ). ചെറിയ ഫോട്ടോ ഉപയോഗിക്കൂ.';

  @override
  String get stockTitle => 'സ്റ്റോക്ക്';

  @override
  String get lowStockBadge => 'കുറവാണ്';

  @override
  String reorderAt(String level) {
    return '$level ആകുമ്പോൾ ഓർഡർ ചെയ്യുക';
  }

  @override
  String get emptyStock => 'സ്റ്റോക്കിൽ ഒന്നുമില്ല. വന്ന സാധനങ്ങൾ പറയൂ.';

  @override
  String get udhaarTitle => 'കടം';

  @override
  String get totalOutstanding => 'ആകെ ബാക്കി';

  @override
  String get emptyLedger =>
      'കടം ഒന്നും ബാക്കിയില്ല. \"Gupta ji-ക്ക് 350 രൂപ കടം കൊടുത്തു\" എന്ന് പറയൂ.';

  @override
  String get forecastTitle => 'കണക്കുകൂട്ടൽ';

  @override
  String get legendHistory => 'കഴിഞ്ഞ ആഴ്ച';

  @override
  String get legendForecast => 'കണക്കുകൂട്ടൽ';

  @override
  String get legendBand => 'പരിധി';

  @override
  String get orderReady => 'ഓർഡർ തയ്യാർ';

  @override
  String get shareWhatsapp => 'WhatsApp-ൽ അയക്കുക';

  @override
  String get copied => 'കോപ്പി ചെയ്തു';

  @override
  String get copy => 'കോപ്പി';

  @override
  String get retry => 'വീണ്ടും ശ്രമിക്കൂ';

  @override
  String get loading => 'ലോഡ് ചെയ്യുന്നു…';

  @override
  String get errorLoading =>
      'ലോഡ് ചെയ്യാനായില്ല. വീണ്ടും ശ്രമിക്കാൻ താഴേക്ക് വലിക്കൂ.';

  @override
  String get tagline => 'പറഞ്ഞാൽ മതി, കാര്യം നടക്കും.';

  @override
  String get languageQuestion => 'Mitra ഏത് ഭാഷയിൽ സംസാരിക്കണം?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'ഇത് പൂരിപ്പിക്കണം';

  @override
  String get dockPhoto => 'ഷെൽഫ് ഫോട്ടോ';

  @override
  String get dockType => 'എഴുതുക';

  @override
  String get micLabel => 'അമർത്തിപ്പിടിച്ച് പറയൂ';

  @override
  String get recordingLabel => 'കേൾക്കുന്നുണ്ട്… വിരൽ മാറ്റിയാൽ അയക്കും';

  @override
  String get recordingCancelHint => 'ക്യാൻസൽ ചെയ്യാൻ വിരൽ പുറത്തേക്ക് മാറ്റുക';

  @override
  String get confirmHeader => 'മനസ്സിലായി · രേഖപ്പെടുത്തി';

  @override
  String get confirmTotalUdhaar => 'കടം · ഇപ്പോഴത്തെ തുക';

  @override
  String get confirmTotalStock => 'സ്റ്റോക്ക് · ഇപ്പോഴത്തെ എണ്ണം';

  @override
  String get confirmTotalSale => 'വിൽപ്പന · ഇന്നത്തെ ആകെ';

  @override
  String get askHeader => 'ഉറപ്പില്ല';

  @override
  String askHeard(String text) {
    return 'നിങ്ങൾ പറഞ്ഞത് “$text”';
  }

  @override
  String get askStock => 'സ്റ്റോക്കിലേക്ക് ചേർക്കണോ?';

  @override
  String get askUdhaar => 'കടത്തിൽ എഴുതണോ?';

  @override
  String get askSale => 'വിൽപ്പനയിൽ എഴുതണോ?';

  @override
  String get askNo => 'വേണ്ട';

  @override
  String get askDeclined => 'ശരി, എഴുതിയിട്ടില്ല.';

  @override
  String scanHeader(int count) {
    return 'ഷെൽഫ് നോക്കി · $count സാധനങ്ങൾ കണ്ടെത്തി';
  }

  @override
  String get scanQuestion => 'സ്റ്റോക്ക് ഇങ്ങനെ മാറ്റണോ?';

  @override
  String get scanConfirmed => 'മനസ്സിലായി · സ്റ്റോക്ക് അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String stockSubtitle(int count, String time) {
    return '$count സാധനങ്ങൾ · അപ്ഡേറ്റ് $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count സാധനങ്ങൾ കുറവാണ്',
      one: '1 സാധനം കുറവാണ്',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'എല്ലാം കൃത്യമാണ്';

  @override
  String get orderButton => 'ഓർഡർ തയ്യാറാക്കുക';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ഓർഡർ തയ്യാറാക്കുക · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count പേർ · കടം പുസ്തകം';
  }

  @override
  String get balanceLabel => 'ബാക്കി';

  @override
  String todayGiven(String amount) {
    return 'ഇന്ന് കൊടുത്തത് +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'ഇന്ന് കിട്ടിയത് −₹$amount';
  }

  @override
  String get owedCaption => 'ബാക്കി';

  @override
  String get settledBadge => 'തീർത്തു';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount കിട്ടി';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'കടം തുടങ്ങിയത് $date · $count തവണ';
  }

  @override
  String lastEntryAt(String time) {
    return 'അവസാനം: $time';
  }

  @override
  String get remindButton => 'ഓർമ്മിപ്പിക്കുക';

  @override
  String get paidButton => 'പണം കിട്ടി';

  @override
  String get paidPrompt => 'എത്ര കിട്ടി? പറയൂ.';

  @override
  String get historyLabel => 'വിവരങ്ങൾ';

  @override
  String get entryGiven => 'കടം കൊടുത്തു';

  @override
  String get entryPaid => 'പണം കിട്ടി';

  @override
  String get entrySourceVoice => 'വോയ്‌സ്';

  @override
  String get entrySourceCash => 'പണം';

  @override
  String get entrySourcePhoto => 'ഫോട്ടോ';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'നമസ്കാരം $name ji, $shop-ൽ നിന്ന്. നിങ്ങളുടെ ₹$balance ബാക്കിയുണ്ട്. നന്ദി!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'അടുത്ത 4 ആഴ്ച · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'അടുത്ത 4 ആഴ്ച';

  @override
  String perWeek(String unit) {
    return '$unit / ആഴ്ച';
  }

  @override
  String get forecastFuture => 'വരും നാളുകൾ · കണക്കുകൂട്ടൽ';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'സ്റ്റോക്കിൽ $onHand · വാങ്ങേണ്ടത് $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count സാധനങ്ങൾ';
  }

  @override
  String get share => 'ഷെയർ';

  @override
  String get hisaabTitle => 'ഇന്നത്തെ കണക്ക്';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count വിവരങ്ങൾ';
  }

  @override
  String hisaabDayChip(String time) {
    return 'കട അടച്ചത് · $time';
  }

  @override
  String get hisaabSales => 'ഇന്നത്തെ വിൽപ്പന';

  @override
  String get hisaabGiven => 'കടം കൊടുത്തത്';

  @override
  String get hisaabReceived => 'കടം കിട്ടിയത്';

  @override
  String get hisaabOutstanding => 'ആകെ ബാക്കി';

  @override
  String get hisaabLow => 'കുറവാണ്';

  @override
  String hisaabLowItems(String items) {
    return '$items നാളെ വാങ്ങണം.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival-ന് ഇനി $weeks ആഴ്ച കൂടി.';
  }

  @override
  String get hisaabOrderButton => 'നാളത്തേക്ക് ഓർഡർ തയ്യാറാക്കുക';

  @override
  String get hisaabShareButton => 'WhatsApp-ൽ അയക്കുക';

  @override
  String todayChip(String date) {
    return 'ഇന്ന് · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'ഇന്നലെ · $date';
  }

  @override
  String get demoNotice => 'സെർവർ കിട്ടിയില്ല. ഡെമോ മോഡിൽ തുടങ്ങുന്നു.';

  @override
  String get languageSheetTitle => 'Mitra ഏത് ഭാഷയിൽ സംസാരിക്കണം?';

  @override
  String get backLabel => 'പുറകോട്ട്';

  @override
  String get voiceNoteLabel => 'വോയ്‌സ് നോട്ട്';

  @override
  String get undo => 'തിരുത്തുക';

  @override
  String get feedbackButton => 'അഭിപ്രായം';

  @override
  String get feedbackTitle => 'Kirana Mitra എങ്ങനെയുണ്ട്?';

  @override
  String get feedbackUp => 'കൊള്ളാം';

  @override
  String get feedbackDown => 'പോരാ';

  @override
  String get feedbackCommentHint => 'മറ്റെന്തെങ്കിലും പറയാനുണ്ടെങ്കിൽ എഴുതൂ…';

  @override
  String get feedbackVoiceHint => 'അല്ലെങ്കിൽ അമർത്തിപ്പിടിച്ച് പറയൂ';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'ശബ്ദം തയ്യാർ · ${seconds}s';
  }

  @override
  String get feedbackSend => 'അയക്കുക';

  @override
  String get feedbackPickRating => 'ആദ്യം കൊള്ളാമോ പോരയോ എന്ന് തിരഞ്ഞെടുക്കൂ';

  @override
  String get feedbackThanks => 'നന്ദി!';

  @override
  String get changeLanguage => 'ഭാഷ മാറ്റുക';

  @override
  String get languageSearchHint => 'ഭാഷ തിരയുക…';

  @override
  String get languageNoMatch => 'ഭാഷ കണ്ടെത്താനായില്ല';

  @override
  String get topSellersTitle => 'കൂടുതൽ വിൽക്കുന്നവ';

  @override
  String get topSellersSubtitle =>
      'കഴിഞ്ഞ 2 ആഴ്ച · അടുത്ത 2 ആഴ്ചയിലെ കണക്കുകൂട്ടൽ';

  @override
  String get autoBadge => 'ഓട്ടോ';

  @override
  String coverDays(String days) {
    return '$days ദിവസത്തെ സ്റ്റോക്ക്';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 ആഴ്ച';
  }

  @override
  String get autoRestockTitle =>
      'കൂടുതൽ വിൽക്കുന്നവ ഓട്ടോ-റീസ്റ്റോക്ക് ചെയ്യുക';

  @override
  String get autoRestockSubtitle =>
      'സ്റ്റോക്ക് കുറഞ്ഞവ രാത്രി തനിയെ ഓർഡർ ചെയ്യപ്പെടും';

  @override
  String get distributorPhoneLabel => 'സപ്ലയറുടെ WhatsApp നമ്പർ';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'സേവ് ചെയ്യുക';

  @override
  String get settingsSaved => 'സേവ് ചെയ്തു';

  @override
  String get ordersTitle => 'ഓർഡറുകൾ';

  @override
  String get ordersEmpty =>
      'ഓർഡറുകൾ ഒന്നുമില്ല. ഫോർകാസ്റ്റിൽ നിന്ന് ഓർഡർ തയ്യാറാക്കൂ.';

  @override
  String get orderAuto => 'ഓട്ടോ';

  @override
  String get orderManual => 'മാനുവൽ';

  @override
  String get orderPlaced => 'അയച്ചു';

  @override
  String get orderCancelled => 'ക്യാൻസൽ ചെയ്തു';

  @override
  String get viewOrders => 'ഓർഡറുകൾ കാണുക';

  @override
  String get newOrdersNotice => 'രാത്രിയിലെ ഓട്ടോ ഓർഡർ വന്നു';

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
