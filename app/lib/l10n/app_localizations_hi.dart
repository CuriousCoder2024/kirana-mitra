// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'किराना मित्र';

  @override
  String get shopNameLabel => 'दुकान का नाम';

  @override
  String get shopNameHint => 'गुप्ता जनरल स्टोर';

  @override
  String get ownerNameLabel => 'आपका नाम';

  @override
  String get ownerNameHint => 'रमेश गुप्ता';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'शुरू करें';

  @override
  String get requiredField => 'कृपया यह भरें';

  @override
  String get navChat => 'बात';

  @override
  String get navStock => 'स्टॉक';

  @override
  String get navUdhaar => 'उधार';

  @override
  String get navForecast => 'अनुमान';

  @override
  String get chatTitle => 'किराना मित्र';

  @override
  String get demoMode => 'डेमो';

  @override
  String get changeShop => 'दुकान बदलें';

  @override
  String welcomeMessage(String name) {
    return 'नमस्ते $name! बताइए क्या आया, क्या बिका, किसको उधार दिया। माइक दबाकर बोलिए।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'Namaste $name! Bolo: kya aaya, kya bika, kisko udhaar diya. Mic dabake rakho aur bolo.';
  }

  @override
  String get recordingCancelled => 'छोड़ दो, कैंसल हो गया';

  @override
  String get voiceTooShort => 'थोड़ा और देर दबाकर बोलें';

  @override
  String get micPermissionDenied => 'वॉइस नोट के लिए माइक की अनुमति चाहिए।';

  @override
  String get voiceNoteSent => '🎤 वॉइस नोट';

  @override
  String get photoSent => '📷 शेल्फ की फोटो';

  @override
  String get typeMessageHint => 'यहाँ लिखो…';

  @override
  String get send => 'भेजें';

  @override
  String get thinking => 'सोच रहा हूँ…';

  @override
  String get networkError => 'सर्वर से संपर्क नहीं हुआ। फिर से कोशिश करें।';

  @override
  String get comingSoon => 'जल्दी आ रहा है! शेल्फ स्कैन अभी तैयार हो रहा है।';

  @override
  String get scanFailed => 'फोटो समझ नहीं आई, फिर से कोशिश करें।';

  @override
  String get imageTooLarge =>
      'फोटो बहुत बड़ी है (8 MB से ज़्यादा)। छोटी फोटो लें।';

  @override
  String get stockTitle => 'स्टॉक';

  @override
  String get lowStockBadge => 'कम है';

  @override
  String reorderAt(String level) {
    return '$level पर मंगाओ';
  }

  @override
  String get emptyStock => 'अभी स्टॉक नहीं है। बोलो क्या आया।';

  @override
  String get udhaarTitle => 'उधार';

  @override
  String get totalOutstanding => 'कुल बाकी';

  @override
  String get emptyLedger =>
      'अभी कोई उधार नहीं। बोलो \"गुप्ता जी को 350 का उधार दिया\"।';

  @override
  String get forecastTitle => 'अनुमान';

  @override
  String get legendHistory => 'पिछले हफ्ते';

  @override
  String get legendForecast => 'अनुमान';

  @override
  String get legendBand => 'दायरा';

  @override
  String get orderReady => 'ऑर्डर तैयार';

  @override
  String get shareWhatsapp => 'WhatsApp पर भेजो';

  @override
  String get copied => 'कॉपी हो गया';

  @override
  String get copy => 'कॉपी';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get errorLoading => 'लोड नहीं हुआ। नीचे खींचकर फिर कोशिश करें।';

  @override
  String get tagline => 'बोलो, हो जाएगा।';

  @override
  String get languageQuestion => 'मित्र किस भाषा में बोले?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'यह भरो';

  @override
  String get dockPhoto => 'शेल्फ फोटो';

  @override
  String get dockType => 'लिखो';

  @override
  String get micLabel => 'दबाकर बोलो';

  @override
  String get recordingLabel => 'सुन रहा हूँ… छोड़ो तो भेजेगा';

  @override
  String get recordingCancelHint => 'कैंसल के लिए उंगली बाहर ले जाओ';

  @override
  String get confirmHeader => 'समझा · लिख दिया';

  @override
  String get confirmTotalUdhaar => 'उधार · अब कुल';

  @override
  String get confirmTotalStock => 'स्टॉक · अब कुल';

  @override
  String get confirmTotalSale => 'बिक्री · आज कुल';

  @override
  String get askHeader => 'पक्का नहीं';

  @override
  String askHeard(String text) {
    return 'आपने कहा “$text”';
  }

  @override
  String get askStock => 'स्टॉक में जोड़ूँ?';

  @override
  String get askUdhaar => 'उधार में लिखूँ?';

  @override
  String get askSale => 'बिक्री में लिखूँ?';

  @override
  String get askNo => 'नहीं';

  @override
  String get askDeclined => 'ठीक है, नहीं लिखा।';

  @override
  String scanHeader(int count) {
    return 'शेल्फ देखा · $count चीज़ें मिलीं';
  }

  @override
  String get scanQuestion => 'स्टॉक यही सेट कर दूँ?';

  @override
  String get scanConfirmed => 'समझा · स्टॉक अपडेट हो गया';

  @override
  String stockSubtitle(int count, String time) {
    return '$count चीज़ें · अपडेट $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चीज़ें कम हैं',
      one: '1 चीज़ कम है',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'सब ठीक है';

  @override
  String get orderButton => 'ऑर्डर बनाओ';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ऑर्डर बनाओ · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count लोग · बही-खाता';
  }

  @override
  String get balanceLabel => 'बाकी';

  @override
  String todayGiven(String amount) {
    return 'आज दिया +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'आज आया −₹$amount';
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
    return '$date · −₹$amount आया';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'उधार शुरू $date · $count एंट्री';
  }

  @override
  String lastEntryAt(String time) {
    return 'आखिरी: $time';
  }

  @override
  String get remindButton => 'याद दिलाओ';

  @override
  String get paidButton => 'पैसा आया';

  @override
  String get paidPrompt => 'कितना आया? बोलो।';

  @override
  String get historyLabel => 'हिस्ट्री';

  @override
  String get entryGiven => 'उधार लिया';

  @override
  String get entryPaid => 'पैसा आया';

  @override
  String get entrySourceVoice => 'वॉइस';

  @override
  String get entrySourceCash => 'कैश';

  @override
  String get entrySourcePhoto => 'फोटो';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'नमस्ते $name जी, $shop से। आपका ₹$balance बाकी है। धन्यवाद!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'अगले 4 हफ्ते · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'अगले 4 हफ्ते';

  @override
  String perWeek(String unit) {
    return '$unit / हफ्ता';
  }

  @override
  String get forecastFuture => 'आगे · अनुमान';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'स्टॉक में $onHand · मंगाओ $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count चीज़ें';
  }

  @override
  String get share => 'शेयर';

  @override
  String get hisaabTitle => 'आज का हिसाब';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count एंट्री';
  }

  @override
  String hisaabDayChip(String time) {
    return 'दुकान बंद · $time';
  }

  @override
  String get hisaabSales => 'आज की बिक्री';

  @override
  String get hisaabGiven => 'उधार दिया';

  @override
  String get hisaabReceived => 'उधार आया';

  @override
  String get hisaabOutstanding => 'कुल बाकी';

  @override
  String get hisaabLow => 'कम है';

  @override
  String hisaabLowItems(String items) {
    return '$items कल मंगाओ।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks हफ्ते दूर है।';
  }

  @override
  String get hisaabOrderButton => 'कल का ऑर्डर बनाओ';

  @override
  String get hisaabShareButton => 'घर पर WhatsApp करो';

  @override
  String todayChip(String date) {
    return 'आज · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'कल · $date';
  }

  @override
  String get demoNotice => 'सर्वर नहीं मिला। डेमो मोड में शुरू कर रहा हूँ।';

  @override
  String get languageSheetTitle => 'मित्र किस भाषा में बोले?';

  @override
  String get backLabel => 'पीछे';

  @override
  String get voiceNoteLabel => 'वॉइस नोट';

  @override
  String get undo => 'अनडू';

  @override
  String get feedbackButton => 'फ़ीडबैक';

  @override
  String get feedbackTitle => 'किराना मित्र कैसा चल रहा है?';

  @override
  String get feedbackUp => 'अच्छा';

  @override
  String get feedbackDown => 'ठीक नहीं';

  @override
  String get feedbackCommentHint => 'कुछ और बताना हो तो लिखो…';

  @override
  String get feedbackVoiceHint => 'या दबाकर बोलो';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'आवाज़ तैयार · ${seconds}s';
  }

  @override
  String get feedbackSend => 'भेजो';

  @override
  String get feedbackPickRating => 'पहले अच्छा या ठीक नहीं चुनो';

  @override
  String get feedbackThanks => 'शुक्रिया!';

  @override
  String get changeLanguage => 'भाषा बदलो';

  @override
  String get languageSearchHint => 'भाषा ढूँढो…';

  @override
  String get languageNoMatch => 'कोई भाषा नहीं मिली';

  @override
  String get topSellersTitle => 'टॉप सेलर';

  @override
  String get topSellersSubtitle => 'पिछले 2 हफ्ते · अगले 2 हफ्ते का अनुमान';

  @override
  String get autoBadge => 'ऑटो';

  @override
  String coverDays(String days) {
    return '$days दिन';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit';
  }

  @override
  String get autoRestockTitle => 'टॉप सेलर का ऑटो-रीस्टॉक';

  @override
  String get autoRestockSubtitle =>
      'कम स्टॉक वाले टॉप सेलर का ऑर्डर रात को अपने आप जाएगा';

  @override
  String get distributorPhoneLabel => 'डिस्ट्रीब्यूटर का WhatsApp नंबर';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'सेव करो';

  @override
  String get settingsSaved => 'सेव हो गया';

  @override
  String get ordersTitle => 'ऑर्डर';

  @override
  String get ordersEmpty => 'अभी कोई ऑर्डर नहीं। अनुमान से ऑर्डर बनाओ।';

  @override
  String get orderAuto => 'ऑटो';

  @override
  String get orderManual => 'मैनुअल';

  @override
  String get orderPlaced => 'भेजा';

  @override
  String get orderCancelled => 'कैंसल हो गया';

  @override
  String get viewOrders => 'ऑर्डर देखो';

  @override
  String get newOrdersNotice => 'रात का ऑटो ऑर्डर आया';

  @override
  String get shopReRegistered =>
      'सर्वर रीस्टार्ट हुआ, दुकान फिर से रजिस्टर की।';
}

