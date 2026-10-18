// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sanskrit (`sa`).
class AppLocalizationsSa extends AppLocalizations {
  AppLocalizationsSa([String locale = 'sa']) : super(locale);

  @override
  String get appTitle => 'Kirana Mitra';

  @override
  String get shopNameLabel => 'आपणस्य नाम';

  @override
  String get shopNameHint => 'Gupta General Store';

  @override
  String get ownerNameLabel => 'भवतः नाम';

  @override
  String get ownerNameHint => 'Ramesh Gupta';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langEnglish => 'English';

  @override
  String get langHinglish => 'Hinglish';

  @override
  String get startButton => 'आरभ्यताम्';

  @override
  String get requiredField => 'कृपया एतत् पूरयतु';

  @override
  String get navChat => 'वार्ता';

  @override
  String get navStock => 'संग्रहः';

  @override
  String get navUdhaar => 'ऋणम्';

  @override
  String get navForecast => 'पूर्वानुमानम्';

  @override
  String get chatTitle => 'Kirana Mitra';

  @override
  String get demoMode => 'परीक्षणम्';

  @override
  String get changeShop => 'आपणं परिवर्तयतु';

  @override
  String welcomeMessage(String name) {
    return 'नमस्ते $name! किं समागतम्, किं विक्रीतम्, कस्मै ऋणं दत्तम् इति वदतु। ध्वनिग्राहिकां संपीड्य भाषताम्।';
  }

  @override
  String welcomeMessageHinglish(String name) {
    return 'नमस्ते $name! वदतु: किं समागतम्, किं विक्रीतम्, कस्मै ऋणं दत्तम्। ध्वनिग्राहिकां संपीड्य भाषताम्।';
  }

  @override
  String get recordingCancelled => 'त्यक्तम्, निरस्तम्';

  @override
  String get voiceTooShort => 'किञ्चित्कालं संपीड्य वदतु';

  @override
  String get micPermissionDenied =>
      'ध्वनिसन्देशार्थं ध्वनिग्राहिकायाः अनुमतिः आवश्यकी।';

  @override
  String get voiceNoteSent => '🎤 ध्वनिसन्देशः';

  @override
  String get photoSent => '📷 पट्टिकाचित्रम्';

  @override
  String get typeMessageHint => 'अत्र लिखतु…';

  @override
  String get send => 'प्रेषयतु';

  @override
  String get thinking => 'चिन्तयन्…';

  @override
  String get networkError => 'सम्पर्कः न जातः। पुनः प्रयतताम्।';

  @override
  String get comingSoon =>
      'शीघ्रम् आगमिष्यति! पट्टिका-स्कैन शीघ्रमेव आगमिष्यति।';

  @override
  String get scanFailed => 'चित्रं न स्पष्टम्, पुनः प्रयतताम्।';

  @override
  String get imageTooLarge =>
      'चित्रं बृहत् अस्ति (8 MB तः अधिकम्)। लघु चित्रं योजयतु।';

  @override
  String get stockTitle => 'संग्रहः';

  @override
  String get lowStockBadge => 'न्यूनम् अस्ति';

  @override
  String reorderAt(String level) {
    return '$level स्तरे पुनः आदिशतु';
  }

  @override
  String get emptyStock => 'अधुना संग्रहः नास्ति। किं समागतम् इति वदतु।';

  @override
  String get udhaarTitle => 'ऋणम्';

  @override
  String get totalOutstanding => 'कुलम् अवशिष्टम्';

  @override
  String get emptyLedger =>
      'अधुना ऋणं नास्ति। वदतु \"Gupta ji महोदयाय 350 ऋणं दत्तम्\"।';

  @override
  String get forecastTitle => 'पूर्वानुमानम्';

  @override
  String get legendHistory => 'पूर्वसप्ताहः';

  @override
  String get legendForecast => 'अनुमानम्';

  @override
  String get legendBand => 'सीमा';

  @override
  String get orderReady => 'आदेशः सज्जः';

  @override
  String get shareWhatsapp => 'WhatsApp मध्ये प्रेषयतु';

  @override
  String get copied => 'प्रतिकृतम्';

  @override
  String get copy => 'प्रतिकरोतु';

  @override
  String get retry => 'पुनः प्रयतताम्';

  @override
  String get loading => 'लोड् भवति…';

  @override
  String get errorLoading => 'लोड् न जातम्। अधः कर्षतु।';

  @override
  String get tagline => 'वदतु, भविष्यति।';

  @override
  String get languageQuestion => 'मित्रः कस्यां भाषायां वदेत्?';

  @override
  String get langSampleHindi => 'नमस्ते! आज क्या आया?';

  @override
  String get langSampleHinglish => 'Namaste! Aaj kya aaya?';

