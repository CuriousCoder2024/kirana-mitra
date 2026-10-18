// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dogri (`doi`).
class AppLocalizationsDoi extends AppLocalizations {
  AppLocalizationsDoi([String locale = 'doi']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'दुकान दा नां';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'तुंदा नां';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'शुरू करो';

  @override
  String get requiredField => 'एह् भरो';

  @override
  String get navChat => 'गल्लबात';

  @override
  String get navStock => 'स्टॉक';

  @override
  String get navUdhaar => 'उधार';

  @override
  String get navForecast => 'अनुमान';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'डेमो';

  @override
  String get changeShop => 'दुकान बदलो';

  @override
  String welcomeMessage(String name) {
    return 'नमस्ते $name! दस्सो: केह् आया, केह् बिकेआ, किसे गी उधार दित्ता। माइक नप्पी रखियै बोलो।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'नमस्ते $name! बोलो: केह् आया, केह् बिकेआ, किसे गी उधार दित्ता। माइक नप्पी रखियै बोलो।';
  }

  @override
  String get recordingCancelled => 'छोड़ी दित्ता, कैंसिल होई गेआ';

  @override
  String get voiceTooShort => 'थोह्‌ड़ा होर नप्पी रखियै बोलो';

  @override
  String get micPermissionDenied => 'आवाज़ लेई माइक दी मंज़ूरी चाहिदी ऐ।';

  @override
  String get voiceNoteSent => '🎤 वॉयस नोट';

  @override
  String get photoSent => '📷 शैल्फ दी फोटो';

  @override
  String get typeMessageHint => 'इत्थै लिखो…';

  @override
  String get send => 'भेजो';

  @override
  String get thinking => 'सोचदा ऐ…';

  @override
  String get networkError =>
      'सर्वर कन्नै संपर्क नी होई सकेआ। परतियै कोशिश करो।';

  @override
  String get comingSoon => 'झटपट औग! शैल्फ स्कैन जल्द औने आला ऐ।';

  @override
  String get scanFailed => 'फोटो समझ नी आई, परतियै कोशिश करो।';

  @override
  String get imageTooLarge =>
      'फोटो मती बड्डी ऐ (8 MB कोला मती)। निक्की फोटो चुनो।';

  @override
  String get stockTitle => 'स्टॉक';

  @override
  String get lowStockBadge => 'घट्ट ऐ';

  @override
  String reorderAt(String level) {
    return '$level उप्पर परतियै मंगाओ';
  }

  @override
  String get emptyStock => 'अज्जै स्टॉक नी ऐ। बोलो केह् आया।';

  @override
  String get udhaarTitle => 'उधार';

  @override
  String get totalOutstanding => 'कुल बाकी';

  @override
  String get emptyLedger =>
      'अज्जै कोई उधार नी। बोलो \"Gupta ji गी 350 दा उधार दित्ता\"।';

  @override
  String get forecastTitle => 'अनुमान';

  @override
  String get legendHistory => 'पिछ्ले हफ्फे';

  @override
  String get legendForecast => 'अनुमान';

  @override
  String get legendBand => 'दायरा';

  @override
  String get orderReady => 'ऑर्डर त्यार';

  @override
  String get shareWhatsapp => 'WhatsApp पर भेजो';

  @override
  String get copied => 'कॉपी होई गेआ';

  @override
  String get copy => 'कॉपी';

  @override
  String get retry => 'परतियै कोशिश करो';

  @override
  String get loading => 'लोड होंदा ऐ…';

  @override
  String get errorLoading =>
      'लोड नी होई सकेआ। थल्ले खिच्चियै परतियै कोशिश करो।';

  @override
  String get tagline => 'बोलो, होई जाग।';

  @override
  String get languageQuestion => 'Mitra केह्ड़ी बोली च बोले?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'एह् भरो';

  @override
  String get dockPhoto => 'शैल्फ फोटो';

  @override
  String get dockType => 'लिखो';

  @override
  String get micLabel => 'नप्पी तै बोलो';

  @override
  String get recordingLabel => 'सुन्दा ऐ… छोड़ोगे तां भेजग';

  @override
  String get recordingCancelHint => 'रद्द करने लेई उंगली बाहर लै जाओ';

  @override
  String get confirmHeader => 'समझी गेआ · लिखी दित्ता';

  @override
  String get confirmTotalUdhaar => 'उधार · हुन कुल';

  @override
  String get confirmTotalStock => 'स्टॉक · हुन कुल';

  @override
  String get confirmTotalSale => 'बिक्री · अज्ज कुल';

  @override
  String get askHeader => 'पक्का नेईं';

  @override
  String askHeard(String text) {
    return 'तुस आखेआ “$text”';
  }

  @override
  String get askStock => 'स्टॉक च पावां?';

  @override
  String get askUdhaar => 'उधार च लिक्खां?';

  @override
  String get askSale => 'बिक्री च लिक्खां?';

  @override
  String get askNo => 'नेईं';

  @override
  String get askDeclined => 'ठीक ऐ, नी लिखेआ।';

  @override
  String scanHeader(int count) {
    return 'शैल्फ दिक्खेआ · $count चीज़ां लब्भियां';
  }

  @override
  String get scanQuestion => 'स्टॉक एह्‌गे सैट करी देआं?';

  @override
  String get scanConfirmed => 'समझी गेआ · स्टॉक अपडेट होई गेआ';

  @override
  String stockSubtitle(int count, String time) {
    return '$count चीज़ां · अपडेट $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चीज़ां घट्ट न',
      one: '1 चीज़ घट्ट ऐ',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'सब ठीक ऐ';

  @override
  String get orderButton => 'ऑर्डर बनाओ';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ऑर्डर बनाओ · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count लोक · बही-खाता';
  }

  @override
  String get balanceLabel => 'बाकी';

  @override
  String todayGiven(String amount) {
    return 'अज्ज दित्ता +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'अज्ज आया −₹$amount';
  }

  @override
  String get owedCaption => 'बाकी';

  @override
  String get settledBadge => 'चुक्ता';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount आया';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'उधार शुरू $date · $count प्रविष्टियां';
  }

