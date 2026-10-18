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
  String get shopNameLabel => 'Shop name';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'Your name';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'Get started';

  @override
  String get requiredField => 'Please fill this in';

  @override
  String get navChat => 'Chat';

  @override
  String get navStock => 'Stock';

  @override
  String get navUdhaar => 'Credit';

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
    return 'Namaste $name! Tell me what came in, what sold, or who took credit. Hold the mic and speak.';
  }

  @override
  String get recordingCancelled => 'Released, cancelled';

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
  String get typeMessageHint => 'Type here…';

  @override
  String get send => 'Send';

  @override
  String get thinking => 'Thinking…';

  @override
  String get networkError => 'Couldn\'t reach the server. Try again.';

  @override
  String get comingSoon => 'Coming soon: shelf scan.';

  @override
  String get scanFailed => 'Couldn\'t read the photo, try again.';

  @override
  String get imageTooLarge =>
      'Photo is too big (over 8 MB). Try a smaller one.';

  @override
  String get stockTitle => 'Stock';

  @override
  String get lowStockBadge => 'Low';

  @override
  String reorderAt(String level) {
    return 'reorder at $level';
  }

  @override
  String get emptyStock => 'No stock yet. Tell me what came in.';

  @override
  String get udhaarTitle => 'Credit';

  @override
  String get totalOutstanding => 'Total due';

  @override
  String get emptyLedger =>
      'No credit yet. Say \"Gupta ji took 350 on credit\".';

  @override
  String get forecastTitle => 'Forecast';

  @override
  String get legendHistory => 'Past weeks';

  @override
  String get legendForecast => 'Forecast';

  @override
  String get legendBand => 'Likely range';

  @override
  String get orderReady => 'Order ready';

  @override
  String get shareWhatsapp => 'Send on WhatsApp';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading…';

  @override
  String get errorLoading => 'Couldn\'t load. Pull down to retry.';

  @override
  String get tagline => 'Say it, it\'s done.';

  @override
  String get languageQuestion => 'Which language should Mitra reply in?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'Fill this in';

  @override
  String get dockPhoto => 'Shelf photo';

  @override
  String get dockType => 'Type';

  @override
  String get micLabel => 'Hold and speak';

  @override
  String get recordingLabel => 'Listening… release to send';

  @override
  String get recordingCancelHint => 'Slide out to cancel';

  @override
  String get confirmHeader => 'Got it · saved';

  @override
  String get confirmTotalUdhaar => 'Credit · new total';

  @override
  String get confirmTotalStock => 'Stock · new total';

  @override
  String get confirmTotalSale => 'Sales · today\'s total';

  @override
  String get askHeader => 'Not sure';

  @override
  String askHeard(String text) {
    return 'you said “$text”';
  }

  @override
  String get askStock => 'Add to stock?';

  @override
  String get askUdhaar => 'Write it as credit?';

  @override
  String get askSale => 'Record as a sale?';

  @override
  String get askNo => 'No';

  @override
  String get askDeclined => 'Okay, not saved.';

  @override
  String scanHeader(int count) {
    return 'Shelf scanned · $count items found';
  }

  @override
  String get scanQuestion => 'Set stock to these counts?';

  @override
  String get scanConfirmed => 'Got it · stock updated';

  @override
  String stockSubtitle(int count, String time) {
    return '$count items · updated $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items are low',
      one: '1 item is low',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'All good';

  @override
  String get orderButton => 'Build order';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'Build order · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count people · ledger';
  }

  @override
  String get balanceLabel => 'Due';

  @override
  String todayGiven(String amount) {
    return 'Given today +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'Received today −₹$amount';
  }

  @override
  String get owedCaption => 'due';

  @override
  String get settledBadge => 'Settled';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount paid';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'Credit since $date · $count entries';
  }

  @override
  String lastEntryAt(String time) {
    return 'Last: $time';
  }

  @override
  String get remindButton => 'Remind';

  @override
  String get paidButton => 'Payment received';

  @override
  String get paidPrompt => 'How much came in? Speak.';

  @override
  String get historyLabel => 'History';

  @override
  String get entryGiven => 'Took credit';

  @override
  String get entryPaid => 'Paid';

  @override
  String get entrySourceVoice => 'voice';

  @override
  String get entrySourceCash => 'cash';

  @override
  String get entrySourcePhoto => 'photo';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'Hello $name, this is $shop. ₹$balance is due. Thank you!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'Next 4 weeks · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'Next 4 weeks';

  @override
  String perWeek(String unit) {
    return '$unit / week';
  }

  @override
  String get forecastFuture => 'AHEAD · forecast';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'On hand $onHand · order $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count items';
  }

  @override
  String get share => 'Share';

  @override
  String get hisaabTitle => 'Today\'s summary';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count entries';
  }

  @override
  String hisaabDayChip(String time) {
    return 'Shop closed · $time';
  }

  @override
  String get hisaabSales => 'Today\'s sales';

  @override
  String get hisaabGiven => 'Credit given';

  @override
  String get hisaabReceived => 'Credit received';

  @override
  String get hisaabOutstanding => 'Total due';

  @override
  String get hisaabLow => 'Low';

  @override
  String hisaabLowItems(String items) {
    return 'Order $items tomorrow.';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival is $weeks weeks away.';
  }

  @override
  String get hisaabOrderButton => 'Build tomorrow\'s order';

  @override
  String get hisaabShareButton => 'WhatsApp it home';

  @override
  String todayChip(String date) {
    return 'Today · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'Yesterday · $date';
  }

  @override
  String get demoNotice => 'Couldn\'t reach the server. Starting in demo mode.';

  @override
  String get languageSheetTitle => 'Which language should Mitra reply in?';

  @override
  String get backLabel => 'Back';

  @override
  String get voiceNoteLabel => 'Voice note';

  @override
  String get undo => 'Undo';

  @override
  String get feedbackButton => 'Feedback';

  @override
  String get feedbackTitle => 'How is Kirana Mitra working for you?';

  @override
  String get feedbackUp => 'Good';

  @override
  String get feedbackDown => 'Not good';

  @override
  String get feedbackCommentHint => 'Anything else? Type it here…';

  @override
  String get feedbackVoiceHint => 'Or hold and speak';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'Voice ready · ${seconds}s';
  }

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackPickRating => 'Pick Good or Not good first';

  @override
  String get feedbackThanks => 'Thank you!';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get languageSearchHint => 'Search languages…';

  @override
  String get languageNoMatch => 'No language found';

  @override
  String get topSellersTitle => 'Top sellers';

  @override
  String get topSellersSubtitle => 'Last 2 weeks · next 2 weeks forecast';

  @override
  String get autoBadge => 'Auto';

  @override
  String coverDays(String days) {
    return '$days days';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit';
  }

  @override
  String get autoRestockTitle => 'Auto-restock top sellers';

  @override
  String get autoRestockSubtitle =>
      'Low-stock top sellers get ordered automatically overnight';

  @override
  String get distributorPhoneLabel => 'Distributor\'s WhatsApp number';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'Save';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersEmpty => 'No orders yet. Build one from Forecast.';

  @override
  String get orderAuto => 'Auto';

  @override
  String get orderManual => 'Manual';

  @override
  String get orderPlaced => 'Placed';

  @override
  String get orderCancelled => 'Cancelled';

  @override
  String get viewOrders => 'View orders';

  @override
  String get newOrdersNotice => 'Overnight auto order arrived';

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
