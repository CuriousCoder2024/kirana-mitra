// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'पसलको नाम';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'तपाईंको नाम';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'सुरु गरौँ';

  @override
  String get requiredField => 'कृपया यो भर्नुहोस्';

  @override
  String get navChat => 'कुराकानी';

  @override
  String get navStock => 'स्टक';

  @override
  String get navUdhaar => 'उधारो';

  @override
  String get navForecast => 'अनुमान';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'डेमो';

  @override
  String get changeShop => 'पसल फेर्नुहोस्';

  @override
  String welcomeMessage(String name) {
    return 'नमस्ते $name! के सामान आयो, के बिक्री भयो, वा कसले उधारो लग्यो भन्नुहोस्। माइक थिचेर बोल्नुहोस्।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'नमस्ते $name! भन्नुहोस्: के आयो, के बिक्री भयो, कसलाई उधारो दिनुभयो। माइक थिचेर बोल्नुहोस्।';
  }

  @override
  String get recordingCancelled => 'छोड्नुभयो, रद्द भयो';

  @override
  String get voiceTooShort => 'अलि बेर थिचेर बोल्नुहोस्';

  @override
  String get micPermissionDenied =>
      'भ्वाइस नोटका लागि माइक्रोफोनको अनुमति चाहिन्छ।';

  @override
  String get voiceNoteSent => '🎤 भ्वाइस नोट';

  @override
  String get photoSent => '📷 र्‍याकको फोटो';

  @override
  String get typeMessageHint => 'यहाँ लेख्नुहोस्…';

  @override
  String get send => 'पठाउनुहोस्';

  @override
  String get thinking => 'सोच्दैछ…';

  @override
  String get networkError => 'सर्भरसँग सम्पर्क भएन। फेरि प्रयास गर्नुहोस्।';

  @override
  String get comingSoon => 'चाँडै आउँदैछ! र्‍याक स्क्यान सुविधा छिट्टै आउनेछ।';

  @override
  String get scanFailed => 'फोटो बुझिएन, फेरि प्रयास गर्नुहोस्।';

  @override
  String get imageTooLarge =>
      'फोटो धेरै ठूलो भयो (8 MB भन्दा बढी)। सानो फोटो हाल्नुहोस्।';

  @override
  String get stockTitle => 'स्टक';

  @override
  String get lowStockBadge => 'कम छ';

  @override
  String reorderAt(String level) {
    return '$level मा पुनः अर्डर';
  }

  @override
  String get emptyStock => 'अहिले स्टक छैन। के सामान आयो, बोल्नुहोस्।';

  @override
  String get udhaarTitle => 'उधारो';

  @override
  String get totalOutstanding => 'कुल बाँकी';

  @override
  String get emptyLedger =>
      'अहिले कुनै उधारो छैन। बोल्नुहोस् \"गुप्ता जीलाई 350 को उधारो दिएँ\"।';

  @override
  String get forecastTitle => 'अनुमान';

  @override
  String get legendHistory => 'अघिल्लो हप्ता';

  @override
  String get legendForecast => 'अनुमान';

  @override
  String get legendBand => 'दायरा';

  @override
  String get orderReady => 'अर्डर तयार';

  @override
  String get shareWhatsapp => 'WhatsApp मा पठाउनुहोस्';

  @override
  String get copied => 'कपी भयो';

  @override
  String get copy => 'कपी';

  @override
  String get retry => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get loading => 'लोड हुँदैछ…';

  @override
  String get errorLoading => 'लोड हुन सकेन। तल तानेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get tagline => 'बोल्नुहोस्, भइहाल्छ।';

  @override
  String get languageQuestion => 'Mitra कुन भाषामा बोलोस्?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'यो भर्नुहोस्';

  @override
  String get dockPhoto => 'र्‍याकको फोटो';

  @override
  String get dockType => 'लेख्नुहोस्';

  @override
  String get micLabel => 'थिचेर बोल्नुहोस्';

  @override
  String get recordingLabel => 'सुन्दैछु… छोडेपछि पठाइनेछ';

  @override
  String get recordingCancelHint => 'रद्द गर्न औँला बाहिर लैजानुहोस्';

  @override
  String get confirmHeader => 'बुझेँ · लेखिदिएँ';

  @override
  String get confirmTotalUdhaar => 'उधारो · कुल जम्मा';

  @override
  String get confirmTotalStock => 'स्टक · कुल जम्मा';

  @override
  String get confirmTotalSale => 'बिक्री · आजको जम्मा';

  @override
  String get askHeader => 'पक्का भएन';

  @override
  String askHeard(String text) {
    return 'तपाईंले भन्नुभयो “$text”';
  }

  @override
  String get askStock => 'स्टकमा थपौँ?';

  @override
  String get askUdhaar => 'उधारोमा लेखौँ?';

  @override
  String get askSale => 'बिक्रीमा लेखौँ?';

  @override
  String get askNo => 'होइन';

  @override
  String get askDeclined => 'हुन्छ, लेखिनँ।';

  @override
  String scanHeader(int count) {
    return 'र्‍याक हेरियो · $count सामान भेटियो';
  }

  @override
  String get scanQuestion => 'स्टक यही राखौँ?';

  @override
  String get scanConfirmed => 'बुझेँ · स्टक अपडेट भयो';

  @override
  String stockSubtitle(int count, String time) {
    return '$count सामान · अपडेट $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामान कम छन्',
      one: '1 सामान कम छ',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'सबै ठीक छ';

  @override
  String get orderButton => 'अर्डर बनाउनुहोस्';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'अर्डर बनाउनुहोस् · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count जना · खाता';
  }

  @override
  String get balanceLabel => 'बाँकी';

  @override
  String todayGiven(String amount) {
    return 'आज दिएको +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'आज आएको −₹$amount';
  }

  @override
  String get owedCaption => 'बाँकी';

  @override
  String get settledBadge => 'चुक्ता';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount आयो';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'उधारो सुरु $date · $count हिसाब';
  }

  @override
  String lastEntryAt(String time) {
    return 'अन्तिम: $time';
  }

  @override
  String get remindButton => 'सम्झाउनुहोस्';

  @override
  String get paidButton => 'पैसा आयो';

  @override
  String get paidPrompt => 'कति आयो? बोल्नुहोस्।';

  @override
  String get historyLabel => 'विवरण';

  @override
  String get entryGiven => 'उधारो लग्यो';

  @override
  String get entryPaid => 'पैसा आयो';

  @override
  String get entrySourceVoice => 'आवाज';

  @override
  String get entrySourceCash => 'नगद';

  @override
  String get entrySourcePhoto => 'फोटो';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'नमस्ते $name जी, $shop बाट। तपाईंको ₹$balance बाँकी छ। धन्यवाद!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'आउँदो 4 हप्ता · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'आउँदो 4 हप्ता';

  @override
  String perWeek(String unit) {
    return '$unit / हप्ता';
  }

  @override
  String get forecastFuture => 'अगाडि · अनुमान';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'स्टकमा $onHand · मगाउनुहोस् $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count सामान';
  }

  @override
  String get share => 'सेयर';

  @override
  String get hisaabTitle => 'आजको हिसाब';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count हिसाब';
  }

  @override
  String hisaabDayChip(String time) {
    return 'पसल बन्द · $time';
  }

  @override
  String get hisaabSales => 'आजको बिक्री';

  @override
  String get hisaabGiven => 'उधारो दिएको';

  @override
  String get hisaabReceived => 'उधारो उठेको';

  @override
  String get hisaabOutstanding => 'कुल बाँकी';

  @override
  String get hisaabLow => 'कम छ';

  @override
  String hisaabLowItems(String items) {
    return '$items भोलि मगाउनुहोस्।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks हप्ता बाँकी छ।';
  }

  @override
  String get hisaabOrderButton => 'भोलिको अर्डर बनाउनुहोस्';

  @override
  String get hisaabShareButton => 'घरमा WhatsApp गर्नुहोस्';

  @override
  String todayChip(String date) {
    return 'आज · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'हिजो · $date';
  }

  @override
  String get demoNotice => 'सर्भर भेटिएन। डेमो मोडमा सुरु गर्दैछु।';

  @override
  String get languageSheetTitle => 'Mitra कुन भाषामा बोलोस्?';

  @override
  String get backLabel => 'पछाडि';

  @override
  String get voiceNoteLabel => 'भ्वाइस नोट';

  @override
  String get undo => 'फिर्ता';

  @override
  String get feedbackButton => 'प्रतिक्रिया';

  @override
  String get feedbackTitle => 'Kirana Mitra कस्तो चल्दैछ?';

  @override
  String get feedbackUp => 'राम्रो';

  @override
  String get feedbackDown => 'राम्रो छैन';

  @override
  String get feedbackCommentHint => 'अरू केही भन्नु छ भने लेख्नुहोस्…';

  @override
  String get feedbackVoiceHint => 'वा थिचेर बोल्नुहोस्';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'आवाज तयार · ${seconds}s';
  }

  @override
  String get feedbackSend => 'पठाउनुहोस्';

  @override
  String get feedbackPickRating => 'पहिले राम्रो वा राम्रो छैन रोज्नुहोस्';

  @override
  String get feedbackThanks => 'धन्यवाद!';

  @override
  String get changeLanguage => 'भाषा फेर्नुहोस्';

  @override
  String get languageSearchHint => 'भाषा खोज्नुहोस्…';

  @override
  String get languageNoMatch => 'कुनै भाषा भेटिएन';

  @override
  String get topSellersTitle => 'धेरै बिक्री हुने सामान';

  @override
  String get topSellersSubtitle => 'अघिल्लो 2 हप्ता · आउँदो 2 हप्ताको अनुमान';

  @override
  String get autoBadge => 'अटो';

  @override
  String coverDays(String days) {
    return '$days दिनको स्टक';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 हप्ता';
  }

  @override
  String get autoRestockTitle => 'धेरै बिक्री हुने सामान स्वतः अर्डर';

  @override
  String get autoRestockSubtitle =>
      'कम स्टक भएका सामानको अर्डर राति आफैँ जानेछ';

  @override
  String get distributorPhoneLabel => 'डिस्टिब्युटरको WhatsApp नम्बर';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'सेभ गर्नुहोस्';

  @override
  String get settingsSaved => 'सेभ भयो';

  @override
  String get ordersTitle => 'अर्डरहरू';

  @override
  String get ordersEmpty => 'अहिले कुनै अर्डर छैन। अनुमानबाट अर्डर बनाउनुहोस्।';

  @override
  String get orderAuto => 'अटो';

  @override
  String get orderManual => 'म्यानुअल';

  @override
  String get orderPlaced => 'पठाइयो';

  @override
  String get orderCancelled => 'रद्द भयो';

  @override
  String get viewOrders => 'अर्डरहरू हेर्नुहोस्';

  @override
  String get newOrdersNotice => 'रातिको अटो अर्डर आयो';

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

  @override
  String get askYes => 'Haan, add karo';
}
