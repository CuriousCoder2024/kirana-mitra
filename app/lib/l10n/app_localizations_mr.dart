// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'दुकानाचे नाव';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'तुमचे नाव';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'सुरू करा';

  @override
  String get requiredField => 'कृपया हे भरा';

  @override
  String get navChat => 'बोला';

  @override
  String get navStock => 'स्टॉक';

  @override
  String get navUdhaar => 'उधारी';

  @override
  String get navForecast => 'अंदाज';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'डेमो';

  @override
  String get changeShop => 'दुकान बदला';

  @override
  String welcomeMessage(String name) {
    return 'नमस्ते $name! काय आले, काय विकले, किंवा कोणाला उधारी दिली ते सांगा. माइक दाबून बोला.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'नमस्ते $name! बोला: काय आले, काय विकले, कोणाला उधारी दिली. माइक दाबून ठेवा आणि बोला.';
  }

  @override
  String get recordingCancelled => 'सोडून दिले, रद्द झाले';

  @override
  String get voiceTooShort => 'माइक थोडा वेळ दाबून ठेवा आणि बोला';

  @override
  String get micPermissionDenied =>
      'व्हॉइस नोटसाठी मायक्रोफोनची परवानगी हवी आहे.';

  @override
  String get voiceNoteSent => '🎤 व्हॉइस नोट';

  @override
  String get photoSent => '📷 शेल्फचा फोटो';

  @override
  String get typeMessageHint => 'इथे लिहा…';

  @override
  String get send => 'पाठवा';

  @override
  String get thinking => 'विचार करतोय…';

  @override
  String get networkError => 'सर्व्हरशी संपर्क झाला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get comingSoon => 'लवकरच येत आहे! शेल्फ स्कॅन लवकरच सुरू होईल.';

  @override
  String get scanFailed => 'फोटो समजला नाही, पुन्हा प्रयत्न करा.';

  @override
  String get imageTooLarge =>
      'फोटो खूप मोठा आहे (8 MB पेक्षा जास्त). लहान फोटो निवडा.';

  @override
  String get stockTitle => 'स्टॉक';

  @override
  String get lowStockBadge => 'कमी आहे';

  @override
  String reorderAt(String level) {
    return '$level झाल्यावर मागवा';
  }

  @override
  String get emptyStock => 'सध्या स्टॉक नाही. काय आले ते बोला.';

  @override
  String get udhaarTitle => 'उधारी';

  @override
  String get totalOutstanding => 'एकूण बाकी';

  @override
  String get emptyLedger =>
      'सध्या कोणतीही उधारी नाही. \"गुप्ताजींना 350 ची उधारी दिली\" असे बोला.';

  @override
  String get forecastTitle => 'अंदाज';

  @override
  String get legendHistory => 'मागील आठवडा';

  @override
  String get legendForecast => 'अंदाज';

  @override
  String get legendBand => 'रेंज';

  @override
  String get orderReady => 'ऑर्डर तयार';

  @override
  String get shareWhatsapp => 'WhatsApp वर पाठवा';

  @override
  String get copied => 'कॉपी झाले';

  @override
  String get copy => 'कॉपी करा';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get loading => 'लोड होत आहे…';

  @override
  String get errorLoading => 'लोड झाले नाही. पुन्हा पाहण्यासाठी खाली ओढा.';

  @override
  String get tagline => 'बोला, होऊन जाईल.';

  @override
  String get languageQuestion => 'मित्राने कोणत्या भाषेत बोलावे?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'हे भरा';

  @override
  String get dockPhoto => 'शेल्फ फोटो';

  @override
  String get dockType => 'लिहा';

  @override
  String get micLabel => 'दाबून बोला';

  @override
  String get recordingLabel => 'ऐकतोय… सोडल्यावर जाईल';

  @override
  String get recordingCancelHint => 'रद्द करण्यासाठी बोट बाजूला सरकवा';

  @override
  String get confirmHeader => 'समजले · नोंदवले';

  @override
  String get confirmTotalUdhaar => 'उधारी · आता एकूण';

  @override
  String get confirmTotalStock => 'स्टॉक · आता एकूण';

  @override
  String get confirmTotalSale => 'विक्री · आज एकूण';

  @override
  String get askHeader => 'नक्की नाही';

  @override
  String askHeard(String text) {
    return 'तुम्ही म्हणालात “$text”';
  }

  @override
  String get askStock => 'स्टॉकमध्ये जोडू का?';

  @override
  String get askUdhaar => 'उधारीमध्ये लिहू का?';

  @override
  String get askSale => 'विक्रीमध्ये लिहू का?';

  @override
  String get askNo => 'नाही';

  @override
  String get askDeclined => 'ठीक आहे, नाही नोंदवले.';

  @override
  String scanHeader(int count) {
    return 'शेल्फ पाहिले · $count वस्तू मिळाल्या';
  }

  @override
  String get scanQuestion => 'हाच स्टॉक सेट करू का?';

  @override
  String get scanConfirmed => 'समजले · स्टॉक अपडेट झाला';

  @override
  String stockSubtitle(int count, String time) {
    return '$count वस्तू · अपडेट $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू कमी आहेत',
      one: '1 वस्तू कमी आहे',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'सर्व ठीक आहे';

  @override
  String get orderButton => 'ऑर्डर बनवा';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ऑर्डर बनवा · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count लोक · खातेवही';
  }

  @override
  String get balanceLabel => 'बाकी';

  @override
  String todayGiven(String amount) {
    return 'आज दिले +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'आज जमा −₹$amount';
  }

  @override
  String get owedCaption => 'बाकी';

  @override
  String get settledBadge => 'चुकते';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount आले';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'उधारी सुरू $date · $count नोंदी';
  }

  @override
  String lastEntryAt(String time) {
    return 'शेवटची: $time';
  }

  @override
  String get remindButton => 'आठवण करा';

  @override
  String get paidButton => 'पैसे आले';

  @override
  String get paidPrompt => 'किती आले? बोला.';

  @override
  String get historyLabel => 'इतिहास';

  @override
  String get entryGiven => 'उधारी दिली';

  @override
  String get entryPaid => 'पैसे आले';

  @override
  String get entrySourceVoice => 'व्हॉइस';

  @override
  String get entrySourceCash => 'कॅश';

  @override
  String get entrySourcePhoto => 'फोटो';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'नमस्ते $name जी, $shop कडून. तुमचे ₹$balance बाकी आहेत. धन्यवाद!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'पुढील 4 आठवडे · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'पुढील 4 आठवडे';

  @override
  String perWeek(String unit) {
    return '$unit / आठवडा';
  }

  @override
  String get forecastFuture => 'पुढे · अंदाज';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'स्टॉकमध्ये $onHand · मागवा $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count वस्तू';
  }

  @override
  String get share => 'शेअर करा';

  @override
  String get hisaabTitle => 'आजचा हिशोब';

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
  String get hisaabGiven => 'उधारी दिली';

  @override
  String get hisaabReceived => 'उधारी जमा';

  @override
  String get hisaabOutstanding => 'एकूण बाकी';

  @override
  String get hisaabLow => 'कमी आहे';

  @override
  String hisaabLowItems(String items) {
    return '$items उद्या मागवा.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks आठवडे बाकी आहे.';
  }

  @override
  String get hisaabOrderButton => 'उद्याची ऑर्डर बनवा';

  @override
  String get hisaabShareButton => 'घरी WhatsApp करा';

  @override
  String todayChip(String date) {
    return 'आज · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'काल · $date';
  }

  @override
  String get demoNotice => 'सर्व्हर मिळाला नाही. डेमो मोडमध्ये सुरू करत आहे.';

  @override
  String get languageSheetTitle => 'मित्राने कोणत्या भाषेत बोलावे?';

  @override
  String get backLabel => 'मागे';

  @override
  String get voiceNoteLabel => 'व्हॉइस नोट';

  @override
  String get undo => 'पूर्ववत करा';

  @override
  String get feedbackButton => 'अभिप्राय';

  @override
  String get feedbackTitle => 'Kirana Mitra कसे चालले आहे?';

  @override
  String get feedbackUp => 'छान';

  @override
  String get feedbackDown => 'ठीक नाही';

  @override
  String get feedbackCommentHint => 'काही सांगायचे असल्यास इथे लिहा…';

  @override
  String get feedbackVoiceHint => 'किंवा दाबून बोला';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'आवाज तयार · ${seconds}s';
  }

  @override
  String get feedbackSend => 'पाठवा';

  @override
  String get feedbackPickRating => 'आधी छान किंवा ठीक नाही निवडा';

  @override
  String get feedbackThanks => 'धन्यवाद!';

  @override
  String get changeLanguage => 'भाषा बदला';

  @override
  String get languageSearchHint => 'भाषा शोधा…';

  @override
  String get languageNoMatch => 'कोणतीही भाषा सापडली नाही';

  @override
  String get topSellersTitle => 'टॉप सेलर्स';

  @override
  String get topSellersSubtitle => 'मागील 2 आठवडे · पुढील 2 आठवड्यांचा अंदाज';

  @override
  String get autoBadge => 'ऑटो';

  @override
  String coverDays(String days) {
    return '$days दिवसांचा स्टॉक';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 आठवडे';
  }

  @override
  String get autoRestockTitle => 'टॉप सेलर्स ऑटो-रीस्टॉक';

  @override
  String get autoRestockSubtitle =>
      'कमी स्टॉक असलेल्या टॉप सेलर्सची ऑर्डर रात्री आपोआप जाईल';

  @override
  String get distributorPhoneLabel => 'डिस्ट्रिब्युटरचा WhatsApp नंबर';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'सेव्ह करा';

  @override
  String get settingsSaved => 'सेव्ह झाले';

  @override
  String get ordersTitle => 'ऑर्डर्स';

  @override
  String get ordersEmpty => 'सध्या कोणतीही ऑर्डर नाही. अंदाजावरून ऑर्डर बनवा.';

  @override
  String get orderAuto => 'ऑटो';

  @override
  String get orderManual => 'मॅन्युअल';

  @override
  String get orderPlaced => 'पाठवले';

  @override
  String get orderCancelled => 'रद्द केले';

  @override
  String get viewOrders => 'ऑर्डर्स पहा';

  @override
  String get newOrdersNotice => 'रात्रीची ऑटो ऑर्डर तयार';

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
