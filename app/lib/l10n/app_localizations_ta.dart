// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'கடை பெயர்';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'உங்கள் பெயர்';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'தொடங்குங்க';

  @override
  String get requiredField => 'இதை நிரப்பவும்';

  @override
  String get navChat => 'பேச';

  @override
  String get navStock => 'ஸ்டாக்';

  @override
  String get navUdhaar => 'கடன்';

  @override
  String get navForecast => 'மதிப்பீடு';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'டெமோ';

  @override
  String get changeShop => 'கடையை மாற்று';

  @override
  String welcomeMessage(String name) {
    return 'வணக்கம் $name! என்ன வந்தது, என்ன விற்றது, யார் கடன் வாங்கினாங்கனு சொல்லுங்க. மைக் அழுத்திப் பேசுங்க.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'வணக்கம் $name! என்ன வந்தது, என்ன விற்றது, யார் கடன் வாங்கினாங்கனு சொல்லுங்க. மைக் அழுத்திப் பேசுங்க.';
  }

  @override
  String get recordingCancelled => 'ரத்து செய்யப்பட்டது';

  @override
  String get voiceTooShort => 'கொஞ்சம் நேரம் அழுத்திப் பேசுங்க';

  @override
  String get micPermissionDenied => 'வாய்ஸ் மெசேஜுக்கு மைக் அனுமதி தேவை.';

  @override
  String get voiceNoteSent => '🎤 வாய்ஸ் மெசேஜ்';

  @override
  String get photoSent => '📷 அலமாரி படம்';

  @override
  String get typeMessageHint => 'இங்கே எழுதுங்க…';

  @override
  String get send => 'அனுப்பு';

  @override
  String get thinking => 'யோசிக்கிறேன்…';

  @override
  String get networkError => 'இணைக்க முடியவில்லை. மீண்டும் முயற்சி செய்யவும்.';

  @override
  String get comingSoon => 'விரைவில் வருது! அலமாரி ஸ்கேன் விரைவில் வரும்.';

  @override
  String get scanFailed => 'படம் புரியல, திரும்ப முயற்சி செய்யுங்க.';

  @override
  String get imageTooLarge =>
      'படம் ரொம்ப பெருசு (8 MB மேல்). சிறிய படத்தை அனுப்பவும்.';

  @override
  String get stockTitle => 'ஸ்டாக்';

  @override
  String get lowStockBadge => 'குறைவா இருக்கு';

  @override
  String reorderAt(String level) {
    return '$level வந்ததும் ஆர்டர் செய்';
  }

  @override
  String get emptyStock =>
      'இப்போதைக்கு ஸ்டாக் இல்லை. என்ன வந்ததுன்னு சொல்லுங்க.';

  @override
  String get udhaarTitle => 'கடன்';

  @override
  String get totalOutstanding => 'மொத்த பாக்கி';

  @override
  String get emptyLedger =>
      'கடன் ஏதும் இல்லை. \"குப்தா அண்ணனுக்கு 350 ரூபாய் கடன்\"னு சொல்லுங்க.';

  @override
  String get forecastTitle => 'மதிப்பீடு';

  @override
  String get legendHistory => 'கடந்த வாரம்';

  @override
  String get legendForecast => 'மதிப்பீடு';

  @override
  String get legendBand => 'வரம்பு';

  @override
  String get orderReady => 'ஆர்டர் தயார்';

  @override
  String get shareWhatsapp => 'WhatsApp-ல் அனுப்பு';

  @override
  String get copied => 'காப்பி செய்யப்பட்டது';

  @override
  String get copy => 'காப்பி';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get loading => 'ஏற்றுகிறது…';

  @override
  String get errorLoading =>
      'ஏற்ற முடியவில்லை. கீழே இழுத்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get tagline => 'சொல்லுங்க, முடிச்சிடலாம்.';

  @override
  String get languageQuestion => 'மித்ரா எந்த மொழியில் பேசட்டும்?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'இதை நிரப்புங்க';

  @override
  String get dockPhoto => 'அலமாரி படம்';

  @override
  String get dockType => 'டைப் செய்';

  @override
  String get micLabel => 'அழுத்திப் பேசுங்க';

  @override
  String get recordingLabel => 'கேட்கிறேன்… விரலை எடுத்தால் அனுப்பப்படும்';

  @override
  String get recordingCancelHint => 'ரத்து செய்ய விரலை வெளியே நகர்த்தவும்';

  @override
  String get confirmHeader => 'புரிந்தது · குறித்துவிட்டேன்';

  @override
  String get confirmTotalUdhaar => 'கடன் · இப்போதைய மொத்தம்';

  @override
  String get confirmTotalStock => 'ஸ்டாக் · இப்போதைய மொத்தம்';

  @override
  String get confirmTotalSale => 'விற்பனை · இன்றைய மொத்தம்';

  @override
  String get askHeader => 'சரியாக தெரியவில்லை';

  @override
  String askHeard(String text) {
    return 'நீங்கள் சொன்னது “$text”';
  }

  @override
  String get askStock => 'ஸ்டாக்கில் சேர்க்கவா?';

  @override
  String get askUdhaar => 'கடனில் எழுதவா?';

  @override
  String get askSale => 'விற்பனையில் எழுதவா?';

  @override
  String get askNo => 'இல்லை';

  @override
  String get askDeclined => 'சரி, எழுதவில்லை.';

  @override
  String scanHeader(int count) {
    return 'அலமாரி பார்த்தாச்சு · $count பொருட்கள் உள்ளன';
  }

  @override
  String get scanQuestion => 'ஸ்டாக்கை இப்படி வைக்கவா?';

  @override
  String get scanConfirmed => 'புரிந்தது · ஸ்டாக் புதுப்பிக்கப்பட்டது';

  @override
  String stockSubtitle(int count, String time) {
    return '$count பொருட்கள் · அப்டேட் $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொருட்கள் குறைவா இருக்கு',
      one: '1 பொருள் குறைவா இருக்கு',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'எல்லாம் சரியா இருக்கு';

  @override
  String get orderButton => 'ஆர்டர் போடுங்க';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'ஆர்டர் போடுங்க · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count நபர்கள் · கணக்கு புத்தகம்';
  }

  @override
  String get balanceLabel => 'பாக்கி';

  @override
  String todayGiven(String amount) {
    return 'இன்று கொடுத்தது +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'இன்று வந்தது −₹$amount';
  }

  @override
  String get owedCaption => 'பாக்கி';

  @override
  String get settledBadge => 'செட்டில் ஆனது';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount வந்தது';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'கடன் தொடக்கம் $date · $count பதிவுகள்';
  }

  @override
  String lastEntryAt(String time) {
    return 'கடைசியாக: $time';
  }

  @override
  String get remindButton => 'நினைவூட்டு';

  @override
  String get paidButton => 'பணம் வந்தது';

  @override
  String get paidPrompt => 'எவ்வளவு வந்தது? சொல்லுங்க.';

  @override
  String get historyLabel => 'வரலாறு';

  @override
  String get entryGiven => 'கடன் கொடுக்கப்பட்டது';

  @override
  String get entryPaid => 'பணம் வந்தது';

  @override
  String get entrySourceVoice => 'வாய்ஸ்';

  @override
  String get entrySourceCash => 'பணம்';

  @override
  String get entrySourcePhoto => 'படம்';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'வணக்கம் $name அவர்களே, $shop-லிருந்து. தங்களின் ₹$balance பாக்கி உள்ளது. நன்றி!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'அடுத்த 4 வாரங்கள் · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'அடுத்த 4 வாரங்கள்';

  @override
  String perWeek(String unit) {
    return '$unit / வாரம்';
  }

  @override
  String get forecastFuture => 'அடுத்து · மதிப்பீடு';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'இருப்பில் $onHand · ஆர்டர் $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count பொருட்கள்';
  }

  @override
  String get share => 'பகிர்';

  @override
  String get hisaabTitle => 'இன்றைய கணக்கு';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count பதிவுகள்';
  }

  @override
  String hisaabDayChip(String time) {
    return 'கடை மூடல் · $time';
  }

  @override
  String get hisaabSales => 'இன்றைய விற்பனை';

  @override
  String get hisaabGiven => 'கடன் கொடுத்தது';

  @override
  String get hisaabReceived => 'கடன் வசூல்';

  @override
  String get hisaabOutstanding => 'மொத்த பாக்கி';

  @override
  String get hisaabLow => 'குறைவா இருக்கு';

  @override
  String hisaabLowItems(String items) {
    return '$items நாளைக்கு ஆர்டர் பண்ணுங்க.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival வர இன்னும் $weeks வாரங்கள் உள்ளன.';
  }

  @override
  String get hisaabOrderButton => 'நாளைக்கான ஆர்டர் போடுங்க';

  @override
  String get hisaabShareButton => 'வீட்டுக்கு WhatsApp பண்ணுங்க';

  @override
  String todayChip(String date) {
    return 'இன்று · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'நேற்று · $date';
  }

  @override
  String get demoNotice => 'சர்வர் கிடைக்கவில்லை. டெமோ முறையில் துவங்குகிறது.';

  @override
  String get languageSheetTitle => 'மித்ரா எந்த மொழியில் பேசட்டும்?';

  @override
  String get backLabel => 'பின்னால்';

  @override
  String get voiceNoteLabel => 'வாய்ஸ் மெசேஜ்';

  @override
  String get undo => 'Undo';

  @override
  String get feedbackButton => 'கருத்து';

  @override
  String get feedbackTitle => 'Kirana Mitra எப்படி இருக்கு?';

  @override
  String get feedbackUp => 'நன்றாக உள்ளது';

  @override
  String get feedbackDown => 'சரி இல்லை';

  @override
  String get feedbackCommentHint => 'வேறு ஏதேனும் சொல்ல விரும்பினால் எழுதுங்க…';

  @override
  String get feedbackVoiceHint => 'அல்லது அழுத்திப் பேசுங்க';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'குரல் தயார் · $secondsவி';
  }

  @override
  String get feedbackSend => 'அனுப்பு';

  @override
  String get feedbackPickRating =>
      'முதலில் பிடித்ததா இல்லையா என்பதை தேர்ந்தெடுக்கவும்';

  @override
  String get feedbackThanks => 'நன்றி!';

  @override
  String get changeLanguage => 'மொழி மாற்று';

  @override
  String get languageSearchHint => 'மொழியைத் தேடுங்க…';

  @override
  String get languageNoMatch => 'மொழி எதுவும் கிடைக்கவில்லை';

  @override
  String get topSellersTitle => 'அதிகம் விற்பவை';

  @override
  String get topSellersSubtitle => 'கடந்த 2 வாரங்கள் · அடுத்த 2 வார கணிப்பு';

  @override
  String get autoBadge => 'ஆட்டோ';

  @override
  String coverDays(String days) {
    return '$days நாட்களுக்கு ஸ்டாக்';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 வாரம்';
  }

  @override
  String get autoRestockTitle => 'அதிகம் விற்பவைக்கு ஆட்டோ ஆர்டர்';

  @override
  String get autoRestockSubtitle =>
      'குறைந்த ஸ்டாக் உள்ள அதிகம் விற்பவைக்கு இரவில் தானாக ஆர்டர் போகும்';

  @override
  String get distributorPhoneLabel => 'டிஸ்ட்ரிபியூட்டர் WhatsApp எண்';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'சேமி';

  @override
  String get settingsSaved => 'சேமிக்கப்பட்டது';

  @override
  String get ordersTitle => 'ஆர்டர்கள்';

  @override
  String get ordersEmpty =>
      'இப்போதைக்கு ஆர்டர் இல்லை. கணிப்பிலிருந்து ஆர்டர் போடுங்க.';

  @override
  String get orderAuto => 'ஆட்டோ';

  @override
  String get orderManual => 'மேனுவல்';

  @override
  String get orderPlaced => 'அனுப்பப்பட்டது';

  @override
  String get orderCancelled => 'ரத்து செய்யப்பட்டது';

  @override
  String get viewOrders => 'ஆர்டர்களைப் பார்க்க';

  @override
  String get newOrdersNotice => 'இரவின் ஆட்டோ ஆர்டர் வந்தது';

  @override
  String get shopReRegistered =>
      'The server restarted, so the shop was registered again.';

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
      'Pick a shelf; it is scanned exactly like a camera photo.';

  @override
  String get askYes => 'Yes, add';

  @override
  String scanUnmatched(String items) {
    return 'Seen but not in the catalogue: $items';
  }
}
