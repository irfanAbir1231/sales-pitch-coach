import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pitch Coach'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Today\'s challenge'**
  String get dailyChallenge;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @anotherProduct.
  ///
  /// In en, this message translates to:
  /// **'Another product'**
  String get anotherProduct;

  /// No description provided for @avgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg score'**
  String get avgScore;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestScore;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @pitchPractice.
  ///
  /// In en, this message translates to:
  /// **'Pitch practice'**
  String get pitchPractice;

  /// No description provided for @handleObjections.
  ///
  /// In en, this message translates to:
  /// **'Handle objections'**
  String get handleObjections;

  /// No description provided for @recentAttempts.
  ///
  /// In en, this message translates to:
  /// **'Recent attempts'**
  String get recentAttempts;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noPracticeYet.
  ///
  /// In en, this message translates to:
  /// **'No practice yet.'**
  String get noPracticeYet;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @tryOtherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try another search.'**
  String get tryOtherSearch;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newTag;

  /// No description provided for @pitchMode.
  ///
  /// In en, this message translates to:
  /// **'Give a pitch'**
  String get pitchMode;

  /// No description provided for @shopkeeperThinking.
  ///
  /// In en, this message translates to:
  /// **'The shopkeeper is thinking of a question...'**
  String get shopkeeperThinking;

  /// No description provided for @shopkeeperSays.
  ///
  /// In en, this message translates to:
  /// **'Shopkeeper says:'**
  String get shopkeeperSays;

  /// No description provided for @questionNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Question not loaded.'**
  String get questionNotLoaded;

  /// No description provided for @anotherQuestion.
  ///
  /// In en, this message translates to:
  /// **'Another question'**
  String get anotherQuestion;

  /// No description provided for @holdToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get holdToTalk;

  /// No description provided for @listeningRelease.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listeningRelease;

  /// No description provided for @listeningHint.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listeningHint;

  /// No description provided for @answerHint.
  ///
  /// In en, this message translates to:
  /// **'Your answer will appear here (you can edit it)'**
  String get answerHint;

  /// No description provided for @pitchHint.
  ///
  /// In en, this message translates to:
  /// **'Your pitch will appear here (you can edit it)'**
  String get pitchHint;

  /// No description provided for @getScore.
  ///
  /// In en, this message translates to:
  /// **'Get score'**
  String get getScore;

  /// No description provided for @scoring.
  ///
  /// In en, this message translates to:
  /// **'Scoring...'**
  String get scoring;

  /// No description provided for @holdMicSnack.
  ///
  /// In en, this message translates to:
  /// **'Hold the mic while you speak.'**
  String get holdMicSnack;

  /// No description provided for @questionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load a question: {error}'**
  String questionLoadFailed(String error);

  /// No description provided for @micUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input is not available on this device. Please type instead.'**
  String get micUnavailable;

  /// No description provided for @micProblem.
  ///
  /// In en, this message translates to:
  /// **'Microphone problem: {error}'**
  String micProblem(String error);

  /// No description provided for @speakOrTypeFirst.
  ///
  /// In en, this message translates to:
  /// **'Speak or type your pitch first.'**
  String get speakOrTypeFirst;

  /// No description provided for @waitForQuestion.
  ///
  /// In en, this message translates to:
  /// **'Wait for the shopkeeper\'s question to load first.'**
  String get waitForQuestion;

  /// No description provided for @scoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not score: {error}'**
  String scoreFailed(String error);

  /// No description provided for @objectionSuffix.
  ///
  /// In en, this message translates to:
  /// **'(objection)'**
  String get objectionSuffix;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your score'**
  String get yourScore;

  /// No description provided for @outOfTen.
  ///
  /// In en, this message translates to:
  /// **'/ 10'**
  String get outOfTen;

  /// No description provided for @praiseHigh.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get praiseHigh;

  /// No description provided for @praiseMid.
  ///
  /// In en, this message translates to:
  /// **'Good try!'**
  String get praiseMid;

  /// No description provided for @praiseLow.
  ///
  /// In en, this message translates to:
  /// **'Keep practising'**
  String get praiseLow;

  /// No description provided for @critKeyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key points'**
  String get critKeyPoints;

  /// No description provided for @critReason.
  ///
  /// In en, this message translates to:
  /// **'Reasons / ingredients'**
  String get critReason;

  /// No description provided for @critStructure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get critStructure;

  /// No description provided for @critTone.
  ///
  /// In en, this message translates to:
  /// **'Tone & clarity'**
  String get critTone;

  /// No description provided for @critNoFalseClaims.
  ///
  /// In en, this message translates to:
  /// **'No false claims'**
  String get critNoFalseClaims;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @coveredTitle.
  ///
  /// In en, this message translates to:
  /// **'What you got right'**
  String get coveredTitle;

  /// No description provided for @missedTitle.
  ///
  /// In en, this message translates to:
  /// **'What you missed'**
  String get missedTitle;

  /// No description provided for @falseClaimsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wrong / forbidden claims'**
  String get falseClaimsTitle;

  /// No description provided for @betterLineTitle.
  ///
  /// In en, this message translates to:
  /// **'A better way to say it'**
  String get betterLineTitle;

  /// No description provided for @viewIdealPitch.
  ///
  /// In en, this message translates to:
  /// **'View ideal pitch'**
  String get viewIdealPitch;

  /// No description provided for @viewIdealAnswer.
  ///
  /// In en, this message translates to:
  /// **'View ideal answer'**
  String get viewIdealAnswer;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @scoredBy.
  ///
  /// In en, this message translates to:
  /// **'Scored by {provider}'**
  String scoredBy(String provider);

  /// No description provided for @myScores.
  ///
  /// In en, this message translates to:
  /// **'My scores'**
  String get myScores;

  /// No description provided for @nothingYetTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingYetTitle;

  /// No description provided for @nothingYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Your scores will show up here.'**
  String get nothingYetMessage;

  /// No description provided for @totalAttempts.
  ///
  /// In en, this message translates to:
  /// **'Total attempts'**
  String get totalAttempts;

  /// No description provided for @attemptsCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String attemptsCount(int count);

  /// No description provided for @scoreOutOfTen.
  ///
  /// In en, this message translates to:
  /// **'{score}/10'**
  String scoreOutOfTen(String score);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldEmployeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get fieldEmployeeId;

  /// No description provided for @fieldTerritory.
  ///
  /// In en, this message translates to:
  /// **'Area / territory'**
  String get fieldTerritory;

  /// No description provided for @fieldMobileLong.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get fieldMobileLong;

  /// No description provided for @fieldMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get fieldMobile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @salesOfficer.
  ///
  /// In en, this message translates to:
  /// **'Sales officer'**
  String get salesOfficer;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfile;

  /// No description provided for @attempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attempts;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminTitle;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter admin PIN'**
  String get enterPin;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set a new admin PIN'**
  String get setPin;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @pinTooShort.
  ///
  /// In en, this message translates to:
  /// **'Enter a PIN of at least 4 digits'**
  String get pinTooShort;

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get pinWrong;

  /// No description provided for @adminProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin - AI provider'**
  String get adminProviderTitle;

  /// No description provided for @activeProvider.
  ///
  /// In en, this message translates to:
  /// **'Active provider'**
  String get activeProvider;

  /// No description provided for @fallbackSwitch.
  ///
  /// In en, this message translates to:
  /// **'Fall back to another provider on failure'**
  String get fallbackSwitch;

  /// No description provided for @enterKeyFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter the API key first'**
  String get enterKeyFirst;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testing;

  /// No description provided for @connectionOk.
  ///
  /// In en, this message translates to:
  /// **'Connection OK ✓ (key saved)'**
  String get connectionOk;

  /// No description provided for @failedMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed: {msg}'**
  String failedMsg(String msg);

  /// No description provided for @saveNoKey.
  ///
  /// In en, this message translates to:
  /// **'Not saved: no API key found'**
  String get saveNoKey;

  /// No description provided for @savedWithKeys.
  ///
  /// In en, this message translates to:
  /// **'Saved (keys set: {list})'**
  String savedWithKeys(String list);

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveError(String error);

  /// No description provided for @catFabric.
  ///
  /// In en, this message translates to:
  /// **'Fabric care'**
  String get catFabric;

  /// No description provided for @catSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer care'**
  String get catSummer;

  /// No description provided for @catHome.
  ///
  /// In en, this message translates to:
  /// **'Home care'**
  String get catHome;

  /// No description provided for @catHair.
  ///
  /// In en, this message translates to:
  /// **'Hair care'**
  String get catHair;

  /// No description provided for @catSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin care'**
  String get catSkin;

  /// No description provided for @catOral.
  ///
  /// In en, this message translates to:
  /// **'Oral care'**
  String get catOral;

  /// No description provided for @catFeminine.
  ///
  /// In en, this message translates to:
  /// **'Feminine care'**
  String get catFeminine;

  /// No description provided for @catMen.
  ///
  /// In en, this message translates to:
  /// **'Men\'s care'**
  String get catMen;

  /// No description provided for @catBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby care'**
  String get catBaby;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catHealthProtection.
  ///
  /// In en, this message translates to:
  /// **'Health protection'**
  String get catHealthProtection;

  /// No description provided for @tipStart.
  ///
  /// In en, this message translates to:
  /// **'Start with today\'s challenge!'**
  String get tipStart;

  /// No description provided for @tipAgain.
  ///
  /// In en, this message translates to:
  /// **'Ready to beat your best score?'**
  String get tipAgain;

  /// No description provided for @tipPitch.
  ///
  /// In en, this message translates to:
  /// **'Hold the mic and pitch to me!'**
  String get tipPitch;

  /// No description provided for @tipListening.
  ///
  /// In en, this message translates to:
  /// **'I\'m listening...'**
  String get tipListening;

  /// No description provided for @tipScoring.
  ///
  /// In en, this message translates to:
  /// **'Checking your pitch...'**
  String get tipScoring;

  /// No description provided for @listenFeedback.
  ///
  /// In en, this message translates to:
  /// **'Listen to feedback'**
  String get listenFeedback;

  /// No description provided for @stopSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopSpeaking;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This phone has no voice for the language. Install it in Google Text-to-speech settings.'**
  String get voiceUnavailable;

  /// No description provided for @hints.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hints;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