/// The translations for Hindi, using the Latin script (`hi_Latn`).
class AppLocalizationsHiLatn extends AppLocalizationsHi {
  AppLocalizationsHiLatn() : super('hi_Latn');

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'Dukaan ka naam';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'Aapka naam';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'Shuru karo';

  @override
  String get requiredField => 'Yeh bharna zaroori hai';

  @override
  String get navChat => 'Baat';

  @override
  String get navStock => 'Stock';

  @override
  String get navUdhaar => 'Udhaar';

  @override
  String get navForecast => 'Forecast';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'Demo';

  @override
  String get changeShop => 'Dukaan badlo';

  @override
  String welcomeMessage(String name) {
    return 'Namaste $name! Bolo: kya aaya, kya bika, kisko udhaar diya. Mic dabake rakho aur bolo.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'Namaste $name! Bolo: kya aaya, kya bika, kisko udhaar diya. Mic dabake rakho aur bolo.';
  }

  @override
  String get recordingCancelled => 'Chhod do, cancel ho gaya';

  @override
  String get voiceTooShort => 'Thoda der dabake bolo';

  @override
  String get micPermissionDenied =>
      'Voice note ke liye mic ki permission chahiye.';

  @override
  String get voiceNoteSent => '🎤 Voice note';

  @override
  String get photoSent => '📷 Shelf photo';

