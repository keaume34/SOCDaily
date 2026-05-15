// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'SOCDaily';

  @override
  String get navHome => 'Trang chính';

  @override
  String get navBrowse => 'Duyệt';

  @override
  String get navStudy => 'Học';

  @override
  String get navStats => 'Thống kê';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get homeGreeting => 'Chào mừng quay lại';

  @override
  String homeStreak(String count) {
    return 'Chuỗi $count ngày';
  }

  @override
  String homeDueToday(String count) {
    return '$count thẻ cần ôn hôm nay';
  }

  @override
  String get homeStartSession => 'Bắt đầu phiên học';

  @override
  String get homeStartSessionSubtitle => 'Những thẻ được lên lịch cho hôm nay.';

  @override
  String get homeDailyChallenge => 'Thử thách hằng ngày';

  @override
  String get homeDailyChallengeSubtitle =>
      'Một bộ mới mỗi ngày, ai cũng nhận cùng đề.';

  @override
  String get homeBrowse => 'Xem tất cả tài liệu';

  @override
  String get homeBrowseSubtitle => 'Chọn bất kỳ Subject, Chapter hoặc Topic.';

  @override
  String get placeholderComingSoon => 'Sẽ có trong các phase tiếp theo.';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsAccent => 'Màu nhấn';

  @override
  String get settingsAccentSubtitle =>
      'Kết hợp với nền trắng/đen để giữ cảm giác chuyên nghiệp.';

  @override
  String get settingsLanguageSystem => 'Theo hệ thống';

  @override
  String get settingsAboutTagline =>
      'Xây dựng kho học SOC từ PDF của riêng anh, sau đó học như Anki nhưng đầy đủ hơn.';

  @override
  String settingsAboutVersion(String version) {
    return 'Phiên bản $version';
  }
}
