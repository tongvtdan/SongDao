// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get tabToday => 'Hôm nay';

  @override
  String get tabCalendar => 'Lịch';

  @override
  String get tabPray => 'Cầu nguyện';

  @override
  String get tabChurch => 'Nhà thờ';

  @override
  String get tabProgress => 'Tiến trình';

  @override
  String get settingsParishTitle => 'Giáo xứ của tôi';

  @override
  String get settingsParishUnset =>
      'Tuỳ chọn cho beta. Chỉ chọn thủ công khi giáo xứ có trong gói dữ liệu cục bộ.';

  @override
  String get settingsParishSelected =>
      'Giáo xứ của bạn được lưu trên thiết bị. Bạn có thể đổi bất cứ lúc nào.';

  @override
  String get settingsParishButton => 'Chọn giáo xứ';

  @override
  String get prayerTagDaily => 'Hằng ngày';

  @override
  String get prayerTagMorning => 'Buổi sáng';

  @override
  String get prayerTagEvening => 'Buổi tối';

  @override
  String get prayerTagReflection => 'Xét mình';

  @override
  String get prayerTagWork => 'Công việc';

  @override
  String get prayerTagPeace => 'Bình an';
}
