// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Maithili (`mai`).
class AppLocalizationsMai extends AppLocalizations {
  AppLocalizationsMai([String locale = 'mai']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'दुकानक नाम';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'अहाँक नाम';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'शुरू करू';

  @override
  String get requiredField => 'ई भरब जरूरी अछि';

  @override
  String get navChat => 'बात';

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
  String get changeShop => 'दुकान बदलू';

  @override
  String welcomeMessage(String name) {
    return 'प्रणाम $name! कहू की आयल, की बिकल, वा के उधार लेलक। माइक दबा कऽ राखू आ बोलू।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'प्रणाम $name! बोलू: की आयल, की बिकल, ककरा उधार देलहुँ। माइक दबा कऽ राखू आ बोलू।';
  }

  @override
  String get recordingCancelled => 'छोड़ू, कैंसिल भऽ गेल';

  @override
  String get voiceTooShort => 'माइक थोकबे बेसी देर दबा कऽ बोलू';

  @override
  String get micPermissionDenied => 'वॉइस नोट लेल माइकक अनुमति चाही।';

  @override
  String get voiceNoteSent => '🎤 वॉइस नोट';

  @override
  String get photoSent => '📷 शेल्फ फोटो';

  @override
  String get typeMessageHint => 'एतय लिखू…';

  @override
  String get send => 'भेजू';

  @override
  String get thinking => 'सोचि रहल छी…';

  @override
  String get networkError => 'सर्वर सँ संपर्क नहि भेल। फेर कोशिश करू।';

  @override
  String get comingSoon => 'जल्दिए आबि रहल अछि! शेल्फ स्कैन जल्दिए अयता।';

  @override
  String get scanFailed => 'फोटो समझ मे नहि आयल, फेर कोशिश करू।';

  @override
  String get imageTooLarge =>
      'फोटो बेसी पैघ अछि (8 MB सँ बेसी)। छोट फोटो खिंचू।';

  @override
  String get stockTitle => 'स्टॉक';

  @override
  String get lowStockBadge => 'कम अछि';

  @override
  String reorderAt(String level) {
    return '$level पर फेर मंगाऊ';
  }

  @override
  String get emptyStock => 'एखन स्टॉक नहि अछि। बोलू की आयल।';

  @override
  String get udhaarTitle => 'उधार';

  @override
  String get totalOutstanding => 'कुल बाकी';

  @override
  String get emptyLedger =>
      'एखन कोनो उधार नहि अछि। बोलू \"गुप्ता जी कें 350 केर उधार देलियनि\"।';

  @override
  String get forecastTitle => 'अनुमान';

  @override
  String get legendHistory => 'पिछिला सप्ताह';

  @override
  String get legendForecast => 'अनुमान';

  @override
  String get legendBand => 'दायरा';

  @override
  String get orderReady => 'ऑर्डर तैयार';

  @override
  String get shareWhatsapp => 'WhatsApp पर भेजू';

  @override
  String get copied => 'कॉपी भऽ गेल';

  @override
  String get copy => 'कॉपी करू';

  @override
  String get retry => 'फेर कोशिश करू';

  @override
  String get loading => 'लोड भऽ रहल अछि…';

  @override
  String get errorLoading => 'लोड नहि भेल। नीचाँ खींचि कऽ फेर कोशिश करू।';

  @override
  String get tagline => 'बोलू, भऽ जाएत।';

  @override
  String get languageQuestion => 'Mitra कोन् भाषा मे बाजय?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'ई भरू';

  @override
  String get dockPhoto => 'शेल्फ फोटो';

  @override
  String get dockType => 'लिखू';

  @override
  String get micLabel => 'दबा कऽ बोलू';

  @override
  String get recordingLabel => 'सुनि रहल छी… छोड़ला पर जेता';

  @override
  String get recordingCancelHint => 'कैंसिल लेल आँगुर बाहर खींचू';

  @override
  String get confirmHeader => 'बुझि गेलहुँ · लिखि देलहुँ';

  @override
  String get confirmTotalUdhaar => 'उधार · आब कुल';

  @override
  String get confirmTotalStock => 'स्टॉक · आब कुल';

  @override
  String get confirmTotalSale => 'बिक्री · आइ कुल';

  @override
  String get askHeader => 'पक्का नहि';

  @override
  String askHeard(String text) {
    return 'अहाँ कहलहुँ “$text”';
  }

  @override
  String get askStock => 'स्टॉक मे जोड़ी?';

  @override
  String get askUdhaar => 'उधार मे लिखी?';

  @override
  String get askSale => 'बिक्री मे लिखी?';

  @override
  String get askNo => 'नहि';

  @override
  String get askDeclined => 'ठीक अछि, नहि लिखलहुँ।';

  @override
  String scanHeader(int count) {
    return 'शेल्फ देखलहुँ · $count जिनिस भेटल';
  }

  @override
  String get scanQuestion => 'स्टॉक इहै सेट कऽ दी?';

  @override
  String get scanConfirmed => 'बुझि गेलहुँ · स्टॉक अपडेट भऽ गेल';

  @override
  String stockSubtitle(int count, String time) {
    return '$count जिनिस · अपडेट $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टा जिनिस कम अछि',
      one: '1 टा जिनिस कम अछि',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'सब ठीक अछि';

  @override
  String get orderButton => 'ऑर्डर बनाऊ';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ऑर्डर बनाऊ · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count गोटा · बही-खाता';
  }

  @override
  String get balanceLabel => 'बाकी';

  @override
  String todayGiven(String amount) {
    return 'आइ देलहुँ +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'आइ आयल −₹$amount';
  }

  @override
  String get owedCaption => 'बाकी';

  @override
  String get settledBadge => 'चुकता';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount आयल';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'उधार शुरू $date · $count एंट्री';
  }