  @override
  String get typeMessageHint => 'Yahan likho…';

  @override
  String get send => 'Bhejo';

  @override
  String get thinking => 'Soch raha hoon…';

  @override
  String get networkError => 'Server connect nahi hua. Phir try karo.';

  @override
  String get comingSoon => 'Jaldi aa raha hai! Shelf scan jald aayega.';

  @override
  String get scanFailed => 'Photo samajh nahi aayi, phir se try karo.';

  @override
  String get imageTooLarge =>
      'Photo bohot badi hai (8 MB se zyada). Chhoti photo daalo.';

  @override
  String get stockTitle => 'Stock';

  @override
  String get lowStockBadge => 'Kam hai';

  @override
  String reorderAt(String level) {
    return '$level pe mangao';
  }

  @override
  String get emptyStock => 'Abhi stock nahi hai. Bolo kya aaya.';

  @override
  String get udhaarTitle => 'Udhaar';

  @override
  String get totalOutstanding => 'Kul baaki';

  @override
  String get emptyLedger =>
      'Abhi koi udhaar nahi. Bolo \"Gupta ji ko 350 ka udhaar diya\".';

  @override
  String get forecastTitle => 'Forecast';

  @override
  String get legendHistory => 'Pichhle hafte';

  @override
  String get legendForecast => 'Anumaan';