  @override
  String get langSampleEnglish => 'Hello! What came in today?';

  @override
  String get fieldRequired => 'एतत् पूरयतु';

  @override
  String get dockPhoto => 'पट्टिकाचित्रम्';

  @override
  String get dockType => 'लिखतु';

  @override
  String get micLabel => 'संपीड्य वदतु';

  @override
  String get recordingLabel => 'शृणोमि… त्यक्ते सति प्रेषयिष्यति';

  @override
  String get recordingCancelHint => 'निरसनाय अङ्गुलिं बहिः नयतु';

  @override
  String get confirmHeader => 'अवगतम् · लिखितम्';

  @override
  String get confirmTotalUdhaar => 'ऋणम् · कुलम् अधुना';

  @override
  String get confirmTotalStock => 'संग्रहः · कुलम् अधुना';

  @override
  String get confirmTotalSale => 'विक्रयः · कुलम् अद्य';

  @override
  String get askHeader => 'निश्चितं न';

  @override
  String askHeard(String text) {
    return 'भवता उक्तम् “$text”';
  }

  @override
  String get askStock => 'संग्रहे योजयामि किम्?';

  @override
  String get askUdhaar => 'ऋणरूपेण लिखामि किम्?';

  @override
  String get askSale => 'विक्रयरूपेण लिखामि किम्?';

  @override
  String get askNo => 'न';

  @override
  String get askDeclined => 'अस्तु, न लिखितम्।';

  @override
  String scanHeader(int count) {
    return 'पट्टिका दृष्टा · $count वस्तूनि लब्धानि';
  }

  @override
  String get scanQuestion => 'संग्रहः अयमेव स्थाप्यताम् किम्?';

  @override
  String get scanConfirmed => 'अवगतम् · संग्रहः नवीकृतः';

  @override
  String stockSubtitle(int count, String time) {
    return '$count वस्तूनि · नवीकृतम् $time';
  }

