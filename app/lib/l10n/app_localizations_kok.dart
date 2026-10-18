// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Konkani (`kok`).
class AppLocalizationsKok extends AppLocalizations {
  AppLocalizationsKok([String locale = 'kok']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'दुकानचें नांव';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'तुमचें नांव';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'सुरू करात';

  @override
  String get requiredField => 'उपकार करून हें भरात';

  @override
  String get navChat => 'उलोवप';

  @override
  String get navStock => 'स्टॉक';

  @override
  String get navUdhaar => 'उदारी';

  @override
  String get navForecast => 'अंदाज';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'डेमो';

  @override
  String get changeShop => 'दुकान बदलात';

  @override
  String welcomeMessage(String name) {
    return 'नमस्कार $name! कितें आयलें, कितें विकलें वा कोणाक उदार दिलें तें सांगात. माइक दाबून धरा आनी उलयात.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'नमस्कार $name! सांगात: कितें आयलें, कितें विकलें, कोणाक उदार दिलें. माइक दाबून धरा आनी उलयात.';
  }

  @override
  String get recordingCancelled => 'सोडून दिया, रद्द जालें';

  @override
  String get voiceTooShort => 'मात्शें चड वेळ दाबून धरा आनी उलयात';

  @override
  String get micPermissionDenied => 'व्हॉईस नोट खातीर मायक्रोफोन परवानगी जाय.';

  @override
  String get voiceNoteSent => '🎤 व्हॉईस नोट';

  @override
  String get photoSent => '📷 शेल्फ फोटो';

  @override
  String get typeMessageHint => 'हांगा बरयात…';

  @override
  String get send => 'धाडा';

  @override
  String get thinking => 'विचार करता…';

  @override
  String get networkError => 'सर्व्हर मेळूंक ना. परतून यत्न करात.';

  @override
  String get comingSoon => 'रोखडेंच येतलो! शेल्फ स्कॅन बेगीन येतलो.';

  @override
  String get scanFailed => 'फोटो समजलो ना, परतून यत्न करात.';

  @override
  String get imageTooLarge => 'फोटो खूब व्हड आसा (8 MB वयर). ल्हान फोटो धाडा.';

  @override
  String get stockTitle => 'स्टॉक';

  @override
  String get lowStockBadge => 'उणें आसा';

  @override
  String reorderAt(String level) {
    return '$level चेर परतून मागायात';
  }

  @override
  String get emptyStock => 'सद्या स्टॉक ना. कितें आयलां तें सांगात.';

  @override
  String get udhaarTitle => 'उदारी';

  @override
  String get totalOutstanding => 'एकूण बाकी';

  @override
  String get emptyLedger =>
      'सद्या कांयच उदारी ना. \"गुप्ताजीक 350 ची उदारी दिली\" अशें सांगात.';

  @override
  String get forecastTitle => 'अंदाज';

  @override
  String get legendHistory => 'फाटलो सप्तक';

  @override
  String get legendForecast => 'अंदाज';

  @override
  String get legendBand => 'मर्यादा';

  @override
  String get orderReady => 'ऑर्डर तयार';

  @override
  String get shareWhatsapp => 'WhatsApp चेर धाडा';

  @override
  String get copied => 'कॉपी जालें';

  @override
  String get copy => 'कॉपी';

  @override
  String get retry => 'परतून यत्न करा';

  @override
  String get loading => 'लोड जाता…';

  @override
  String get errorLoading => 'लोड जावंक ना. सकयल ओडून परतून यत्न करात.';

  @override
  String get tagline => 'उलयात, काम जातलें.';

  @override
  String get languageQuestion => 'मित्र खंयचे भाशेंत उलयतलो?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'हें भरात';

  @override
  String get dockPhoto => 'शेल्फ फोटो';

  @override
  String get dockType => 'बरयात';

  @override
  String get micLabel => 'दाबून उलयात';

  @override
  String get recordingLabel => 'आयकता… सोडटकच धाडतलो';

  @override
  String get recordingCancelHint => 'रद्द करपाक बोट भायर व्हरयात';

  @override
  String get confirmHeader => 'समजलें · बरोवन घेतलें';

  @override
  String get confirmTotalUdhaar => 'उदारी · आतां एकूण';

  @override
  String get confirmTotalStock => 'स्टॉक · आतां एकूण';

  @override
  String get confirmTotalSale => 'विक्री · आज एकूण';

  @override
  String get askHeader => 'खात्री ना';

  @override
  String askHeard(String text) {
    return 'तुमी म्हळें “$text”';
  }

  @override
  String get askStock => 'स्टॉकांत घालूं?';

  @override
  String get askUdhaar => 'उदारींत बरोवूं?';

  @override
  String get askSale => 'विक्रींत बरोवूं?';

  @override
  String get askNo => 'नाका';

  @override
  String get askDeclined => 'ठीक आसा, बरोवंक ना.';

  @override
  String scanHeader(int count) {
    return 'शेल्फ पळयलें · $count वस्तू मेळ्ळ्यो';
  }

  @override
  String get scanQuestion => 'स्टॉक होच दवरूं?';

  @override
  String get scanConfirmed => 'समजलें · स्टॉक अपडेट जालो';

  @override
  String stockSubtitle(int count, String time) {
    return '$count वस्तू · अपडेट $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू उण्यो आसात',
      one: '1 वस्तू उणी आसा',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'सगळें ठीक आसा';

  @override
  String get orderButton => 'ऑर्डर करात';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ऑर्डर करात · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count लोक · बही-खातें';
  }

  @override
  String get balanceLabel => 'बाकी';

  @override
  String todayGiven(String amount) {
    return 'आज दिलें +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'आज आयलें −₹$amount';
  }

  @override
  String get owedCaption => 'बाकी';

  @override
  String get settledBadge => 'चुकतें जालें';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount आयले';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'उदारी सुरू $date · $count नोंदी';
  }

