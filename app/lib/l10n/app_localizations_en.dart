// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get requiredField => 'Please fill this in';

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
  String get changeShop => 'Change shop';

  @override
  String welcomeMessage(String name) {
    return 'Namaste $name! Tell me what came in, what sold, or who took udhaar. Hold the mic and speak.';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'Namaste $name! Bolo: kya aaya, kya bika, kisko udhaar diya. Mic dabake rakho aur bolo.';
  }

  @override
  String get recordingCancelled => 'Chhod do, cancel ho gaya';

  @override
  String get voiceTooShort => 'Hold a bit longer and speak';

  @override
  String get micPermissionDenied =>
      'Microphone permission is needed for voice notes.';

  @override
  String get voiceNoteSent => '🎤 Voice note';

  @override
  String get photoSent => '📷 Shelf photo';

  @override
  String get typeMessageHint => 'Yahan likho…';

  @override
  String get send => 'Send';

  @override
  String get thinking => 'Thinking…';

  @override
  String get networkError => 'Couldn\'t reach the server. Try again.';

  @override
  String get comingSoon => 'Jaldi aa raha hai! Shelf scan is coming soon.';

  @override
  String get scanFailed => 'Photo samajh nahi aayi, phir se try karo.';

  @override
  String get imageTooLarge =>
      'Photo is too big (over 8 MB). Try a smaller one.';

  @override
  String get stockTitle => 'Stock';

  @override
  String get lowStockBadge => 'Kam hai';

  @override
  String reorderAt(String level) {
    return 'reorder at $level';
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
  String get retry => 'Try again';

  @override
  String get loading => 'Loading…';

  @override
  String get errorLoading => 'Couldn\'t load. Pull down to retry.';

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
    return '$days din';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit';
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
}