  @override
  String lowBandTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तूनि न्यूनानि सन्ति',
      one: '1 वस्तु न्यूनम् अस्ति',
    );
    return '$_temp0';
  }

  @override
  String get allGoodBand => 'सर्वं सम्यक् अस्ति';

  @override
  String get orderButton => 'आदेशं रचयतु';

  @override
  String orderButtonQty(String qty, String unit) {
    return 'आदेशं रचयतु · $qty $unit';
  }

  @override
  String udhaarSubtitle(int count) {
    return '$count जनाः · लेखापुस्तिका';
  }

  @override
  String get balanceLabel => 'अवशिष्टम्';

  @override
  String todayGiven(String amount) {
    return 'अद्य दत्तम् +₹$amount';
  }

  @override
  String todayReceived(String amount) {
    return 'अद्य प्राप्तम् −₹$amount';
  }

  @override
  String get owedCaption => 'अवशिष्टम्';

  @override
  String get settledBadge => 'शोधितम्';

  @override
  String lastMovementGiven(String date, String amount) {
    return '$date · +₹$amount';
  }

  @override
  String lastMovementPaid(String date, String amount) {
    return '$date · −₹$amount प्राप्तम्';
  }

  @override
  String customerSubtitle(String date, int count) {
    return 'ऋणप्रारम्भः $date · $count प्रविष्टयः';
  }

  @override
  String lastEntryAt(String time) {
    return 'अन्तिमम्: $time';
  }

  @override
  String get remindButton => 'स्मारयतु';

  @override
  String get paidButton => 'धनं प्राप्तम्';

  @override
  String get paidPrompt => 'कियत् प्राप्तम्? वदतु।';

  @override
  String get historyLabel => 'इतिहासः';

  @override
  String get entryGiven => 'ऋणं दत्तम्';

  @override
  String get entryPaid => 'धनं प्राप्तम्';

  @override
  String get entrySourceVoice => 'ध्वनिः';

  @override
  String get entrySourceCash => 'नगदम्';

  @override
  String get entrySourcePhoto => 'चित्रम्';

  @override
  String reminderText(String name, String shop, String balance) {
    return 'नमस्ते $name महोदय, $shop तः। भवतः ₹$balance अवशिष्टम् अस्ति। धन्यवादाः!';
  }

  @override
  String forecastSubtitle(String festival, String date) {
    return 'अग्रिमाः 4 सप्ताहाः · $festival $date';
  }

  @override
  String get forecastSubtitlePlain => 'अग्रिमाः 4 सप्ताहाः';

  @override
  String perWeek(String unit) {
    return '$unit / सप्ताहम्';
  }

  @override
  String get forecastFuture => 'अग्रिमम् · पूर्वानुमानम्';

  @override
  String onHandReorder(String onHand, String qty, String unit) {
    return 'हस्ते $onHand · आनयतु $qty $unit';
  }

  @override
  String orderItemCount(int count) {
    return '$count वस्तूनि';
  }

  @override
  String get share => 'वितरतु';

  @override
  String get hisaabTitle => 'अद्यतनः आयव्ययः';

  @override
  String hisaabSubtitle(String date, int count) {
    return '$date · $count प्रविष्टयः';
  }

  @override
  String hisaabDayChip(String time) {
    return 'आपणं पिहितम् · $time';
  }

  @override
  String get hisaabSales => 'अद्यतनः विक्रयः';

  @override
  String get hisaabGiven => 'ऋणं दत्तम्';

  @override
  String get hisaabReceived => 'ऋणं प्राप्तम्';

  @override
  String get hisaabOutstanding => 'कुलम् अवशिष्टम्';

  @override
  String get hisaabLow => 'न्यूनम् अस्ति';

  @override
  String hisaabLowItems(String items) {
    return '$items श्वः आनयतु।';
  }

  @override
  String hisaabFestival(String festival, String weeks) {
    return '$festival $weeks सप्ताहाः अवशिष्टाः।';
  }

  @override
  String get hisaabOrderButton => 'श्वस्तनम् आदेशं रचयतु';

  @override
  String get hisaabShareButton => 'गृहे WhatsApp प्रेषयतु';

  @override
  String todayChip(String date) {
    return 'अद्य · $date';
  }

  @override
  String yesterdayChip(String date) {
    return 'ह्यः · $date';
  }

  @override
  String get demoNotice => 'सेवकः न लब्धः। परीक्षण-स्थितौ आरभते।';

  @override
  String get languageSheetTitle => 'मित्रः कस्यां भाषायां वदेत्?';

  @override
  String get backLabel => 'पृष्ठतः';

  @override
  String get voiceNoteLabel => 'ध्वनिसन्देशः';

  @override
  String get undo => 'पूर्वावस्था';

  @override
  String get feedbackButton => 'प्रतिपुष्टिः';

  @override
  String get feedbackTitle => 'Kirana Mitra कथं प्रचलति?';

  @override
  String get feedbackUp => 'उत्तमम्';

  @override
  String get feedbackDown => 'न सम्यक्';

  @override
  String get feedbackCommentHint => 'अन्यत् वक्तव्यं चेत् लिखतु…';

  @override
  String get feedbackVoiceHint => 'वा संपीड्य वदतु';

  @override
  String feedbackVoiceReady(String seconds) {
    return 'ध्वनिः सज्जः · ${seconds}s';
  }

  @override
  String get feedbackSend => 'प्रेषयतु';

  @override
  String get feedbackPickRating => 'प्रथमम् उत्तमं वा न सम्यक् वा चिनोतु';

  @override
  String get feedbackThanks => 'धन्यवादाः!';

  @override
  String get changeLanguage => 'भाषां परिवर्तयतु';

  @override
  String get languageSearchHint => 'भाषां अन्विष्यतु…';

  @override
  String get languageNoMatch => 'कापि भाषा न लब्धा';

  @override
  String get topSellersTitle => 'मुख्यविक्रयाः';

  @override
  String get topSellersSubtitle =>
      'पूर्वे 2 सप्ताहाः · अग्रिम-2-सप्ताहयोः अनुमानम्';

  @override
  String get autoBadge => 'स्वचालितम्';

  @override
  String coverDays(String days) {
    return '$days दिनानां संग्रहः';
  }

  @override
  String unitsPerFortnight(String units, String unit) {
    return '$units $unit / 2 सप्ताहौ';
  }

  @override
  String get autoRestockTitle => 'मुख्यवस्तूनां स्वचालित-आदेशः';

  @override
  String get autoRestockSubtitle =>
      'न्यूनसंग्रहयुक्तानां मुख्यवस्तूनाम् आदेशः रात्रौ स्वयमेव गमिष्यति';

  @override
  String get distributorPhoneLabel => 'वितरकस्य WhatsApp सङ्ख्या';

  @override
  String get distributorPhoneHint => '+91 98765 43210';

  @override
  String get save => 'संरक्षतु';

  @override
  String get settingsSaved => 'संरक्षितम्';

  @override
  String get ordersTitle => 'आदेशाः';

  @override
  String get ordersEmpty =>
      'अधुना कोऽपि आदेशः नास्ति। पूर्वानुमानतः आदेशं रचयतु।';

  @override
  String get orderAuto => 'स्वचालितम्';

  @override
  String get orderManual => 'हस्तकृतम्';

  @override
  String get orderPlaced => 'प्रेषितम्';

  @override
  String get orderCancelled => 'निरस्तम्';

  @override
  String get viewOrders => 'आदेशान् पश्यतु';

  @override
  String get newOrdersNotice => 'रात्रेः स्वचालित-आदेशः आगतः';
}
