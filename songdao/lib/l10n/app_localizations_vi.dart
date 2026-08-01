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

  @override
  String get asyncErrorTitle => 'Không thể tải nội dung';

  @override
  String get asyncErrorMessage =>
      'Dữ liệu vẫn được lưu trên thiết bị. Hãy thử tải lại.';

  @override
  String get retry => 'Tải lại';

  @override
  String get calendarEmptyTitle => 'Chưa có lịch phụng vụ';

  @override
  String get calendarEmptyMessage =>
      'Gói nội dung trên thiết bị chưa có dữ liệu cho tháng này.';

  @override
  String get progressEmptyTitle => 'Chưa có việc hoàn thành';

  @override
  String get progressEmptyMessage =>
      'Hoàn thành một việc nhỏ hôm nay để bắt đầu nhịp sống đức tin.';
}
