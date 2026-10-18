// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'దుకాణం పేరు';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'మీ పేరు';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'మొదలుపెట్టండి';

  @override
  String get requiredField => 'దయచేసి ఇది పూర్తి చేయండి';

  @override
  String get navChat => 'మాట';

  @override
  String get navStock => 'స్టాక్';

  @override
  String get navUdhaar => 'బాకీ';

  @override
  String get navForecast => 'అంచనా';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'డెమో';

  @override
  String get changeShop => 'దుకాణం మార్చండి';

  @override
  String welcomeMessage(String name) {
    return 'నమస్తే $name! ఏమి సరుకు వచ్చింది, ఏమి అమ్ముడైంది, ఎవరికి అప్పు ఇచ్చారో చెప్పండి. మైక్ నొక్కి మాట్లాడండి.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'నమస్తే $name! ఏమి వచ్చింది, ఏమి అమ్ముడైంది, ఎవరికి అప్పు ఇచ్చారో చెప్పండి. మైక్ నొక్కి మాట్లాడండి.';
  }

  @override
  String get recordingCancelled => 'వదిలేశారు, రద్దయింది';

  @override
  String get voiceTooShort => 'కాస్త ఎక్కువసేపు నొక్కి పట్టి మాట్లాడండి';

  @override
  String get micPermissionDenied =>
      'వాయిస్ నోట్స్ కోసం మైక్రోఫోన్ అనుమతి అవసరం.';

  @override
  String get voiceNoteSent => '🎤 వాయిస్ నోట్';

  @override
  String get photoSent => '📷 షెల్ఫ్ ఫోటో';

  @override
  String get typeMessageHint => 'ఇక్కడ రాయండి…';

  @override
  String get send => 'పంపండి';

  @override
  String get thinking => 'ఆలోచిస్తోంది…';

  @override
  String get networkError => 'సర్వర్ కనెక్ట్ కాలేదు. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get comingSoon =>
      'త్వరలోనే వస్తుంది! షెల్ఫ్ స్కాన్ ఫీచర్ త్వరలో వస్తుంది.';

  @override
  String get scanFailed => 'ఫోటో సరిగ్గా అర్థం కాలేదు, మళ్ళీ ప్రయత్నించండి.';

  @override
  String get imageTooLarge =>
      'ఫోటో సైజు ఎక్కువ (8 MB కంటే ఎక్కువ). చిన్నది ప్రయత్నించండి.';

  @override
  String get stockTitle => 'స్టాక్';

  @override
  String get lowStockBadge => 'తక్కువ ఉంది';

  @override
  String reorderAt(String level) {
    return '$level వద్ద ఆర్డర్ చేయండి';
  }

  @override
  String get emptyStock => 'ప్రస్తుతం స్టాక్ లేదు. ఏమి వచ్చిందో చెప్పండి.';

  @override
  String get udhaarTitle => 'బాకీ';

  @override
  String get totalOutstanding => 'మొత్తం బాకీ';

  @override
  String get emptyLedger =>
      'ఇంకా ఏ బాకీ లేదు. \"గుప్తా గారికి 350 అప్పు ఇచ్చాను\" అని చెప్పండి.';

  @override
  String get forecastTitle => 'అంచనా';

  @override
  String get legendHistory => 'గత వారం';

  @override
  String get legendForecast => 'అంచనా';

  @override
  String get legendBand => 'పరిధి';

  @override
  String get orderReady => 'ఆర్డర్ సిద్ధం';

  @override
  String get shareWhatsapp => 'WhatsApp లో పంపండి';

  @override
  String get copied => 'కాపీ అయింది';

  @override
  String get copy => 'కాపీ చేయండి';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get loading => 'లోడ్ అవుతోంది…';

  @override
  String get errorLoading =>
      'లోడ్ కాలేదు. మళ్ళీ ప్రయత్నించడానికి కిందకు లాగండి.';

  @override
  String get tagline => 'చెప్పండి, అయిపోతుంది.';

  @override
  String get languageQuestion => 'మిత్ర ఏ భాషలో మాట్లాడాలి?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'ఇది రాయండి';

  @override
  String get dockPhoto => 'షెల్ఫ్ ఫోటో';

  @override
  String get dockType => 'రాయండి';

  @override
  String get micLabel => 'నొక్కి మాట్లాడండి';

  @override
  String get recordingLabel => 'వింటున్నాను… వదిలితే వెళ్తుంది';

  @override
  String get recordingCancelHint => 'రద్దు చేయడానికి వేలిని బయటకు జరపండి';

  @override
  String get confirmHeader => 'అర్థమైంది · రాశాను';

  @override
  String get confirmTotalUdhaar => 'బాకీ · ఇప్పుడు మొత్తం';

  @override
  String get confirmTotalStock => 'స్టాక్ · ఇప్పుడు మొత్తం';

  @override
  String get confirmTotalSale => 'అమ్మకాలు · నేటి మొత్తం';

  @override
  String get askHeader => 'ఖచ్చితంగా తెలీదు';

  @override
  String askHeard(String text) {
    return 'మీరు “$text” అన్నారు';
  }

  @override
  String get askStock => 'స్టాక్‌లో కలపమంటారా?';

  @override
  String get askUdhaar => 'బాకీలో రాయమంటారా?';

  @override
  String get askSale => 'అమ్మకాల్లో రాయమంటారా?';

  @override
  String get askNo => 'వద్దు';

  @override
  String get askDeclined => 'సరే, రాయలేదు.';

  @override
  String scanHeader(int count) {
    return 'షెల్ఫ్ చూశాను · $count వస్తువులు కనిపించాయి';
  }

  @override
  String get scanQuestion => 'స్టాక్ ఇదే సెట్ చేయమంటారా?';

  @override
  String get scanConfirmed => 'అర్థమైంది · స్టాక్ అప్‌డేట్ అయింది';

  @override
  String stockSubtitle(int count, String time) {
    return '$count వస్తువులు · అప్‌డేట్ $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count వస్తువులు తక్కువ ఉన్నాయి',
      one: '1 వస్తువు తక్కువ ఉంది',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'అంతా బాగుంది';

  @override
  String get orderButton => 'ఆర్డర్ చేయండి';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ఆర్డర్ చేయండి · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count మంది · లెక్కల పుస్తకం';
  }

  @override
  String get balanceLabel => 'బాకీ';

  @override
  String todayGiven(String amount) {
    return 'నేడు ఇచ్చింది +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'నేడు వచ్చింది −₹$amount';
  }

  @override
  String get owedCaption => 'బాకీ';

  @override
  String get settledBadge => 'చెల్లించారు';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount వచ్చింది';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'అప్పు మొదలు $date · $count ఎంట్రీలు';
  }

  @override
  String lastEntryAt(String time) {
    return 'చివరిది: $time';
  }

  @override
  String get remindButton => 'గుర్తు చేయండి';

  @override
  String get paidButton => 'డబ్బులు వచ్చాయి';

  @override
  String get paidPrompt => 'ఎంత వచ్చింది? చెప్పండి.';

  @override
  String get historyLabel => 'వివరాలు';

  @override
  String get entryGiven => 'అప్పు ఇచ్చారు';

  @override
  String get entryPaid => 'డబ్బులు వచ్చాయి';

  @override
  String get entrySourceVoice => 'వాయిస్';

  @override
  String get entrySourceCash => 'నగదు';

  @override
  String get entrySourcePhoto => 'ఫోటో';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'నమస్తే $name గారు, $shop నుండి. మీ వద్ద ₹$balance బాకీ ఉంది. ధన్యవాదాలు!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'వచ్చే 4 వారాలు · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'వచ్చే 4 వారాలు';

  @override
  String perWeek(String unit) {
    return '$unit / వారం';
  }

  @override
  String get forecastFuture => 'ముందున్నది · అంచనా';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'స్టాక్‌లో $onHand · తెప్పించండి $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count వస్తువులు';
  }

  @override
  String get share => 'షేర్ చేయండి';

  @override
  String get hisaabTitle => 'నేటి లెక్క';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count ఎంట్రీలు';
  }

  @override
  String hisaabDayChip(String time) {
    return 'దుకాణం బంద్ · $time';
  }

  @override
  String get hisaabSales => 'నేటి అమ్మకాలు';

  @override
  String get hisaabGiven => 'ఇచ్చిన అప్పు';

  @override
  String get hisaabReceived => 'వచ్చిన బాకీ';

  @override
  String get hisaabOutstanding => 'మొత్తం బాకీ';

  @override
  String get hisaabLow => 'తక్కువ ఉంది';

  @override
  String hisaabLowItems(String items) {
    return '$items రేపు తెప్పించండి.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks వారాల్లో ఉంది.';
  }

  @override
  String get hisaabOrderButton => 'రేపటి ఆర్డర్ వేయండి';

  @override
  String get hisaabShareButton => 'ఇంటికి WhatsApp చేయండి';

  @override
  String todayChip(String date) {
    return 'నేడు · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'నిన్న · $date';
  }

  @override
  String get demoNotice => 'సర్వర్ కలవలేదు. డెమో మోడ్‌లో మొదలుపెడుతున్నాను.';

  @override
  String get languageSheetTitle => 'మిత్ర ఏ భాషలో మాట్లాడాలి?';

  @override
  String get backLabel => 'వెనుకకు';

  @override
  String get voiceNoteLabel => 'వాయిస్ నోట్';

  @override
  String get undo => 'వెనక్కి';

  @override
  String get feedbackButton => 'ఫీడ్‌బ్యాక్';

  @override
  String get feedbackTitle => 'Kirana Mitra ఎలా పనిచేస్తోంది?';

  @override
  String get feedbackUp => 'బాగుంది';

  @override
  String get feedbackDown => 'బాగోలేదు';

  @override
  String get feedbackCommentHint => 'ఇంకేమైనా చెప్పాలంటే రాయండి…';

  @override
  String get feedbackVoiceHint => 'లేదా నొక్కి మాట్లాడండి';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'వాయిస్ సిద్ధం · $secondsసె';
  }

  @override
  String get feedbackSend => 'పంపండి';

  @override
  String get feedbackPickRating => 'ముందు బాగుందో బాగోలేదో ఎంచుకోండి';

  @override
  String get feedbackThanks => 'ధన్యవాదాలు!';

  @override
  String get changeLanguage => 'భాష మార్చండి';

  @override
  String get languageSearchHint => 'భాషను వెతకండి…';

  @override
  String get languageNoMatch => 'ఏ భాషా కనపడలేదు';

  @override
  String get topSellersTitle => 'టాప్ సెల్లర్స్';

  @override
  String get topSellersSubtitle => 'గత 2 వారాలు · వచ్చే 2 వారాల అంచనా';

  @override
  String get autoBadge => 'ఆటో';

  @override
  String coverDays(String days) {
    return '$days రోజుల స్టాక్';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 వారాలు';
  }

  @override
  String get autoRestockTitle => 'టాప్ సెల్లర్స్ ఆటో-రీస్టాక్';

  @override
  String get autoRestockSubtitle =>
      'స్టాక్ తక్కువ ఉన్న టాప్ సెల్లర్స్ రాత్రికి ఆటోమేటిక్‌గా ఆర్డర్ అవుతాయి';

  @override
  String get distributorPhoneLabel => 'డిస్ట్రిబ్యూటర్ WhatsApp నంబర్';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'సేవ్ చేయండి';

  @override
  String get settingsSaved => 'సేవ్ అయింది';

  @override
  String get ordersTitle => 'ఆర్డర్లు';

  @override
  String get ordersEmpty => 'ఇంకా ఏ ఆర్డర్ లేదు. అంచనా నుండి ఆర్డర్ చేయండి.';

  @override
  String get orderAuto => 'ఆటో';

  @override
  String get orderManual => 'మాన్యువల్';

  @override
  String get orderPlaced => 'పంపబడింది';

  @override
  String get orderCancelled => 'రద్దయింది';

  @override
  String get viewOrders => 'ఆర్డర్లు చూడండి';

  @override
  String get newOrdersNotice => 'రాత్రి ఆటో ఆర్డర్ వచ్చింది';

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
