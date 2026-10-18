import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_brx.dart';
import 'app_localizations_doi.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_kok.dart';
import 'app_localizations_ks.dart';
import 'app_localizations_mai.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mni.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_sa.dart';
import 'app_localizations_sat.dart';
import 'app_localizations_sd.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('brx'),
    Locale('doi'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale.fromSubtags(languageCode: 'hi', scriptCode: 'Latn'),
    Locale('kn'),
    Locale('kok'),
    Locale('ks'),
    Locale('mai'),
    Locale('ml'),
    Locale('mni'),
    Locale('mr'),
    Locale('ne'),
    Locale('or'),
    Locale('pa'),
    Locale('sa'),
    Locale('sat'),
    Locale('sd'),
    Locale('ta'),
    Locale('te'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kirana Mitra'**
  String get appTitle;

  /// No description provided for @shopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Dukaan ka naam'**
  String get shopNameLabel;

  /// No description provided for @shopNameHint.
  ///
  /// In en, this message translates to:
  /// **'Gupta General Store'**
  String get shopNameHint;

  /// No description provided for @ownerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Aapka naam'**
  String get ownerNameLabel;

  /// No description provided for @ownerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ramesh Gupta'**
  String get ownerNameHint;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get langHindi;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langHinglish.
  ///
  /// In en, this message translates to:
  /// **'Hinglish'**
  String get langHinglish;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Shuru karo'**
  String get startButton;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Please fill this in'**
  String get requiredField;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Baat'**
  String get navChat;

  /// No description provided for @navStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get navStock;

  /// No description provided for @navUdhaar.
  ///
  /// In en, this message translates to:
  /// **'Udhaar'**
  String get navUdhaar;

  /// No description provided for @navForecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get navForecast;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Kirana Mitra'**
  String get chatTitle;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demoMode;

  /// No description provided for @changeShop.
  ///
  /// In en, this message translates to:
  /// **'Change shop'**
  String get changeShop;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Namaste {name}! Tell me what came in, what sold, or who took udhaar. Hold the mic and speak.'**
  String welcomeMessage(String name);

  /// No description provided for @welcomeMessageHinglish.
  ///
  /// In en, this message translates to:
  /// **'Namaste {name}! Bolo: kya aaya, kya bika, kisko udhaar diya. Mic dabake rakho aur bolo.'**
  String welcomeMessageHinglish(String name);

  /// No description provided for @recordingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Chhod do, cancel ho gaya'**
  String get recordingCancelled;

  /// No description provided for @voiceTooShort.
  ///
  /// In en, this message translates to:
  /// **'Hold a bit longer and speak'**
  String get voiceTooShort;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is needed for voice notes.'**
  String get micPermissionDenied;

  /// No description provided for @voiceNoteSent.
  ///
  /// In en, this message translates to:
  /// **'🎤 Voice note'**
  String get voiceNoteSent;

  /// No description provided for @photoSent.
  ///
  /// In en, this message translates to:
  /// **'📷 Shelf photo'**
  String get photoSent;

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Yahan likho…'**
  String get typeMessageHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinking;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Try again.'**
  String get networkError;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Jaldi aa raha hai! Shelf scan is coming soon.'**
  String get comingSoon;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Photo samajh nahi aayi, phir se try karo.'**
  String get scanFailed;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Photo is too big (over 8 MB). Try a smaller one.'**
  String get imageTooLarge;

  /// No description provided for @stockTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockTitle;

  /// No description provided for @lowStockBadge.
  ///
  /// In en, this message translates to:
  /// **'Kam hai'**
  String get lowStockBadge;

  /// No description provided for @reorderAt.
  ///
  /// In en, this message translates to:
  /// **'reorder at {level}'**
  String reorderAt(String level);

  /// No description provided for @emptyStock.
  ///
  /// In en, this message translates to:
  /// **'Abhi stock nahi hai. Bolo kya aaya.'**
  String get emptyStock;

  /// No description provided for @udhaarTitle.
  ///
  /// In en, this message translates to:
  /// **'Udhaar'**
  String get udhaarTitle;

  /// No description provided for @totalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Kul baaki'**
  String get totalOutstanding;

  /// No description provided for @emptyLedger.
  ///
  /// In en, this message translates to:
  /// **'Abhi koi udhaar nahi. Bolo \"Gupta ji ko 350 ka udhaar diya\".'**
  String get emptyLedger;

  /// No description provided for @forecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecastTitle;

  /// No description provided for @legendHistory.
  ///
  /// In en, this message translates to:
  /// **'Pichhle hafte'**
  String get legendHistory;

  /// No description provided for @legendForecast.
  ///
  /// In en, this message translates to:
  /// **'Anumaan'**
  String get legendForecast;

  /// No description provided for @legendBand.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get legendBand;

  /// No description provided for @orderReady.
  ///
  /// In en, this message translates to:
  /// **'Order taiyaar'**
  String get orderReady;

  /// No description provided for @shareWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp pe bhejo'**
  String get shareWhatsapp;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copy ho gaya'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load. Pull down to retry.'**
  String get errorLoading;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Bolo, ho jayega.'**
  String get tagline;

  /// No description provided for @languageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Mitra kis bhasha mein bole?'**
  String get languageQuestion;

  /// No description provided for @langSampleHindi.
  ///
  /// In en, this message translates to:
  /// **'नमस्ते! आज क्या आया?'**
  String get langSampleHindi;

  /// No description provided for @langSampleHinglish.
  ///
  /// In en, this message translates to:
  /// **'Namaste! Aaj kya aaya?'**
  String get langSampleHinglish;

  /// No description provided for @langSampleEnglish.
  ///
  /// In en, this message translates to:
  /// **'Hello! What came in today?'**
  String get langSampleEnglish;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Yeh bharo'**
  String get fieldRequired;

  /// No description provided for @dockPhoto.
  ///
  /// In en, this message translates to:
  /// **'Shelf photo'**
  String get dockPhoto;

  /// No description provided for @dockType.
  ///
  /// In en, this message translates to:
  /// **'Likho'**
  String get dockType;

  /// No description provided for @micLabel.
  ///
  /// In en, this message translates to:
  /// **'Dabake bolo'**
  String get micLabel;

  /// No description provided for @recordingLabel.
  ///
  /// In en, this message translates to:
  /// **'Sun raha hoon… chhodo toh bhejega'**
  String get recordingLabel;

  /// No description provided for @recordingCancelHint.
  ///
  /// In en, this message translates to:
  /// **'Cancel ke liye ungli bahar le jao'**
  String get recordingCancelHint;

  /// No description provided for @confirmHeader.
  ///
  /// In en, this message translates to:
  /// **'Samjha · likh diya'**
  String get confirmHeader;

  /// No description provided for @confirmTotalUdhaar.
  ///
  /// In en, this message translates to:
  /// **'Udhaar · ab total'**
  String get confirmTotalUdhaar;

  /// No description provided for @confirmTotalStock.
  ///
  /// In en, this message translates to:
  /// **'Stock · ab total'**
  String get confirmTotalStock;

  /// No description provided for @confirmTotalSale.
  ///
  /// In en, this message translates to:
  /// **'Bikri · aaj total'**
  String get confirmTotalSale;

  /// No description provided for @askHeader.
  ///
  /// In en, this message translates to:
  /// **'Pakka nahi'**
  String get askHeader;

  /// No description provided for @askHeard.
  ///
  /// In en, this message translates to:
  /// **'aapne kaha “{text}”'**
  String askHeard(String text);

  /// No description provided for @askStock.
  ///
  /// In en, this message translates to:
  /// **'Stock mein add karoon?'**
  String get askStock;

  /// No description provided for @askUdhaar.
  ///
  /// In en, this message translates to:
  /// **'Udhaar mein likhoon?'**
  String get askUdhaar;

  /// No description provided for @askSale.
  ///
  /// In en, this message translates to:
  /// **'Bikri mein likhoon?'**
  String get askSale;

  /// No description provided for @askNo.
  ///
  /// In en, this message translates to:
  /// **'Nahi'**
  String get askNo;

  /// No description provided for @askDeclined.
  ///
  /// In en, this message translates to:
  /// **'Theek hai, nahi likha.'**
  String get askDeclined;

  /// No description provided for @scanHeader.
  ///
  /// In en, this message translates to:
  /// **'Shelf dekha · {count} cheezein mili'**
  String scanHeader(int count);

  /// No description provided for @scanQuestion.
  ///
  /// In en, this message translates to:
  /// **'Stock yahi set kar doon?'**
  String get scanQuestion;

  /// No description provided for @scanConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Samjha · stock update ho gaya'**
  String get scanConfirmed;

  /// No description provided for @stockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} cheezein · update {time}'**
  String stockSubtitle(int count, String time);

  /// No description provided for @lowBandTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 cheez kam hai} other{{count} cheezein kam hain}}'**
  String lowBandTitle(int count);

  /// No description provided for @allGoodBand.
  ///
  /// In en, this message translates to:
  /// **'Sab theek hai'**
  String get allGoodBand;

  /// No description provided for @orderButton.
  ///
  /// In en, this message translates to:
  /// **'Order banao'**
  String get orderButton;

  /// No description provided for @orderButtonQty.
  ///
  /// In en, this message translates to:
  /// **'Order banao · {qty} {unit}'**
  String orderButtonQty(String qty, String unit);

  /// No description provided for @udhaarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} log · bahi-khata'**
  String udhaarSubtitle(int count);

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Baaki'**
  String get balanceLabel;

  /// No description provided for @todayGiven.
  ///
  /// In en, this message translates to:
  /// **'Aaj diya +₹{amount}'**
  String todayGiven(String amount);

  /// No description provided for @todayReceived.
  ///
  /// In en, this message translates to:
  /// **'Aaj aaya −₹{amount}'**
  String todayReceived(String amount);

  /// No description provided for @owedCaption.
  ///
  /// In en, this message translates to:
  /// **'baaki'**
  String get owedCaption;

  /// No description provided for @settledBadge.
  ///
  /// In en, this message translates to:
  /// **'Chukta'**
  String get settledBadge;

  /// No description provided for @lastMovementGiven.
  ///
  /// In en, this message translates to:
  /// **'{date} · +₹{amount}'**
  String lastMovementGiven(String date, String amount);

  /// No description provided for @lastMovementPaid.
  ///
  /// In en, this message translates to:
  /// **'{date} · −₹{amount} aaya'**
  String lastMovementPaid(String date, String amount);

  /// No description provided for @customerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Udhaar shuru {date} · {count} entries'**
  String customerSubtitle(String date, int count);

  /// No description provided for @lastEntryAt.
  ///
  /// In en, this message translates to:
  /// **'Last: {time}'**
  String lastEntryAt(String time);

  /// No description provided for @remindButton.
  ///
  /// In en, this message translates to:
  /// **'Yaad dilao'**
  String get remindButton;

  /// No description provided for @paidButton.
  ///
  /// In en, this message translates to:
  /// **'Paisa aaya'**
  String get paidButton;

  /// No description provided for @paidPrompt.
  ///
  /// In en, this message translates to:
  /// **'Kitna aaya? Bolo.'**
  String get paidPrompt;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @entryGiven.
  ///
  /// In en, this message translates to:
  /// **'Udhaar liya'**
  String get entryGiven;

  /// No description provided for @entryPaid.
  ///
  /// In en, this message translates to:
  /// **'Paisa aaya'**
  String get entryPaid;

  /// No description provided for @entrySourceVoice.
  ///
  /// In en, this message translates to:
  /// **'voice'**
  String get entrySourceVoice;

  /// No description provided for @entrySourceCash.
  ///
  /// In en, this message translates to:
  /// **'cash'**
  String get entrySourceCash;

  /// No description provided for @entrySourcePhoto.
  ///
  /// In en, this message translates to:
  /// **'photo'**
  String get entrySourcePhoto;

  /// No description provided for @reminderText.
  ///
  /// In en, this message translates to:
  /// **'Namaste {name} ji, {shop} se. Aapka ₹{balance} baaki hai. Dhanyavaad!'**
  String reminderText(String name, String shop, String balance);

  /// No description provided for @forecastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Agle 4 hafte · {festival} {date}'**
  String forecastSubtitle(String festival, String date);

  /// No description provided for @forecastSubtitlePlain.
  ///
  /// In en, this message translates to:
  /// **'Agle 4 hafte'**
  String get forecastSubtitlePlain;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'{unit} / hafta'**
  String perWeek(String unit);

  /// No description provided for @forecastFuture.
  ///
  /// In en, this message translates to:
  /// **'AAGE · forecast'**
  String get forecastFuture;

  /// No description provided for @onHandReorder.
  ///
  /// In en, this message translates to:
  /// **'Stock mein {onHand} · mangao {qty} {unit}'**
  String onHandReorder(String onHand, String qty, String unit);

  /// No description provided for @orderItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cheezein'**
  String orderItemCount(int count);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @hisaabTitle.
  ///
  /// In en, this message translates to:
  /// **'Aaj ka hisaab'**
  String get hisaabTitle;

  /// No description provided for @hisaabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{date} · {count} entries'**
  String hisaabSubtitle(String date, int count);

  /// No description provided for @hisaabDayChip.
  ///
  /// In en, this message translates to:
  /// **'Dukaan band · {time}'**
  String hisaabDayChip(String time);

  /// No description provided for @hisaabSales.
  ///
  /// In en, this message translates to:
  /// **'Aaj ki bikri'**
  String get hisaabSales;

  /// No description provided for @hisaabGiven.
  ///
  /// In en, this message translates to:
  /// **'Udhaar diya'**
  String get hisaabGiven;

  /// No description provided for @hisaabReceived.
  ///
  /// In en, this message translates to:
  /// **'Udhaar aaya'**
  String get hisaabReceived;

  /// No description provided for @hisaabOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Kul baaki'**
  String get hisaabOutstanding;

  /// No description provided for @hisaabLow.
  ///
  /// In en, this message translates to:
  /// **'Kam hai'**
  String get hisaabLow;

  /// No description provided for @hisaabLowItems.
  ///
  /// In en, this message translates to:
  /// **'{items} kal mangao.'**
  String hisaabLowItems(String items);

  /// No description provided for @hisaabFestival.
  ///
  /// In en, this message translates to:
  /// **'{festival} {weeks} hafte door hai.'**
  String hisaabFestival(String festival, String weeks);

  /// No description provided for @hisaabOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Kal ka order banao'**
  String get hisaabOrderButton;

  /// No description provided for @hisaabShareButton.
  ///
  /// In en, this message translates to:
  /// **'Ghar pe WhatsApp karo'**
  String get hisaabShareButton;

  /// No description provided for @todayChip.
  ///
  /// In en, this message translates to:
  /// **'Aaj · {date}'**
  String todayChip(String date);

  /// No description provided for @yesterdayChip.
  ///
  /// In en, this message translates to:
  /// **'Kal · {date}'**
  String yesterdayChip(String date);

  /// No description provided for @demoNotice.
  ///
  /// In en, this message translates to:
  /// **'Server nahi mila. Demo mode mein shuru kar raha hoon.'**
  String get demoNotice;

  /// No description provided for @languageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Mitra kis bhasha mein bole?'**
  String get languageSheetTitle;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Peeche'**
  String get backLabel;

  /// No description provided for @voiceNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNoteLabel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @feedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackButton;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Kirana Mitra kaisa chal raha hai?'**
  String get feedbackTitle;

  /// No description provided for @feedbackUp.
  ///
  /// In en, this message translates to:
  /// **'Achha'**
  String get feedbackUp;

  /// No description provided for @feedbackDown.
  ///
  /// In en, this message translates to:
  /// **'Theek nahi'**
  String get feedbackDown;

  /// No description provided for @feedbackCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Kuch aur batana ho toh likho…'**
  String get feedbackCommentHint;

  /// No description provided for @feedbackVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Ya dabake bolo'**
  String get feedbackVoiceHint;

  /// No description provided for @feedbackVoiceReady.
  ///
  /// In en, this message translates to:
  /// **'Aawaz taiyaar · {seconds}s'**
  String feedbackVoiceReady(String seconds);

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Bhejo'**
  String get feedbackSend;

  /// No description provided for @feedbackPickRating.
  ///
  /// In en, this message translates to:
  /// **'Pehle achha ya theek nahi chuno'**
  String get feedbackPickRating;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Shukriya!'**
  String get feedbackThanks;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Bhasha badlo'**
  String get changeLanguage;

  /// No description provided for @languageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Bhasha dhoondo…'**
  String get languageSearchHint;

  /// No description provided for @languageNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Koi bhasha nahi mili'**
  String get languageNoMatch;

  /// No description provided for @topSellersTitle.
  ///
  /// In en, this message translates to:
  /// **'Top sellers'**
  String get topSellersTitle;

  /// No description provided for @topSellersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pichhle 2 hafte · agle 2 hafte ka anumaan'**
  String get topSellersSubtitle;

  /// No description provided for @autoBadge.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoBadge;

  /// No description provided for @coverDays.
  ///
  /// In en, this message translates to:
  /// **'{days} din'**
  String coverDays(String days);

  /// No description provided for @unitsPerFortnight.
  ///
  /// In en, this message translates to:
  /// **'{units} {unit}'**
  String unitsPerFortnight(String units, String unit);

  /// No description provided for @autoRestockTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-restock top sellers'**
  String get autoRestockTitle;

  /// No description provided for @autoRestockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kam stock wale top sellers ka order raat ko apne aap jayega'**
  String get autoRestockSubtitle;

  /// No description provided for @distributorPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Distributor ka WhatsApp number'**
  String get distributorPhoneLabel;

  /// No description provided for @distributorPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43210'**
  String get distributorPhoneHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save karo'**
  String get save;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Save ho gaya'**
  String get settingsSaved;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'Abhi koi order nahi. Forecast se Order banao.'**
  String get ordersEmpty;

  /// No description provided for @orderAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get orderAuto;

  /// No description provided for @orderManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get orderManual;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Bheja'**
  String get orderPlaced;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancel ho gaya'**
  String get orderCancelled;

  /// No description provided for @viewOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders dekho'**
  String get viewOrders;

  /// No description provided for @newOrdersNotice.
  ///
  /// In en, this message translates to:
  /// **'Raat ka auto order aaya'**
  String get newOrdersNotice;

  /// No description provided for @shopReRegistered.
  ///
  /// In en, this message translates to:
  /// **'Server restart hua, dukaan phir se register ki.'**
  String get shopReRegistered;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'as',
    'bn',
    'brx',
    'doi',
    'en',
    'gu',
    'hi',
    'kn',
    'kok',
    'ks',
    'mai',
    'ml',
    'mni',
    'mr',
    'ne',
    'or',
    'pa',
    'sa',
    'sat',
    'sd',
    'ta',
    'te',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'hi':
      {
        switch (locale.scriptCode) {
          case 'Latn':
            return AppLocalizationsHiLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'brx':
      return AppLocalizationsBrx();
    case 'doi':
      return AppLocalizationsDoi();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'kok':
      return AppLocalizationsKok();
    case 'ks':
      return AppLocalizationsKs();
    case 'mai':
      return AppLocalizationsMai();
    case 'ml':
      return AppLocalizationsMl();
    case 'mni':
      return AppLocalizationsMni();
    case 'mr':
      return AppLocalizationsMr();
    case 'ne':
      return AppLocalizationsNe();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'sa':
      return AppLocalizationsSa();
    case 'sat':
      return AppLocalizationsSat();
    case 'sd':
      return AppLocalizationsSd();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
