import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kirana Mitra'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your shop'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Takes 20 seconds. You will never fill a form again.'**
  String get onboardingSubtitle;

  /// No description provided for @shopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopNameLabel;

  /// No description provided for @shopNameHint.
  ///
  /// In en, this message translates to:
  /// **'Gupta General Store'**
  String get shopNameHint;

  /// No description provided for @ownerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get ownerNameLabel;

  /// No description provided for @ownerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ramesh Gupta'**
  String get ownerNameHint;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Reply language'**
  String get languageLabel;

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
  /// **'Start'**
  String get startButton;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Please fill this in'**
  String get requiredField;

  /// No description provided for @couldNotCreateShop.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Starting in demo mode.'**
  String get couldNotCreateShop;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
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

  /// No description provided for @holdToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get holdToTalk;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Listening… release to send'**
  String get recording;

  /// No description provided for @slideToCancel.
  ///
  /// In en, this message translates to:
  /// **'Slide away to cancel'**
  String get slideToCancel;

  /// No description provided for @recordingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
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
  /// **'Or type here…'**
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

  /// No description provided for @scanColItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get scanColItem;

  /// No description provided for @scanColPack.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get scanColPack;

  /// No description provided for @scanColCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get scanColCount;

  /// No description provided for @pickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Scan shelf photo'**
  String get pickPhoto;

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
  /// **'Reorder at {level}'**
  String reorderAt(String level);

  /// No description provided for @emptyStock.
  ///
  /// In en, this message translates to:
  /// **'No stock yet. Tell me what came in.'**
  String get emptyStock;

  /// No description provided for @lowStockCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All good} =1{1 item low} other{{count} items low}}'**
  String lowStockCount(int count);

  /// No description provided for @udhaarTitle.
  ///
  /// In en, this message translates to:
  /// **'Udhaar'**
  String get udhaarTitle;

  /// No description provided for @totalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Total outstanding'**
  String get totalOutstanding;

  /// No description provided for @customersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No customers} =1{1 customer} other{{count} customers}}'**
  String customersCount(int count);

  /// No description provided for @lastEntry.
  ///
  /// In en, this message translates to:
  /// **'Last entry {date}'**
  String lastEntry(String date);

  /// No description provided for @emptyLedger.
  ///
  /// In en, this message translates to:
  /// **'No udhaar yet. Say \"Gupta ji ko 350 ka udhaar diya\".'**
  String get emptyLedger;

  /// No description provided for @forecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecastTitle;

  /// No description provided for @legendHistory.
  ///
  /// In en, this message translates to:
  /// **'Past weeks'**
  String get legendHistory;

  /// No description provided for @legendForecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get legendForecast;

  /// No description provided for @legendBand.
  ///
  /// In en, this message translates to:
  /// **'Likely range'**
  String get legendBand;

  /// No description provided for @onHand.
  ///
  /// In en, this message translates to:
  /// **'On hand: {qty} {unit}'**
  String onHand(String qty, String unit);

  /// No description provided for @suggestedReorder.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {qty} {unit}'**
  String suggestedReorder(String qty, String unit);

  /// No description provided for @reorderButton.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderButton;

  /// No description provided for @reorderPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing order…'**
  String get reorderPreparing;

  /// No description provided for @orderReady.
  ///
  /// In en, this message translates to:
  /// **'Order ready'**
  String get orderReady;

  /// No description provided for @shareWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Send on WhatsApp'**
  String get shareWhatsapp;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
