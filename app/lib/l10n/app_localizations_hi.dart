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
}
