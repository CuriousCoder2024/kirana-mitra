// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bodo (`brx`).
class AppLocalizationsBrx extends AppLocalizations {
  AppLocalizationsBrx([String locale = 'brx']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'दखान्नि मुं';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'नोंथांनि मुं';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'जागायदो';

  @override
  String get requiredField => 'बेखौ सुंआबदो';

  @override
  String get navChat => 'रायज्लाय';

  @override
  String get navStock => 'स्टक';

  @override
  String get navUdhaar => 'उधार';

  @override
  String get navForecast => 'सानथौ';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'डेमो';

  @override
  String get changeShop => 'दखान सोलाय';

  @override
  String welcomeMessage(String name) {
    return 'खुलुमबाय $name! मा माल फैखो, मा फानखो, सोर उधार लागो बुंदो। माइक थुनानै बुं।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'खुलुमबाय $name! बुंदो: मा फैखो, मा फानखो, सोरनो उधार होखो। माइक दबायनानै बुं।';
  }

  @override
  String get recordingCancelled => 'गारदो, क्यान्सेल जाबाय';

  @override
  String get voiceTooShort => 'एसे गोबाव थुनानै बुंदो';

  @override
  String get micPermissionDenied =>
      'राव रेकर्ड खालामनो माइक्र\'फ\'ननि पारमिसन नांगौ।';

  @override
  String get voiceNoteSent => '🎤 राव नोट';

  @override
  String get photoSent => '📷 थाखानि फोटो';

  @override
  String get typeMessageHint => 'बेयाव लिर…';

  @override
  String get send => 'हरदो';

  @override
  String get thinking => 'सानबाय थादों…';

  @override
  String get networkError => 'सार्भार मोनासै। फिन नाजादो।';

  @override
  String get comingSoon =>
      'थाबैनो फैगासिनो! थाखा स्केन खालामनाया थाबैनो फैगोन।';

  @override
  String get scanFailed => 'फोटोआ मोजां रोखा जायाखै, फिन नाजाफिन।';

  @override
  String get imageTooLarge => 'फोटोआ जोबोद देरबाय (8 MB नि बांसिन)। फिसा हरदो।';

  @override
  String get stockTitle => 'स्टक';

  @override
  String get lowStockBadge => 'खम दं';

  @override
  String reorderAt(String level) {
    return '$level आव फिन थिन';
  }

  @override
  String get emptyStock => 'दानिया स्टक गैया। मा फैदों बुंदो।';

  @override
  String get udhaarTitle => 'उधार';

  @override
  String get totalOutstanding => 'गासै बाखि';

  @override
  String get emptyLedger =>
      'दानिया जेबो उधार गैया। \"Gupta ji नो 350 नि उधार हरबाय\" होनना बुं।';

  @override
  String get forecastTitle => 'सानथौ';

  @override
  String get legendHistory => 'थांनाय सबथा';

  @override
  String get legendForecast => 'सानथौ';

  @override
  String get legendBand => 'सिमा';

  @override
  String get orderReady => 'अर्डर जाबाय';

  @override
  String get shareWhatsapp => 'WhatsApp आव हर';

  @override
  String get copied => 'कपि जाबाय';

  @override
  String get copy => 'कपि';

  @override
  String get retry => 'फिन नाजा';

  @override
  String get loading => 'ल\'द जाबाय थादों…';

  @override
  String get errorLoading => 'ल\'द जायाखै। फिन नाजानो गाहायफारि बोदो।';

  @override
  String get tagline => 'बुंदो, जाथारगोन।';

  @override
  String get languageQuestion => 'मित्रा मा रावजों बुंगोन?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'बेखौ आवबायदो';

  @override
  String get dockPhoto => 'थाखानि फोटो';

  @override
  String get dockType => 'लिर';

  @override
  String get micLabel => 'थुनानै बुं';

  @override
  String get recordingLabel => 'खनागासिनो दं… गारबानो थांगोन';

  @override
  String get recordingCancelHint => 'क्यान्सेल खालामनो आसिखौ गोजानाव लां';

  @override
  String get confirmHeader => 'बुजिबाय · लिरबाय';

  @override
  String get confirmTotalUdhaar => 'उधार · दा गासै';

  @override
  String get confirmTotalStock => 'स्टक · दा गासै';

  @override
  String get confirmTotalSale => 'फाननाय · दिनैनि गासै';

  @override
  String get askHeader => 'थार नङा';

  @override
  String askHeard(String text) {
    return 'नोंथाङा बुंबाय “$text”';
  }

  @override
  String get askStock => 'स्टकआव दाजाबगोन?';

  @override
  String get askUdhaar => 'उधारआव लिरगोन?';

  @override
  String get askSale => 'फाननायाव लिरगोन?';

  @override
  String get askNo => 'नङा';

  @override
  String get askDeclined => 'थिग दं, लिरासै।';

  @override
  String scanHeader(int count) {
    return 'थाखा नायबाय · $count ता बेसाद मोनबाय';
  }

  @override
  String get scanQuestion => 'स्टक बेखौनो दोनगोन?';

  @override
  String get scanConfirmed => 'बुजिबाय · स्टक आपडेट जाबाय';

  @override
  String stockSubtitle(int count, String time) {
    return '$count ता मुवा · आपडेट $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ता मुवा खम जाबाय',
      one: '1 ता मुवा खम जाबाय',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'गासैबो मोजां दं';

  @override
  String get orderButton => 'अर्डर खालाम';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'अर्डर खालाम · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count सुबुं · बाहि-खाता';
  }

  @override
  String get balanceLabel => 'बाखि';

  @override
  String todayGiven(String amount) {
    return 'दिनै हरबाय +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'दिनै मोनबाय −₹$amount';
  }

  @override
  String get owedCaption => 'बाखि';

  @override
  String get settledBadge => 'फुजबाय';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount मोनबाय';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'उधार जागायनाय $date · $count ता भुंथि';
  }