  @override
  String lastEntryAt(String time) {
    return 'निमाणें: $time';
  }

  @override
  String get remindButton => 'उगडास करात';

  @override
  String get paidButton => 'पयशे आयले';

  @override
  String get paidPrompt => 'कितले आयले? सांगात.';

  @override
  String get historyLabel => 'इतिहास';

  @override
  String get entryGiven => 'उदारी घेतली';

  @override
  String get entryPaid => 'पयशे आयले';

  @override
  String get entrySourceVoice => 'आवाज';

  @override
  String get entrySourceCash => 'रोकड';

  @override
  String get entrySourcePhoto => 'फोटो';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'नमस्कार $name जी, $shop कडल्यान. तुमची ₹$balance बाकी आसा. देव बरें करूं!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'फुडले 4 सप्तक · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'फुडले 4 सप्तक';

  @override
  String perWeek(String unit) {
    return '$unit / सप्तक';
  }

  @override
  String get forecastFuture => 'फुडारांत · अंदाज';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'स्टॉकांत $onHand · मागायात $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count वस्तू';
  }

  @override
  String get share => 'शेअर करात';

  @override
  String get hisaabTitle => 'आजचो हिशोब';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count नोंदी';
  }

  @override
  String hisaabDayChip(String time) {
    return 'दुकान बंद · $time';
  }

  @override
  String get hisaabSales => 'आजची विक्री';

  @override
  String get hisaabGiven => 'उदारी दिली';

  @override
  String get hisaabReceived => 'उदारी आयली';

  @override
  String get hisaabOutstanding => 'एकूण बाकी';

  @override
  String get hisaabLow => 'उणें आसा';

  @override
  String hisaabLowItems(String items) {
    return '$items फाल्यां मागायात.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks सप्तक पयस आसा.';
  }

  @override
  String get hisaabOrderButton => 'फाल्यांची ऑर्डर तयार करात';

  @override
  String get hisaabShareButton => 'घरा WhatsApp करात';

  @override
  String todayChip(String date) {
    return 'आज · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'काल · $date';
  }

  @override
  String get demoNotice => 'सर्व्हर मेळूंक ना. डेमो मोडांत सुरू करतां.';

  @override
  String get languageSheetTitle => 'मित्र खंयचे भाशेंत उलयतलो?';

  @override
  String get backLabel => 'फाटीं';

  @override
  String get voiceNoteLabel => 'व्हॉईस नोट';

  @override
  String get undo => 'फाटीं घेयात';

  @override
  String get feedbackButton => 'प्रतिक्रिया';

  @override
  String get feedbackTitle => 'Kirana Mitra कसो चलता?';

  @override
  String get feedbackUp => 'बरो';

  @override
  String get feedbackDown => 'बरो ना';

  @override
  String get feedbackCommentHint => 'आनीक कितें सांगपाचें आसा जाल्यार बरयात…';

  @override
  String get feedbackVoiceHint => 'ना जाल्यार दाबून उलयात';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'आवाज तयार · ${seconds}s';
  }

  @override
  String get feedbackSend => 'धाडा';

  @override
  String get feedbackPickRating => 'पयलीं बरो वा बरो ना तें वेंचून काडात';

  @override
  String get feedbackThanks => 'देव बरें करूं!';

  @override
  String get changeLanguage => 'भास बदलात';

  @override
  String get languageSearchHint => 'भास सोदात…';

  @override
  String get languageNoMatch => 'भास मेळ्ळी ना';

  @override
  String get topSellersTitle => 'चड विकपी माल';

  @override
  String get topSellersSubtitle => 'फाटले 2 सप्तक · फुडल्या 2 सप्तकांचो अंदाज';

  @override
  String get autoBadge => 'ऑटो';

  @override
  String coverDays(String days) {
    return '$days दिसांचो स्टॉक';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 सप्तक';
  }

  @override
  String get autoRestockTitle => 'चड विकपी मालाचो ऑटो-रीस्टॉक';

  @override
  String get autoRestockSubtitle =>
      'उण्या स्टॉकाचो चड विकपी माल रातचो आपशींच ऑर्डर जातलो';

  @override
  String get distributorPhoneLabel => 'डिस्ट्रिब्युटराचो WhatsApp नंबर';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'सांबाळा';

  @override
  String get settingsSaved => 'सांबाळ्ळें';

  @override
  String get ordersTitle => 'ऑर्डर्स';

  @override
  String get ordersEmpty =>
      'सद्या कसलीच ऑर्डर ना. अंदाजांतल्यान ऑर्डर तयार करात.';

  @override
  String get orderAuto => 'ऑटो';

  @override
  String get orderManual => 'मॅन्युअल';

  @override
  String get orderPlaced => 'धाडला';

  @override
  String get orderCancelled => 'रद्द जाला';

  @override
  String get viewOrders => 'ऑर्डर्स पळयात';

  @override
  String get newOrdersNotice => 'रातीची ऑटो ऑर्डर आयली';
}