  @override
  String get legendBand => 'Range';

  @override
  String get orderReady => 'Order taiyaar';

  @override
  String get shareWhatsapp => 'WhatsApp pe bhejo';

  @override
  String get copied => 'Copy ho gaya';

  @override
  String get copy => 'Copy';

  @override
  String get retry => 'Phir try karo';

  @override
  String get loading => 'Loading…';

  @override
  String get errorLoading => 'Load nahi hua. Neeche kheench ke phir try karo.';

  @override
  String get tagline => 'Bolo, ho jayega.';

  @override
  String get languageQuestion => 'Mitra kis bhasha mein bole?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'Yeh bharo';

  @override
  String get dockPhoto => 'Shelf photo';

  @override
  String get dockType => 'Likho';

  @override
  String get micLabel => 'Dabake bolo';

  @override
  String get recordingLabel => 'Sun raha hoon… chhodo toh bhejega';

  @override
  String get recordingCancelHint => 'Cancel ke liye ungli bahar le jao';

  @override
  String get confirmHeader => 'Samjha · likh diya';

  @override
  String get confirmTotalUdhaar => 'Udhaar · ab total';

  @override
  String get confirmTotalStock => 'Stock · ab total';

  @override
  String get confirmTotalSale => 'Bikri · aaj total';

  @override
  String get askHeader => 'Pakka nahi';

  @override
  String askHeard(String text) {
    return 'aapne kaha “$text”';
  }

  @override
  String get askStock => 'Stock mein add karoon?';

  @override
  String get askUdhaar => 'Udhaar mein likhoon?';

  @override
  String get askSale => 'Bikri mein likhoon?';

  @override
  String get askNo => 'Nahi';

  @override
  String get askDeclined => 'Theek hai, nahi likha.';

  @override
  String scanHeader(int count) {
    return 'Shelf dekha · $count cheezein mili';
  }

  @override
  String get scanQuestion => 'Stock yahi set kar doon?';

  @override
  String get scanConfirmed => 'Samjha · stock update ho gaya';

  @override
  String stockSubtitle(int count, String time) {
    return '$count cheezein · update $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cheezein kam hain',
      one: '1 cheez kam hai',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'Sab theek hai';

  @override
  String get orderButton => 'Order banao';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'Order banao · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count log · bahi-khata';
  }

  @override
  String get balanceLabel => 'Baaki';

  @override
  String todayGiven(String amount) {
    return 'Aaj diya +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'Aaj aaya −₹$amount';
  }

  @override
  String get owedCaption => 'baaki';

