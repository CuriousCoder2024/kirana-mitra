// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'દુકાનનું નામ';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'તમારું નામ';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'શરૂ કરો';

  @override
  String get requiredField => 'કૃપા કરીને આ ભરો';

  @override
  String get navChat => 'વાત';

  @override
  String get navStock => 'સ્ટોક';

  @override
  String get navUdhaar => 'ઉધાર';

  @override
  String get navForecast => 'અંદાજ';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'ડેમો';

  @override
  String get changeShop => 'દુકાન બદલો';

  @override
  String welcomeMessage(String name) {
    return 'નમસ્તે $name! શું આવ્યું, શું વેચાયું કે કોણે ઉધાર લીધું તે જણાવો. માઇક દબાવીને બોલો.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'નમસ્તે $name! બોલો: શું આવ્યું, શું વેચાયું, કોને ઉધાર આપ્યું. માઇક દબાવીને બોલો.';
  }

  @override
  String get recordingCancelled => 'રદ કર્યું';

  @override
  String get voiceTooShort => 'જરા વધુ વાર દબાવી રાખીને બોલો';

  @override
  String get micPermissionDenied =>
      'વૉઇસ નોટ માટે માઇક્રોફોનની પરવાનગી જરૂરી છે.';

  @override
  String get voiceNoteSent => '🎤 વૉઇસ નોટ';

  @override
  String get photoSent => '📷 છાજલીનો ફોટો';

  @override
  String get typeMessageHint => 'અહીં લખો…';

  @override
  String get send => 'મોકલો';

  @override
  String get thinking => 'વિચારે છે…';

  @override
  String get networkError => 'સર્વર સાથે સંપર્ક ન થયો. ફરી પ્રયાસ કરો.';

  @override
  String get comingSoon => 'ટૂંક સમયમાં આવશે! શેલ્ફ સ્કેન જલદી આવી રહ્યું છે.';

  @override
  String get scanFailed => 'ફોટો વંચાયો નહીં, ફરી પ્રયાસ કરો.';

  @override
  String get imageTooLarge => 'ફોટો બહુ મોટો છે (8 MB થી વધુ). નાનો ફોટો પાડો.';

  @override
  String get stockTitle => 'સ્ટોક';

  @override
  String get lowStockBadge => 'ઓછો છે';

  @override
  String reorderAt(String level) {
    return '$level પર ફરી મંગાવો';
  }

  @override
  String get emptyStock => 'હજુ સ્ટોક નથી. બોલો શું આવ્યું.';

  @override
  String get udhaarTitle => 'ઉધાર';

  @override
  String get totalOutstanding => 'કુલ બાકી';

  @override
  String get emptyLedger =>
      'હજુ કોઈ ઉધાર નથી. બોલો \"ગુપ્તાજીને 350નું ઉધાર આપ્યું\".';

  @override
  String get forecastTitle => 'અંદાજ';

  @override
  String get legendHistory => 'ગયા અઠવાડિયે';

  @override
  String get legendForecast => 'અંદાજ';

  @override
  String get legendBand => 'રેન્જ';

  @override
  String get orderReady => 'ઓર્ડર તૈયાર';

  @override
  String get shareWhatsapp => 'WhatsApp પર મોકલો';

  @override
  String get copied => 'કૉપિ થઈ ગયું';

  @override
  String get copy => 'કૉપિ કરો';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get loading => 'લોડ થાય છે…';

  @override
  String get errorLoading => 'ખૂલ્યું નહીં. ફરી પ્રયાસ કરવા નીચે ખેંચો.';

  @override
  String get tagline => 'બોલો, થઈ જશે.';

  @override
  String get languageQuestion => 'Mitra કઈ ભાષામાં બોલે?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'આ વિગત ભરો';

  @override
  String get dockPhoto => 'છાજલીનો ફોટો';

  @override
  String get dockType => 'લખો';

  @override
  String get micLabel => 'દબાવીને બોલો';

  @override
  String get recordingLabel => 'સાંભળું છું… છોડશો એટલે મોકલાશે';

  @override
  String get recordingCancelHint => 'રદ કરવા આંગળી બહાર ખેંચો';

  @override
  String get confirmHeader => 'સમજી ગયો · નોંધી લીધું';

  @override
  String get confirmTotalUdhaar => 'ઉધાર · હવે કુલ';

  @override
  String get confirmTotalStock => 'સ્ટોક · હવે કુલ';

  @override
  String get confirmTotalSale => 'વેચાણ · આજનું કુલ';

  @override
  String get askHeader => 'પાકી ખબર નથી';

  @override
  String askHeard(String text) {
    return 'તમે કહ્યું “$text”';
  }

  @override
  String get askStock => 'સ્ટોકમાં ઉમેરું?';

  @override
  String get askUdhaar => 'ઉધારમાં લખું?';

  @override
  String get askSale => 'વેચાણમાં લખું?';

  @override
  String get askNo => 'ના';

  @override
  String get askDeclined => 'ભલે, નથી લખ્યું.';

  @override
  String scanHeader(int count) {
    return 'શેલ્ફ જોયું · $count વસ્તુઓ મળી';
  }

  @override
  String get scanQuestion => 'સ્ટોક આટલો નક્કી કરી દઉં?';

  @override
  String get scanConfirmed => 'સમજી ગયો · સ્ટોક અપડેટ થઈ ગયો';

  @override
  String stockSubtitle(int count, String time) {
    return '$count વસ્તુઓ · છેલ્લે $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count વસ્તુઓ ઓછી છે',
      one: '1 વસ્તુ ઓછી છે',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'બધું બરાબર છે';

  @override
  String get orderButton => 'ઓર્ડર બનાવો';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ઓર્ડર બનાવો · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count ગ્રાહકો · ખાતાવહી';
  }

  @override
  String get balanceLabel => 'બાકી';

  @override
  String todayGiven(String amount) {
    return 'આજે આપ્યા +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'આજે આવ્યા −₹$amount';
  }

  @override
  String get owedCaption => 'બાકી';

  @override
  String get settledBadge => 'ચૂકતે';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount આવ્યા';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'ઉધાર શરૂ $date · $count એન્ટ્રી';
  }

  @override
  String lastEntryAt(String time) {
    return 'છેલ્લે: $time';
  }

  @override
  String get remindButton => 'યાદ અપાવો';

  @override
  String get paidButton => 'રૂપિયા આવ્યા';

  @override
  String get paidPrompt => 'કેટલા આવ્યા? બોલો.';

  @override
  String get historyLabel => 'ઇતિહાસ';

  @override
  String get entryGiven => 'ઉધાર આપ્યું';

  @override
  String get entryPaid => 'રૂપિયા આવ્યા';

  @override
  String get entrySourceVoice => 'અવાજ';

  @override
  String get entrySourceCash => 'રોકડ';

  @override
  String get entrySourcePhoto => 'ફોટો';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'નમસ્તે $nameજી, $shop તરફથી. આપના ₹$balance બાકી છે. આભાર!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'આવતા 4 અઠવાડિયા · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'આવતા 4 અઠવાડિયા';

  @override
  String perWeek(String unit) {
    return '$unit / અઠવાડિયું';
  }

  @override
  String get forecastFuture => 'આગળ · અંદાજ';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'સ્ટોકમાં $onHand · મંગાવો $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count વસ્તુઓ';
  }

  @override
  String get share => 'શેર કરો';

  @override
  String get hisaabTitle => 'આજનો હિસાબ';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count એન્ટ્રી';
  }

  @override
  String hisaabDayChip(String time) {
    return 'દુકાન બંધ · $time';
  }

  @override
  String get hisaabSales => 'આજનું વેચાણ';

  @override
  String get hisaabGiven => 'ઉધાર આપ્યું';

  @override
  String get hisaabReceived => 'ઉધાર આવ્યું';

  @override
  String get hisaabOutstanding => 'કુલ બાકી';

  @override
  String get hisaabLow => 'ઓછો છે';

  @override
  String hisaabLowItems(String items) {
    return '$items કાલે મંગાવો.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks અઠવાડિયા દૂર છે.';
  }

  @override
  String get hisaabOrderButton => 'કાલનો ઓર્ડર બનાવો';

  @override
  String get hisaabShareButton => 'ઘરે WhatsApp કરો';

  @override
  String todayChip(String date) {
    return 'આજે · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'ગઈકાલે · $date';
  }

  @override
  String get demoNotice => 'સર્વર મળ્યું નથી. ડેમો મોડમાં શરૂ કરી રહ્યા છીએ.';

  @override
  String get languageSheetTitle => 'Mitra કઈ ભાષામાં બોલે?';

  @override
  String get backLabel => 'પાછા જાઓ';

  @override
  String get voiceNoteLabel => 'વૉઇસ નોટ';

  @override
  String get undo => 'પહેલાં જેવું કરો';

  @override
  String get feedbackButton => 'પ્રતિભાવ';

  @override
  String get feedbackTitle => 'Kirana Mitra કેવું ચાલે છે?';

  @override
  String get feedbackUp => 'સરસ';

  @override
  String get feedbackDown => 'બરાબર નથી';

  @override
  String get feedbackCommentHint => 'બીજું કંઈ જણાવવું હોય તો લખો…';

  @override
  String get feedbackVoiceHint => 'અથવા દબાવીને બોલો';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'અવાજ તૈયાર · $seconds સેકન્ડ';
  }

  @override
  String get feedbackSend => 'મોકલો';

  @override
  String get feedbackPickRating => 'પહેલાં સારું કે ખરાબ પસંદ કરો';

  @override
  String get feedbackThanks => 'ખૂબ આભાર!';

  @override
  String get changeLanguage => 'ભાષા બદલો';

  @override
  String get languageSearchHint => 'ભાષા શોધો…';

  @override
  String get languageNoMatch => 'કોઈ ભાષા ન મળી';

  @override
  String get topSellersTitle => 'સૌથી વધુ વેચાતી વસ્તુઓ';

  @override
  String get topSellersSubtitle =>
      'છેલ્લા 2 અઠવાડિયા · આગળના 2 અઠવાડિયાનો અંદાજ';

  @override
  String get autoBadge => 'ઑટો';

  @override
  String coverDays(String days) {
    return '$days દિવસનો સ્ટોક';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 અઠવાડિયા';
  }

  @override
  String get autoRestockTitle => 'ટોપ સેલર્સ આપોઆપ રીસ્ટોક કરો';

  @override
  String get autoRestockSubtitle =>
      'ઓછા સ્ટોકવાળા ટોપ સેલર્સનો ઓર્ડર રાત્રે આપમેળે જતો રહેશે';

  @override
  String get distributorPhoneLabel => 'ડિસ્ટ્રીબ્યુટરનો WhatsApp નંબર';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'સાચવો';

  @override
  String get settingsSaved => 'સેવ થઈ ગયું';

  @override
  String get ordersTitle => 'ઓર્ડર્સ';

  @override
  String get ordersEmpty => 'હજુ કોઈ ઓર્ડર નથી. અંદાજમાંથી ઓર્ડર બનાવો.';

  @override
  String get orderAuto => 'ઑટો';

  @override
  String get orderManual => 'મેન્યુઅલ';

  @override
  String get orderPlaced => 'મોકલાયો';

  @override
  String get orderCancelled => 'રદ થયો';

  @override
  String get viewOrders => 'ઓર્ડર જુઓ';

  @override
  String get newOrdersNotice => 'રાતનો ઑટો ઓર્ડર આવ્યો';
}