  @override
  String lastEntryAt(String time) {
    return 'जोबथा: $time';
  }

  @override
  String get remindButton => 'गोसोखांखांहो';

  @override
  String get paidButton => 'रां मोनबाय';

  @override
  String get paidPrompt => 'बेसेबां मोनखो? बुंदो।';

  @override
  String get historyLabel => 'जारिमिन';

  @override
  String get entryGiven => 'उधार हरबाय';

  @override
  String get entryPaid => 'रां मोनबाय';

  @override
  String get entrySourceVoice => 'राव';

  @override
  String get entrySourceCash => 'रांखाय';

  @override
  String get entrySourcePhoto => 'फोटो';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'खुलुमबाय $name जी, $shop निफ्राय। नोंथांनि ₹$balance बाखि दं। रोजा-रोजा साबायख\'र!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'फैगौ 4 सबथा · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'फैगौ 4 सबथा';

  @override
  String perWeek(String unit) {
    return '$unit / सबथा';
  }

  @override
  String get forecastFuture => 'सिगांफारि · सानथौ';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'स्टकआव $onHand · $qty $unit थिनहर';
  }

  @override
  String orderItemCount(int count) {
    return '$count ता मुवा';
  }

  @override
  String get share => 'शेयार';

  @override
  String get hisaabTitle => 'दिनैनि हिसाब';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count ता भुंथि';
  }

  @override
  String hisaabDayChip(String time) {
    return 'दखान बन्द · $time';
  }

  @override
  String get hisaabSales => 'दिनैनि फाननाय';

  @override
  String get hisaabGiven => 'उधार हरबाय';

  @override
  String get hisaabReceived => 'उधार मोनबाय';

  @override
  String get hisaabOutstanding => 'गासै बाखि';

  @override
  String get hisaabLow => 'खम दं';

  @override
  String hisaabLowItems(String items) {
    return '$items गाबोन थिनहर।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival आव $weeks सबथा दावगाना दं।';
  }

  @override
  String get hisaabOrderButton => 'गाबोनि अर्डर बानाय';

  @override
  String get hisaabShareButton => 'न\'आव WhatsApp खालाम';

  @override
  String todayChip(String date) {
    return 'दिनै · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'मैया · $date';
  }

  @override
  String get demoNotice => 'सार्भार मोनासै। डेमो म\'डआव जागायबाय।';

  @override
  String get languageSheetTitle => 'मित्रा मा रावजों बुंगोन?';

  @override
  String get backLabel => 'उनाव';

  @override
  String get voiceNoteLabel => 'राव नोट';

  @override
  String get undo => 'फिन लाबो';

  @override
  String get feedbackButton => 'फिदबेक';

  @override
  String get feedbackTitle => 'Kirana Mitra माबोरै सोलिदों?';

  @override
  String get feedbackUp => 'मोजां';

  @override
  String get feedbackDown => 'मोजां जायाखै';

  @override
  String get feedbackCommentHint => 'आर\' माबाफोर बुंनो दंबा लिर…';

  @override
  String get feedbackVoiceHint => 'एबा थुनानै बुंदो';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'राव थियारि · $seconds से';
  }

  @override
  String get feedbackSend => 'हरदो';

  @override
  String get feedbackPickRating => 'सिगां मोजां एबा मोजां जायाखै सायख\'';

  @override
  String get feedbackThanks => 'साबायख\'र!';

  @override
  String get changeLanguage => 'राव सोलाय';

  @override
  String get languageSearchHint => 'राव नागिर…';

  @override
  String get languageNoMatch => 'जेबो राव मोनासै';

  @override
  String get topSellersTitle => 'बांसिन फाननाय';

  @override
  String get topSellersSubtitle => 'थांनाय 2 सबथा · फैगौ 2 सबथानि सानथौ';

  @override
  String get autoBadge => 'अटो';

  @override
  String coverDays(String days) {
    return '$days साननि स्टक';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 सबथा';
  }

  @override
  String get autoRestockTitle => 'बांसिन फाननायफोरखौ गावनो आपडेट';

  @override
  String get autoRestockSubtitle =>
      'खम स्टक थानाय मुवाफोरनि अर्डारा हरआव गावनो थांगोन';

  @override
  String get distributorPhoneLabel => 'डिस्ट्रिब्युटरनि WhatsApp नम्बर';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'दोनथुम';

  @override
  String get settingsSaved => 'दोनथुमबाय';

  @override
  String get ordersTitle => 'अर्डरफोर';

  @override
  String get ordersEmpty =>
      'दानिया जेबो अर्डर गैया। सानथौनिफ्राय अर्डर बानायदो।';

  @override
  String get orderAuto => 'अटो';

  @override
  String get orderManual => 'मेनुयेल';

  @override
  String get orderPlaced => 'हरबाय';

  @override
  String get orderCancelled => 'क्यान्सेल जाबाय';

  @override
  String get viewOrders => 'अर्डरफोरखौ नाय';

  @override
  String get newOrdersNotice => 'हरनि अटो अर्डर फैबाय';

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