  @override
  String lastEntryAt(String time) {
    return 'आखरी: $time';
  }

  @override
  String get remindButton => 'चेते कराओ';

  @override
  String get paidButton => 'पैसे आए';

  @override
  String get paidPrompt => 'केतने आए? बोलो।';

  @override
  String get historyLabel => 'इतिहास';

  @override
  String get entryGiven => 'उधार लैता';

  @override
  String get entryPaid => 'पैसे आए';

  @override
  String get entrySourceVoice => 'voice';

  @override
  String get entrySourceCash => 'cash';

  @override
  String get entrySourcePhoto => 'photo';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'नमस्ते $name जी, $shop थमां। तुंदा ₹$balance बाकी ऐ। धनबाद!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'अगले 4 हफ्फे · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'अगले 4 हफ्फे';

  @override
  String perWeek(String unit) {
    return '$unit / हफ्ता';
  }

  @override
  String get forecastFuture => 'अग्गें · अनुमान';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'स्टॉक च $onHand · मंगाओ $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count चीज़ां';
  }

  @override
  String get share => 'शेयर करो';

  @override
  String get hisaabTitle => 'अज्ज दा हसाब';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count प्रविष्टियां';
  }

  @override
  String hisaabDayChip(String time) {
    return 'दुकान बंद · $time';
  }

  @override
  String get hisaabSales => 'अज्ज दी बिक्री';

  @override
  String get hisaabGiven => 'उधार दित्ता';

  @override
  String get hisaabReceived => 'उधार आया';

  @override
  String get hisaabOutstanding => 'कुल बाकी';

  @override
  String get hisaabLow => 'घट्ट ऐ';

  @override
  String hisaabLowItems(String items) {
    return '$items कल्ल मंगाओ।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks हफ्फे दूर ऐ।';
  }

  @override
  String get hisaabOrderButton => 'कल्ल दा ऑर्डर बनाओ';

  @override
  String get hisaabShareButton => 'घरे WhatsApp करो';

  @override
  String todayChip(String date) {
    return 'अज्ज · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'कल्ल · $date';
  }

  @override
  String get demoNotice => 'सर्वर नी लब्भेआ। डेमो मोड च शुरू करदा ऐ।';

  @override
  String get languageSheetTitle => 'Mitra केह्ड़ी बोली च बोले?';

  @override
  String get backLabel => 'पिच्छें';

  @override
  String get voiceNoteLabel => 'वॉयस नोट';

  @override
  String get undo => 'परतो';

  @override
  String get feedbackButton => 'फीडबैक';

  @override
  String get feedbackTitle => 'Kirana Mitra कैह्‌सा चलदा ऐ?';

  @override
  String get feedbackUp => 'बढ़िया';

  @override
  String get feedbackDown => 'ठीक नेईं';

  @override
  String get feedbackCommentHint => 'किश होर दस्सना होऐ तां लिखो…';

  @override
  String get feedbackVoiceHint => 'यां नप्पी तै बोलो';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'आवाज़ त्यार · ${seconds}s';
  }

  @override
  String get feedbackSend => 'भेजो';

  @override
  String get feedbackPickRating => 'पैह्‌ले बढ़िया या ठीक नेईं चुनो';

  @override
  String get feedbackThanks => 'धनबाद!';

  @override
  String get changeLanguage => 'बोली बदलो';

  @override
  String get languageSearchHint => 'बोली टोह्‌लो…';

  @override
  String get languageNoMatch => 'कोई बोली नी लब्भी';

  @override
  String get topSellersTitle => 'टॉप सेलर';

  @override
  String get topSellersSubtitle => 'पिछ्ले 2 हफ्फे · अगले 2 हफ्फें दा अनुमान';

  @override
  String get autoBadge => 'ऑटो';

  @override
  String coverDays(String days) {
    return '$days दिनें दा स्टॉक';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 हफ्फे';
  }

  @override
  String get autoRestockTitle => 'टॉप सेलर गी आपू रिस्टॉक करो';

  @override
  String get autoRestockSubtitle =>
      'घट्ट स्टॉक आले टॉप सेलरें दा ऑर्डर राती आपू चली जग';

  @override
  String get distributorPhoneLabel => 'डिस्ट्रीब्यूटर दा WhatsApp नंबर';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'सेव करो';

  @override
  String get settingsSaved => 'सेव होई गेआ';

  @override
  String get ordersTitle => 'ऑर्डर';

  @override
  String get ordersEmpty => 'अज्जै कोई ऑर्डर नेईं। अनुमान थमां ऑर्डर बनाओ।';

  @override
  String get orderAuto => 'ऑटो';

  @override
  String get orderManual => 'मैनुअल';

  @override
  String get orderPlaced => 'भेजेआ';

  @override
  String get orderCancelled => 'कैंसिल होई गेआ';

  @override
  String get viewOrders => 'ऑर्डर दिक्खो';

  @override
  String get newOrdersNotice => 'राती दा ऑटो ऑर्डर आया';

  @override
  String get shopReRegistered =>
      'Server restart hua, dukaan phir se register ki.';
}
