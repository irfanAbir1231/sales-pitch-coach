// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'পিচ কোচ';

  @override
  String get navHome => 'হোম';

  @override
  String get navPractice => 'প্র্যাকটিস';

  @override
  String get navHistory => 'ইতিহাস';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get changeLanguage => 'ভাষা পরিবর্তন';

  @override
  String get dailyChallenge => 'আজকের চ্যালেঞ্জ';

  @override
  String get start => 'শুরু করুন';

  @override
  String get anotherProduct => 'অন্য পণ্য';

  @override
  String get avgScore => 'গড় স্কোর';

  @override
  String get bestScore => 'সর্বোচ্চ';

  @override
  String get thisWeek => 'এই সপ্তাহে';

  @override
  String get pitchPractice => 'পিচ প্র্যাকটিস';

  @override
  String get handleObjections => 'আপত্তি সামলান';

  @override
  String get recentAttempts => 'সাম্প্রতিক চেষ্টা';

  @override
  String get seeAll => 'সব দেখুন';

  @override
  String get noPracticeYet => 'এখনো কোনো প্র্যাকটিস নেই।';

  @override
  String get searchProducts => 'পণ্য খুঁজুন';

  @override
  String get all => 'সব';

  @override
  String get nothingFound => 'কিছু পাওয়া যায়নি';

  @override
  String get tryOtherSearch => 'অন্যভাবে খুঁজুন।';

  @override
  String get newTag => 'নতুন';

  @override
  String get pitchMode => 'পিচ করুন';

  @override
  String get shopkeeperThinking => 'দোকানদার প্রশ্ন ভাবছে...';

  @override
  String get shopkeeperSays => 'দোকানদার বলছে:';

  @override
  String get questionNotLoaded => 'প্রশ্ন লোড হয়নি।';

  @override
  String get anotherQuestion => 'অন্য প্রশ্ন';

  @override
  String get holdToTalk => 'চেপে ধরে বলুন';

  @override
  String get listeningRelease => 'শুনছি...';

  @override
  String get listeningHint => 'শুনছি...';

  @override
  String get answerHint => 'আপনার উত্তর এখানে আসবে (এডিট করা যাবে)';

  @override
  String get pitchHint => 'আপনার পিচ এখানে আসবে (এডিট করা যাবে)';

  @override
  String get getScore => 'স্কোর দেখুন';

  @override
  String get scoring => 'স্কোর হচ্ছে...';

  @override
  String get holdMicSnack => 'কথা বলার সময় মাইক চেপে ধরে রাখুন।';

  @override
  String questionLoadFailed(String error) {
    return 'প্রশ্ন আনা যায়নি: $error';
  }

  @override
  String get micUnavailable =>
      'এই ডিভাইসে voice input চালু করা যায়নি। টাইপ করে লিখুন।';

  @override
  String micProblem(String error) {
    return 'মাইক্রোফোন সমস্যা: $error';
  }

  @override
  String get speakOrTypeFirst => 'আগে পিচটি বলুন বা লিখুন।';

  @override
  String get waitForQuestion => 'আগে দোকানদারের প্রশ্ন লোড হতে দিন।';

  @override
  String scoreFailed(String error) {
    return 'স্কোর করা যায়নি: $error';
  }

  @override
  String get objectionSuffix => '(আপত্তি)';

  @override
  String get yourScore => 'আপনার স্কোর';

  @override
  String get outOfTen => '/ ১০';

  @override
  String get praiseHigh => 'দারুণ হয়েছে!';

  @override
  String get praiseMid => 'ভালো চেষ্টা!';

  @override
  String get praiseLow => 'আরও একটু অনুশীলন করুন';

  @override
  String get critKeyPoints => 'মূল পয়েন্ট';

  @override
  String get critReason => 'কারণ/উপাদান';

  @override
  String get critStructure => 'গঠন';

  @override
  String get critTone => 'ভাষা ও স্পষ্টতা';

  @override
  String get critNoFalseClaims => 'ভুল দাবি নেই';

  @override
  String get feedbackTitle => 'মতামত';

  @override
  String get coveredTitle => 'যা ঠিকভাবে বলেছেন';

  @override
  String get missedTitle => 'যা বাদ পড়েছে';

  @override
  String get falseClaimsTitle => 'ভুল/নিষিদ্ধ দাবি';

  @override
  String get betterLineTitle => 'এভাবে বললে আরও ভালো হতো';

  @override
  String get viewIdealPitch => 'আদর্শ পিচ দেখুন';

  @override
  String get viewIdealAnswer => 'আদর্শ উত্তর দেখুন';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String scoredBy(String provider) {
    return 'Scored by $provider';
  }

  @override
  String get myScores => 'আমার স্কোর';

  @override
  String get nothingYetTitle => 'এখনো কিছু নেই';

  @override
  String get nothingYetMessage => 'আপনার স্কোর এখানে দেখা যাবে।';

  @override
  String get totalAttempts => 'মোট চেষ্টা';

  @override
  String attemptsCount(int count) {
    return '$count টি';
  }

  @override
  String scoreOutOfTen(String score) {
    return '$score/১০';
  }

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get edit => 'এডিট';

  @override
  String get editProfile => 'প্রোফাইল এডিট';

  @override
  String get fieldName => 'নাম';

  @override
  String get fieldEmployeeId => 'এমপ্লয়ি আইডি';

  @override
  String get fieldTerritory => 'এলাকা / টেরিটরি';

  @override
  String get fieldMobileLong => 'মোবাইল নম্বর';

  @override
  String get fieldMobile => 'মোবাইল';

  @override
  String get save => 'সেভ করুন';

  @override
  String get yourName => 'আপনার নাম';

  @override
  String get salesOfficer => 'সেলস অফিসার';

  @override
  String get completeProfile => 'প্রোফাইল সম্পূর্ণ করুন';

  @override
  String get attempts => 'চেষ্টা';

  @override
  String get notProvided => 'দেওয়া হয়নি';

  @override
  String get admin => 'অ্যাডমিন';

  @override
  String get adminTitle => 'Admin';

  @override
  String get enterPin => 'Admin PIN দিন';

  @override
  String get setPin => 'নতুন Admin PIN সেট করুন';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get pinTooShort => 'কমপক্ষে ৪ সংখ্যার PIN দিন';

  @override
  String get pinWrong => 'PIN ভুল';

  @override
  String get adminProviderTitle => 'Admin - AI Provider';

  @override
  String get activeProvider => 'সক্রিয় provider';

  @override
  String get fallbackSwitch => 'ব্যর্থ হলে অন্য provider এ fallback';

  @override
  String get enterKeyFirst => 'আগে API key দিন';

  @override
  String get testing => 'পরীক্ষা চলছে...';

  @override
  String get connectionOk => 'সংযোগ ঠিক আছে ✓ (key সেভ হয়েছে)';

  @override
  String failedMsg(String msg) {
    return 'ব্যর্থ: $msg';
  }

  @override
  String get saveNoKey => 'সেভ হয়নি: কোনো API key পাওয়া যায়নি';

  @override
  String savedWithKeys(String list) {
    return 'সেভ হয়েছে (key আছে: $list)';
  }

  @override
  String saveError(String error) {
    return 'সেভ ব্যর্থ: $error';
  }

  @override
  String get catFabric => 'কাপড়ের যত্ন';

  @override
  String get catSummer => 'গরমের যত্ন';

  @override
  String get catHome => 'ঘরের যত্ন';

  @override
  String get catHair => 'চুলের যত্ন';

  @override
  String get catSkin => 'ত্বকের যত্ন';

  @override
  String get catOral => 'দাঁতের যত্ন';

  @override
  String get catFeminine => 'নারীর যত্ন';

  @override
  String get catMen => 'পুরুষের যত্ন';

  @override
  String get catBaby => 'বাবুর যত্ন';

  @override
  String get catHealth => 'স্বাস্থ্য';

  @override
  String get catHealthProtection => 'স্বাস্থ্য সুরক্ষা';

  @override
  String get tipStart => 'আজকের চ্যালেঞ্জ দিয়ে শুরু করুন!';

  @override
  String get tipAgain => 'সেরা স্কোর ছাড়িয়ে যেতে প্রস্তুত?';

  @override
  String get tipPitch => 'মাইক চেপে ধরে আমাকে পিচ করুন!';

  @override
  String get tipListening => 'আমি শুনছি...';

  @override
  String get tipScoring => 'আপনার পিচ দেখছি...';

  @override
  String get listenFeedback => 'মতামত শুনুন';

  @override
  String get stopSpeaking => 'থামুন';

  @override
  String get voiceUnavailable =>
      'ফোনে এই ভাষার ভয়েস নেই। Google Text-to-speech সেটিংসে ইনস্টল করুন।';

  @override
  String get hints => 'ইঙ্গিত';

  @override
  String get close => 'বন্ধ করুন';
}