  @override
  String lastEntryAt(String time) {
    return 'अंतिम: $time';
  }

  @override
  String get remindButton => 'याद दिआऊ';

  @override
  String get paidButton => 'पैसा आयल';

  @override
  String get paidPrompt => 'कतबे आयल? बोलू।';

  @override
  String get historyLabel => 'हिस्ट्री';

  @override
  String get entryGiven => 'उधार देल';

  @override
  String get entryPaid => 'पैसा आयल';

  @override
  String get entrySourceVoice => 'voice';

  @override
  String get entrySourceCash => 'cash';

  @override
  String get entrySourcePhoto => 'photo';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'प्रणाम $name जी, $shop सँ। अहाँक ₹$balance बाकी अछि। धन्यवाद!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'आगाँक 4 सप्ताह · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'आगाँक 4 सप्ताह';

  @override
  String perWeek(String unit) {
    return '$unit / सप्ताह';
  }

  @override
  String get forecastFuture => 'आगाँ · अनुमान';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'स्टॉक मे $onHand · मंगाऊ $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count जिनिस';
  }

  @override
  String get share => 'शेयर करू';

  @override
  String get hisaabTitle => 'आइक हिसाब';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count एंट्री';
  }

  @override
  String hisaabDayChip(String time) {
    return 'दुकान बंद · $time';
  }

  @override
  String get hisaabSales => 'आइक बिक्री';

  @override
  String get hisaabGiven => 'उधार देलहुँ';

  @override
  String get hisaabReceived => 'उधार आयल';

  @override
  String get hisaabOutstanding => 'कुल बाकी';

  @override
  String get hisaabLow => 'कम अछि';

  @override
  String hisaabLowItems(String items) {
    return '$items काल्हि मंगाऊ।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks सप्ताह दूर अछि।';
  }

  @override
  String get hisaabOrderButton => 'काल्हिक ऑर्डर बनाऊ';

  @override
  String get hisaabShareButton => 'घर पर WhatsApp करू';

  @override
  String todayChip(String date) {
    return 'आइ · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'काल्हि · $date';
  }

  @override
  String get demoNotice => 'सर्वर नहि भेटल। डेमो मोड मे शुरू कऽ रहल छी।';

  @override
  String get languageSheetTitle => 'Mitra कोन् भाषा मे बाजय?';

  @override
  String get backLabel => 'पाछाँ';

  @override
  String get voiceNoteLabel => 'वॉइस नोट';

  @override
  String get undo => 'वापस';

  @override
  String get feedbackButton => 'फीडबैक';

  @override
  String get feedbackTitle => 'Kirana Mitra कहेन चलि रहल अछि?';

  @override
  String get feedbackUp => 'नीक';

  @override
  String get feedbackDown => 'ठीक नहि';

  @override
  String get feedbackCommentHint => 'किछु आर कहबाक हो तँ लिखू…';

  @override
  String get feedbackVoiceHint => 'वा दबा कऽ बोलू';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'आवाज तैयार · ${seconds}s';
  }

  @override
  String get feedbackSend => 'भेजू';

  @override
  String get feedbackPickRating => 'पहने नीक वा ठीक नहि चुनू';

  @override
  String get feedbackThanks => 'धन्यवाद!';

  @override
  String get changeLanguage => 'भाषा बदलू';

  @override
  String get languageSearchHint => 'भाषा खोजू…';

  @override
  String get languageNoMatch => 'कोनो भाषा नहि भेटल';

  @override
  String get topSellersTitle => 'बेसी बिकय बला';

  @override
  String get topSellersSubtitle => 'पिछिला 2 सप्ताह · आगाँक 2 सप्ताहक अनुमान';

  @override
  String get autoBadge => 'ऑटो';

  @override
  String coverDays(String days) {
    return '$days दिनक स्टॉक';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 सप्ताह';
  }

  @override
  String get autoRestockTitle => 'बेसी बिकय बला सामानक ऑटो-रीस्टॉक';

  @override
  String get autoRestockSubtitle =>
      'कम स्टॉक बला बेसी बिकय बला सामानक ऑर्डर राति मे अपने आप जाएत';

  @override
  String get distributorPhoneLabel => 'डिस्ट्रिब्यूटरक WhatsApp नंबर';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'सेव करू';

  @override
  String get settingsSaved => 'सेव भऽ गेल';

  @override
  String get ordersTitle => 'ऑर्डर्स';

  @override
  String get ordersEmpty => 'एखन कोनो ऑर्डर नहि अछि। अनुमान सँ ऑर्डर बनाऊ।';

  @override
  String get orderAuto => 'ऑटो';

  @override
  String get orderManual => 'मैनुअल';

  @override
  String get orderPlaced => 'भेजल गेल';

  @override
  String get orderCancelled => 'कैंसिल भऽ गेल';

  @override
  String get viewOrders => 'ऑर्डर्स देखू';

  @override
  String get newOrdersNotice => 'रातिक ऑटो ऑर्डर आयल';

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