  @override
  String get settledBadge => 'Chukta';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount aaya';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'Udhaar shuru $date · $count entries';
  }

  @override
  String lastEntryAt(String time) {
    return 'Last: $time';
  }

  @override
  String get remindButton => 'Yaad dilao';

  @override
  String get paidButton => 'Paisa aaya';

  @override
  String get paidPrompt => 'Kitna aaya? Bolo.';

  @override
  String get historyLabel => 'History';

  @override
  String get entryGiven => 'Udhaar liya';

  @override
  String get entryPaid => 'Paisa aaya';

  @override
  String get entrySourceVoice => 'voice';

  @override
  String get entrySourceCash => 'cash';

  @override
  String get entrySourcePhoto => 'photo';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'Namaste $name ji, $shop se. Aapka ₹$balance baaki hai. Dhanyavaad!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'Agle 4 hafte · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'Agle 4 hafte';

  @override
  String perWeek(String unit) {
    return '$unit / hafta';
  }

  @override
  String get forecastFuture => 'AAGE · forecast';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'Stock mein $onHand · mangao $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count cheezein';
  }

  @override
  String get share => 'Share';

  @override
  String get hisaabTitle => 'Aaj ka hisaab';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count entries';
  }

  @override
  String hisaabDayChip(String time) {
    return 'Dukaan band · $time';
  }

  @override
  String get hisaabSales => 'Aaj ki bikri';

  @override
  String get hisaabGiven => 'Udhaar diya';

  @override
  String get hisaabReceived => 'Udhaar aaya';

  @override
  String get hisaabOutstanding => 'Kul baaki';

  @override
  String get hisaabLow => 'Kam hai';

  @override
  String hisaabLowItems(String items) {
    return '$items kal mangao.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks hafte door hai.';
  }

  @override
  String get hisaabOrderButton => 'Kal ka order banao';

  @override
  String get hisaabShareButton => 'Ghar pe WhatsApp karo';

  @override
  String todayChip(String date) {
    return 'Aaj · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'Kal · $date';
  }

  @override
  String get demoNotice =>
      'Server nahi mila. Demo mode mein shuru kar raha hoon.';

  @override
  String get languageSheetTitle => 'Mitra kis bhasha mein bole?';

  @override
  String get backLabel => 'Peeche';

  @override
  String get voiceNoteLabel => 'Voice note';

  @override
  String get undo => 'Undo';

  @override
  String get feedbackButton => 'Feedback';

  @override
  String get feedbackTitle => 'Kirana Mitra kaisa chal raha hai?';

  @override
  String get feedbackUp => 'Achha';

  @override
  String get feedbackDown => 'Theek nahi';

  @override
  String get feedbackCommentHint => 'Kuch aur batana ho toh likho…';

  @override
  String get feedbackVoiceHint => 'Ya dabake bolo';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'Aawaz taiyaar · ${seconds}s';
  }

  @override
  String get feedbackSend => 'Bhejo';

  @override
  String get feedbackPickRating => 'Pehle achha ya theek nahi chuno';

  @override
  String get feedbackThanks => 'Shukriya!';

  @override
  String get changeLanguage => 'Bhasha badlo';

  @override
  String get languageSearchHint => 'Bhasha dhoondo…';

  @override
  String get languageNoMatch => 'Koi bhasha nahi mili';

  @override
  String get topSellersTitle => 'Top sellers';

  @override
  String get topSellersSubtitle => 'Pichhle 2 hafte · agle 2 hafte ka anumaan';

  @override
  String get autoBadge => 'Auto';

  @override
  String coverDays(String days) {
    return '$days din ka stock';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 hafte';
  }

  @override
  String get autoRestockTitle => 'Auto-restock top sellers';

  @override
  String get autoRestockSubtitle =>
      'Kam stock wale top sellers ka order raat ko apne aap jayega';

  @override
  String get distributorPhoneLabel => 'Distributor ka WhatsApp number';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'Save karo';

  @override
  String get settingsSaved => 'Save ho gaya';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersEmpty => 'Abhi koi order nahi. Forecast se Order banao.';

  @override
  String get orderAuto => 'Auto';

  @override
  String get orderManual => 'Manual';

  @override
  String get orderPlaced => 'Bheja';

  @override
  String get orderCancelled => 'Cancel ho gaya';

  @override
  String get viewOrders => 'Orders dekho';

  @override
  String get newOrdersNotice => 'Raat ka auto order aaya';

  @override
  String get shopReRegistered =>
      'Server restart hua, dukaan phir se register ki.';
}
