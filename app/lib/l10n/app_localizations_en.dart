// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pitch Coach';

  @override
  String get navHome => 'Home';

  @override
  String get navPractice => 'Practice';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get dailyChallenge => 'Today\'s challenge';

  @override
  String get start => 'Start';

  @override
  String get anotherProduct => 'Another product';

  @override
  String get avgScore => 'Avg score';

  @override
  String get bestScore => 'Best';

  @override
  String get thisWeek => 'This week';

  @override
  String get pitchPractice => 'Pitch practice';

  @override
  String get handleObjections => 'Handle objections';

  @override
  String get recentAttempts => 'Recent attempts';

  @override
  String get seeAll => 'See all';

  @override
  String get noPracticeYet => 'No practice yet.';

  @override
  String get searchProducts => 'Search products';

  @override
  String get all => 'All';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get tryOtherSearch => 'Try another search.';

  @override
  String get newTag => 'New';

  @override
  String get pitchMode => 'Give a pitch';

  @override
  String get shopkeeperThinking =>
      'The shopkeeper is thinking of a question...';

  @override
  String get shopkeeperSays => 'Shopkeeper says:';

  @override
  String get questionNotLoaded => 'Question not loaded.';

  @override
  String get anotherQuestion => 'Another question';

  @override
  String get holdToTalk => 'Hold to talk';

  @override
  String get listeningRelease => 'Listening...';

  @override
  String get listeningHint => 'Listening...';

  @override
  String get answerHint => 'Your answer will appear here (you can edit it)';

  @override
  String get pitchHint => 'Your pitch will appear here (you can edit it)';

  @override
  String get getScore => 'Get score';

  @override
  String get scoring => 'Scoring...';

  @override
  String get holdMicSnack => 'Hold the mic while you speak.';

  @override
  String questionLoadFailed(String error) {
    return 'Could not load a question: $error';
  }

  @override
  String get micUnavailable =>
      'Voice input is not available on this device. Please type instead.';

  @override
  String micProblem(String error) {
    return 'Microphone problem: $error';
  }

  @override
  String get speakOrTypeFirst => 'Speak or type your pitch first.';

  @override
  String get waitForQuestion =>
      'Wait for the shopkeeper\'s question to load first.';

  @override
  String scoreFailed(String error) {
    return 'Could not score: $error';
  }

  @override
  String get objectionSuffix => '(objection)';

  @override
  String get yourScore => 'Your score';

  @override
  String get outOfTen => '/ 10';

  @override
  String get praiseHigh => 'Great job!';

  @override
  String get praiseMid => 'Good try!';

  @override
  String get praiseLow => 'Keep practising';

  @override
  String get critKeyPoints => 'Key points';

  @override
  String get critReason => 'Reasons / ingredients';

  @override
  String get critStructure => 'Structure';

  @override
  String get critTone => 'Tone & clarity';

  @override
  String get critNoFalseClaims => 'No false claims';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get coveredTitle => 'What you got right';

  @override
  String get missedTitle => 'What you missed';

  @override
  String get falseClaimsTitle => 'Wrong / forbidden claims';

  @override
  String get betterLineTitle => 'A better way to say it';

  @override
  String get viewIdealPitch => 'View ideal pitch';

  @override
  String get viewIdealAnswer => 'View ideal answer';

  @override
  String get tryAgain => 'Try again';

  @override
  String scoredBy(String provider) {
    return 'Scored by $provider';
  }

  @override
  String get myScores => 'My scores';

  @override
  String get nothingYetTitle => 'Nothing here yet';

  @override
  String get nothingYetMessage => 'Your scores will show up here.';

  @override
  String get totalAttempts => 'Total attempts';

  @override
  String attemptsCount(int count) {
    return '$count';
  }

  @override
  String scoreOutOfTen(String score) {
    return '$score/10';
  }

  @override
  String get profile => 'Profile';

  @override
  String get edit => 'Edit';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldEmployeeId => 'Employee ID';

  @override
  String get fieldTerritory => 'Area / territory';

  @override
  String get fieldMobileLong => 'Mobile number';

  @override
  String get fieldMobile => 'Mobile';

  @override
  String get save => 'Save';

  @override
  String get yourName => 'Your name';

  @override
  String get salesOfficer => 'Sales officer';

  @override
  String get completeProfile => 'Complete your profile';

  @override
  String get attempts => 'Attempts';

  @override
  String get notProvided => 'Not provided';

  @override
  String get admin => 'Admin';

  @override
  String get adminTitle => 'Admin';

  @override
  String get enterPin => 'Enter admin PIN';

  @override
  String get setPin => 'Set a new admin PIN';

  @override
  String get ok => 'OK';

  @override
  String get pinTooShort => 'Enter a PIN of at least 4 digits';

  @override
  String get pinWrong => 'Wrong PIN';

  @override
  String get adminProviderTitle => 'Admin - AI provider';

  @override
  String get activeProvider => 'Active provider';

  @override
  String get fallbackSwitch => 'Fall back to another provider on failure';

  @override
  String get enterKeyFirst => 'Enter the API key first';

  @override
  String get testing => 'Testing...';

  @override
  String get connectionOk => 'Connection OK ✓ (key saved)';

  @override
  String failedMsg(String msg) {
    return 'Failed: $msg';
  }

  @override
  String get saveNoKey => 'Not saved: no API key found';

  @override
  String savedWithKeys(String list) {
    return 'Saved (keys set: $list)';
  }

  @override
  String saveError(String error) {
    return 'Save failed: $error';
  }

  @override
  String get catFabric => 'Fabric care';

  @override
  String get catSummer => 'Summer care';

  @override
  String get catHome => 'Home care';

  @override
  String get catHair => 'Hair care';

  @override
  String get catSkin => 'Skin care';

  @override
  String get catOral => 'Oral care';

  @override
  String get catFeminine => 'Feminine care';

  @override
  String get catMen => 'Men\'s care';

  @override
  String get catBaby => 'Baby care';

  @override
  String get catHealth => 'Health';

  @override
  String get catHealthProtection => 'Health protection';

  @override
  String get tipStart => 'Start with today\'s challenge!';

  @override
  String get tipAgain => 'Ready to beat your best score?';

  @override
  String get tipPitch => 'Hold the mic and pitch to me!';

  @override
  String get tipListening => 'I\'m listening...';

  @override
  String get tipScoring => 'Checking your pitch...';

  @override
  String get listenFeedback => 'Listen to feedback';

  @override
  String get stopSpeaking => 'Stop';

  @override
  String get voiceUnavailable =>
      'This phone has no voice for the language. Install it in Google Text-to-speech settings.';

  @override
  String get hints => 'Hints';

  @override
  String get close => 'Close';
}
