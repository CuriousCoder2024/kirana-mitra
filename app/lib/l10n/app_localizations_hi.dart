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
  String get onboardingTitle => 'अपनी दुकान सेट करें';

  @override
  String get onboardingSubtitle => 'बस 20 सेकंड। फिर कभी फॉर्म नहीं भरना।';

  @override
  String get shopNameLabel => 'दुकान का नाम';

  @override
  String get shopNameHint => 'गुप्ता जनरल स्टोर';

  @override
  String get ownerNameLabel => 'आपका नाम';

  @override
  String get ownerNameHint => 'रमेश गुप्ता';

  @override
  String get languageLabel => 'जवाब की भाषा';

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
  String get couldNotCreateShop =>
      'सर्वर से संपर्क नहीं हुआ। डेमो मोड में शुरू कर रहे हैं।';

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
  String get holdToTalk => 'दबाकर बोलें';

  @override
  String get recording => 'सुन रहा हूँ… छोड़ें तो भेजेगा';

  @override
  String get slideToCancel => 'रद्द करने के लिए उंगली खिसकाएँ';

  @override
  String get recordingCancelled => 'रद्द';

  @override
  String get voiceTooShort => 'थोड़ा और देर दबाकर बोलें';

  @override
  String get micPermissionDenied => 'वॉइस नोट के लिए माइक की अनुमति चाहिए।';

  @override
  String get voiceNoteSent => '🎤 वॉइस नोट';

  @override
  String get photoSent => '📷 शेल्फ की फोटो';

  @override
  String get typeMessageHint => 'या यहाँ लिखें…';

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
  String get scanColItem => 'सामान';

  @override
  String get scanColPack => 'पैक';

  @override
  String get scanColCount => 'गिनती';

  @override
  String get pickPhoto => 'शेल्फ की फोटो स्कैन करें';

  @override
  String get stockTitle => 'स्टॉक';

  @override
  String get lowStockBadge => 'कम है';

  @override
  String reorderAt(String level) {
    return '$level पर दोबारा मंगाएँ';
  }

  @override
  String get emptyStock => 'अभी स्टॉक नहीं है। बताइए क्या आया।';

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चीज़ें कम',
      one: '1 चीज़ कम',
      zero: 'सब ठीक है',
    );
    return '$_temp0';
  }

  @override
  String get udhaarTitle => 'उधार';

  @override
  String get totalOutstanding => 'कुल बकाया';

  @override
  String customersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ग्राहक',
      one: '1 ग्राहक',
      zero: 'कोई ग्राहक नहीं',
    );
    return '$_temp0';
  }

  @override
  String lastEntry(String date) {
    return 'आखिरी एंट्री $date';
  }

  @override
  String get emptyLedger =>
      'अभी कोई उधार नहीं। बोलिए \"गुप्ता जी को 350 का उधार दिया\"।';

  @override
  String get forecastTitle => 'अनुमान';

  @override
  String get legendHistory => 'पिछले हफ्ते';

  @override
  String get legendForecast => 'अनुमान';

  @override
  String get legendBand => 'संभावित दायरा';

  @override
  String onHand(String qty, String unit) {
    return 'स्टॉक में: $qty $unit';
  }

  @override
  String suggestedReorder(String qty, String unit) {
    return 'सुझाव: $qty $unit';
  }

  @override
  String get reorderButton => 'ऑर्डर बनाएँ';

  @override
  String get reorderPreparing => 'ऑर्डर बन रहा है…';

  @override
  String get orderReady => 'ऑर्डर तैयार';

  @override
  String get shareWhatsapp => 'WhatsApp पर भेजें';

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
}
