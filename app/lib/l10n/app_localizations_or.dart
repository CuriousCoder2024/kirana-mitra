// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'ଦୋକାନ ନାଁ';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'ଆପଣଙ୍କ ନାଁ';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'ଆରମ୍ଭ କରନ୍ତୁ';

  @override
  String get requiredField => 'ଏହା ଲେଖନ୍ତୁ';

  @override
  String get navChat => 'କଥା';

  @override
  String get navStock => 'ଷ୍ଟକ୍';

  @override
  String get navUdhaar => 'ବାକି';

  @override
  String get navForecast => 'ଆକଳନ';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'ଡେମୋ';

  @override
  String get changeShop => 'ଦୋକାନ ବଦଳାନ୍ତୁ';

  @override
  String welcomeMessage(String name) {
    return 'ନମସ୍କାର $name! କ’ଣ ଆସିଲା, କ’ଣ ବିକ୍ରି ହେଲା କିମ୍ବା କିଏ ବାକି ନେଲା କୁହନ୍ତୁ। ମାଇକ୍ ଚାପି ଧରି କୁହନ୍ତୁ।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'ନମସ୍କାର $name! କୁହନ୍ତୁ: କ’ଣ ଆସିଲା, କ’ଣ ବିକ୍ରି ହେଲା, କାହାକୁ ବାକି ଦେଲେ। ମାଇକ୍ ଚାପି ରଖି କୁହନ୍ତୁ।';
  }

  @override
  String get recordingCancelled => 'ଛାଡ଼ିଦିଅନ୍ତୁ, ବାତିଲ ହୋଇଗଲା';

  @override
  String get voiceTooShort => 'ଆଉ ଟିକେ ଚାପି ଧରି କୁହନ୍ତୁ';

  @override
  String get micPermissionDenied => 'ଭଏସ୍ ନୋଟ୍ ପାଇଁ ମାଇକ୍ରୋଫୋନ୍ ଅନୁମତି ଦରକାର।';

  @override
  String get voiceNoteSent => '🎤 ଭଏସ୍ ନୋଟ୍';

  @override
  String get photoSent => '📷 ସେଲ୍ଫ୍ ଫଟୋ';

  @override
  String get typeMessageHint => 'ଏଠାରେ ଲେଖନ୍ତୁ…';

  @override
  String get send => 'ପଠାନ୍ତୁ';

  @override
  String get thinking => 'ଭାବୁଛି…';

  @override
  String get networkError =>
      'ସର୍ଭର ସହ ଯୋଡ଼ି ହୋଇପାରିଲା ନାହିଁ। ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get comingSoon => 'ଶୀଘ୍ର ଆସୁଛି! ସେଲ୍ଫ୍ ସ୍କାନ୍ ଖୁବ୍ ଶୀଘ୍ର ଆସିବ।';

  @override
  String get scanFailed => 'ଫଟୋ ବୁଝାପଡ଼ିଲା ନାହିଁ, ପୁଣି ଥରେ ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get imageTooLarge =>
      'ଫଟୋ ବହୁତ ବଡ଼ ଅଛି (8 MB ରୁ ଅଧିକ)। ଛୋଟ ଫଟୋ ବ୍ୟବହାର କରନ୍ତୁ।';

  @override
  String get stockTitle => 'ଷ୍ଟକ୍';

  @override
  String get lowStockBadge => 'କମ ଅଛି';

  @override
  String reorderAt(String level) {
    return '$level ରେ ପୁଣି ମଗାନ୍ତୁ';
  }

  @override
  String get emptyStock => 'ଏବେ ଷ୍ଟକ୍ ନାହିଁ। କୁହନ୍ତୁ କ’ଣ ଆସିଲା।';

  @override
  String get udhaarTitle => 'ବାକି';

  @override
  String get totalOutstanding => 'ମୋଟ ବାକି';

  @override
  String get emptyLedger =>
      'ଏବେ କିଛି ବାକି ନାହିଁ। କୁହନ୍ତୁ \"ଗୁପ୍ତାଜୀଙ୍କୁ 350 ବାକି ଦେଲି\"।';

  @override
  String get forecastTitle => 'ଆକଳନ';

  @override
  String get legendHistory => 'ଗତ ସପ୍ତାହ';

  @override
  String get legendForecast => 'ଅନୁମାନ';

  @override
  String get legendBand => 'ରେଞ୍ଜ୍';

  @override
  String get orderReady => 'ଅର୍ଡର ପ୍ରସ୍ତୁତ';

  @override
  String get shareWhatsapp => 'WhatsApp ରେ ପଠାନ୍ତୁ';

  @override
  String get copied => 'କପି ହୋଇଗଲା';

  @override
  String get copy => 'କପି';

  @override
  String get retry => 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get loading => 'ଲୋଡ୍ ହେଉଛି…';

  @override
  String get errorLoading => 'ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ। ତଳକୁ ଟାଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get tagline => 'କୁହନ୍ତୁ, ହୋଇଯିବ।';

  @override
  String get languageQuestion => 'Mitra କେଉଁ ଭାଷାରେ କହିବେ?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'ଏହା ଲେଖନ୍ତୁ';

  @override
  String get dockPhoto => 'ସେଲ୍ଫ୍ ଫଟୋ';

  @override
  String get dockType => 'ଲେଖନ୍ତୁ';

  @override
  String get micLabel => 'ଚାପି ଧରି କୁହନ୍ତୁ';

  @override
  String get recordingLabel => 'ଶୁଣୁଛି… ଛାଡ଼ିଲେ ପଠାଯିବ';

  @override
  String get recordingCancelHint => 'ବାତିଲ କରିବାକୁ ଆଙ୍ଗୁଠି ବାହାରକୁ ନିଅନ୍ତୁ';

  @override
  String get confirmHeader => 'ବୁଝିଗଲି · ଲେଖିଦେଲି';

  @override
  String get confirmTotalUdhaar => 'ବାକି · ଏବେ ମୋଟ';

  @override
  String get confirmTotalStock => 'ଷ୍ଟକ୍ · ଏବେ ମୋଟ';

  @override
  String get confirmTotalSale => 'ବିକ୍ରି · ଆଜିର ମୋଟ';

  @override
  String get askHeader => 'ନିଶ୍ଚିତ ନୁହେଁ';

  @override
  String askHeard(String text) {
    return 'ଆପଣ କହିଲେ “$text”';
  }

  @override
  String get askStock => 'ଷ୍ଟକ୍‌ରେ ଯୋଡ଼ିବି?';

  @override
  String get askUdhaar => 'ବାକିରେ ଲେଖିବି?';

  @override
  String get askSale => 'ବିକ୍ରିରେ ଲେଖିବି?';

  @override
  String get askNo => 'ନା';

  @override
  String get askDeclined => 'ଠିକ୍ ଅଛି, ଲେଖିଲି ନାହିଁ।';

  @override
  String scanHeader(int count) {
    return 'ସେଲ୍ଫ୍ ଦେଖିଲି · $countଟି ଜିନିଷ ମିଳିଲା';
  }

  @override
  String get scanQuestion => 'ଷ୍ଟକ୍ ଏତିକି ସେଟ୍ କରିବି?';

  @override
  String get scanConfirmed => 'ବୁଝିଗଲି · ଷ୍ଟକ୍ ଅପଡେଟ୍ ହୋଇଗଲା';

  @override
  String stockSubtitle(int count, String time) {
    return '$countଟି ଜିନିଷ · ଅପଡେଟ୍ $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countଟି ଜିନିଷ କମ ଅଛି',
      one: '1ଟି ଜିନିଷ କମ ଅଛି',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'ସବୁ ଠିକ୍ ଅଛି';

  @override
  String get orderButton => 'ଅର୍ଡର କରନ୍ତୁ';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ଅର୍ଡର କରନ୍ତୁ · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count ଜଣ · ଖାତା';
  }

  @override
  String get balanceLabel => 'ବାକି';

  @override
  String todayGiven(String amount) {
    return 'ଆଜି ଦେଲେ +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'ଆଜି ଆସିଲା −₹$amount';
  }

  @override
  String get owedCaption => 'ବାକି';

  @override
  String get settledBadge => 'ଚୁକତା';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount ଆସିଲା';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'ବାକି ଆରମ୍ଭ $date · $countଟି ହିସାବ';
  }

  @override
  String lastEntryAt(String time) {
    return 'ଶେଷ: $time';
  }

  @override
  String get remindButton => 'ମନେ ପକାନ୍ତୁ';

  @override
  String get paidButton => 'ଟଙ୍କା ଆସିଲା';

  @override
  String get paidPrompt => 'କେତେ ଆସିଲା? କୁହନ୍ତୁ।';

  @override
  String get historyLabel => 'ପୂର୍ବ ରେକର୍ଡ';

  @override
  String get entryGiven => 'ବାକି ନେଲେ';

  @override
  String get entryPaid => 'ଟଙ୍କା ଆସିଲା';

  @override
  String get entrySourceVoice => 'voice';

  @override
  String get entrySourceCash => 'cash';

  @override
  String get entrySourcePhoto => 'photo';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'ନମସ୍କାର $name ଜୀ, $shop ତରଫରୁ। ଆପଣଙ୍କର ₹$balance ବାକି ଅଛି। ଧନ୍ୟବାଦ!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'ଆଗାମୀ 4 ସପ୍ତାହ · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'ଆଗାମୀ 4 ସପ୍ତାହ';

  @override
  String perWeek(String unit) {
    return '$unit / ସପ୍ତାହ';
  }

  @override
  String get forecastFuture => 'ଆଗକୁ · ଆକଳନ';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'ଷ୍ଟକ୍‌ରେ $onHand · ମଗାନ୍ତୁ $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$countଟି ଜିନିଷ';
  }

  @override
  String get share => 'ସେୟାର';

  @override
  String get hisaabTitle => 'ଆଜିର ହିସାବ';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $countଟି ଏଣ୍ଟ୍ରି';
  }

  @override
  String hisaabDayChip(String time) {
    return 'ଦୋକାନ ବନ୍ଦ · $time';
  }

  @override
  String get hisaabSales => 'ଆଜିର ବିକ୍ରି';

  @override
  String get hisaabGiven => 'ବାକି ଦେଲେ';

  @override
  String get hisaabReceived => 'ବାକି ଆସିଲା';

  @override
  String get hisaabOutstanding => 'ମୋଟ ବାକି';

  @override
  String get hisaabLow => 'କମ ଅଛି';

  @override
  String hisaabLowItems(String items) {
    return '$items କାଲି ମଗାନ୍ତୁ।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks ସପ୍ତାହ ବାକି ଅଛି।';
  }

  @override
  String get hisaabOrderButton => 'କାଲି ପାଇଁ ଅର୍ଡର କରନ୍ତୁ';

  @override
  String get hisaabShareButton => 'ଘରକୁ WhatsApp କରନ୍ତୁ';

  @override
  String todayChip(String date) {
    return 'ଆଜି · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'ଗତକାଲି · $date';
  }

  @override
  String get demoNotice => 'ସର୍ଭର ମିଳିଲା ନାହିଁ। ଡେମୋ ମୋଡ୍‌ରେ ଚାଲୁ କରୁଛି।';

  @override
  String get languageSheetTitle => 'Mitra କେଉଁ ଭାଷାରେ କହିବେ?';

  @override
  String get backLabel => 'ପଛକୁ';

  @override
  String get voiceNoteLabel => 'ଭଏସ୍ ନୋଟ୍';

  @override
  String get undo => 'ପୂର୍ବବତ୍';

  @override
  String get feedbackButton => 'ମତାମତ';

  @override
  String get feedbackTitle => 'Kirana Mitra କେମିତି ଚାଲିଛି?';

  @override
  String get feedbackUp => 'ଭଲ';

  @override
  String get feedbackDown => 'ଠିକ୍ ନୁହେଁ';

  @override
  String get feedbackCommentHint => 'ଆଉ କିଛି କହିବାକୁ ଚାହାନ୍ତି ତ ଲେଖନ୍ତୁ…';

  @override
  String get feedbackVoiceHint => 'କିମ୍ବା ଚାପି ଧରି କୁହନ୍ତୁ';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'ଭଏସ୍ ପ୍ରସ୍ତୁତ · ${seconds}s';
  }

  @override
  String get feedbackSend => 'ପଠାନ୍ତୁ';

  @override
  String get feedbackPickRating => 'ପ୍ରଥମେ ଭଲ କିମ୍ବା ଠିକ୍ ନୁହେଁ ବାଛନ୍ତୁ';

  @override
  String get feedbackThanks => 'ଧନ୍ୟବାଦ!';

  @override
  String get changeLanguage => 'ଭାଷା ବଦଳାନ୍ତୁ';

  @override
  String get languageSearchHint => 'ଭାଷା ଖୋଜନ୍ତୁ…';

  @override
  String get languageNoMatch => 'କୌଣସି ଭାଷା ମିଳିଲା ନାହିଁ';

  @override
  String get topSellersTitle => 'ସବୁଠୁ ଅଧିକ ବିକ୍ରି';

  @override
  String get topSellersSubtitle => 'ଗତ 2 ସପ୍ତାହ · ଆଗାମୀ 2 ସପ୍ତାହର ଅନୁମାନ';

  @override
  String get autoBadge => 'ଅଟୋ';

  @override
  String coverDays(String days) {
    return '$days ଦିନର ଷ୍ଟକ୍';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 ସପ୍ତାହ';
  }

  @override
  String get autoRestockTitle => 'ଟପ୍ ସେଲର୍ସ ଅଟୋ-ରିଷ୍ଟକ୍';

  @override
  String get autoRestockSubtitle =>
      'କମ ଷ୍ଟକ୍ ଥିବା ଜିନିଷର ଅର୍ଡର ରାତିରେ ନିଜେ ନିଜେ ଚାଲିଯିବ';

  @override
  String get distributorPhoneLabel => 'Distributor ଙ୍କ WhatsApp ନମ୍ବର';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'ସେଭ୍ କରନ୍ତୁ';

  @override
  String get settingsSaved => 'ସେଭ୍ ହୋଇଗଲା';

  @override
  String get ordersTitle => 'ଅର୍ଡର';

  @override
  String get ordersEmpty => 'ଏବେ କୌଣସି ଅର୍ଡର ନାହିଁ। ଆକଳନରୁ ଅର୍ଡର କରନ୍ତୁ।';

  @override
  String get orderAuto => 'ଅଟୋ';

  @override
  String get orderManual => 'ମାନୁଆଲ୍';

  @override
  String get orderPlaced => 'ପଠାଗଲା';

  @override
  String get orderCancelled => 'ବାତିଲ ହେଲା';

  @override
  String get viewOrders => 'ଅର୍ଡର ଦେଖନ୍ତୁ';

  @override
  String get newOrdersNotice => 'ରାତିର ଅଟୋ ଅର୍ଡର ଆସିଲା';
}
