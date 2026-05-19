// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SOCDaily';

  @override
  String get navHome => 'Home';

  @override
  String get navBrowse => 'Browse';

  @override
  String get navStudy => 'Study';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeGreeting => 'Welcome back';

  @override
  String homeStreak(String count) {
    return '$count-day streak';
  }

  @override
  String homeDueToday(String count) {
    return '$count due today';
  }

  @override
  String get homeStartSession => 'Start a study session';

  @override
  String get homeStartSessionSubtitle => 'Cards scheduled for today.';

  @override
  String get homeDailyChallenge => 'Daily challenge';

  @override
  String get homeDailyChallengeSubtitle =>
      'A fresh set every day, same for everyone.';

  @override
  String get homeBrowse => 'Browse all material';

  @override
  String get homeBrowseSubtitle => 'Pick any subject, chapter, or topic.';

  @override
  String get placeholderComingSoon => 'Coming in a later phase.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'Follow system';

  @override
  String get settingsAccent => 'Accent';

  @override
  String get settingsAccentSubtitle =>
      'Pairs with monochrome surfaces for a clean, professional look.';

  @override
  String get settingsLanguageSystem => 'Follow system';

  @override
  String get settingsAboutTagline =>
      'Build a SOC-analyst learning database from your own source PDFs, then study it like an Anki deck on steroids.';

  @override
  String settingsAboutVersion(String version) {
    return 'Version $version';
  }
}
