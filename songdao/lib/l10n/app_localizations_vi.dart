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

  @override
  String get calendarTitle => 'Lịch';

  @override
  String get calendarPreviousMonth => 'Tháng trước';

  @override
  String get calendarNextMonth => 'Tháng sau';

  @override
  String calendarMonthYear(int month, int year) {
    return 'Tháng $month, $year';
  }

  @override
  String get calendarLocalDataSubtitle =>
      'Dữ liệu phụng vụ và sự kiện trên thiết bị';

  @override
  String get calendarLiturgicalUnavailableTitle =>
      'Chưa thể cập nhật lịch phụng vụ';

  @override
  String get calendarLiturgicalUnavailableMessage =>
      'Sự kiện cá nhân vẫn dùng được. Hãy thử tải lại dữ liệu phụng vụ.';

  @override
  String get calendarNoLiturgicalDay =>
      'Chưa có dữ liệu phụng vụ cho ngày này trong gói nội dung trên thiết bị.';

  @override
  String get calendarEventsSectionTitle => 'Sự kiện của bạn';

  @override
  String get calendarNoEvents => 'Chưa có sự kiện cho ngày này.';

  @override
  String get calendarAddEvent => 'Thêm sự kiện';

  @override
  String get calendarEditEvent => 'Sửa sự kiện';

  @override
  String get calendarDeleteEvent => 'Xóa sự kiện';

  @override
  String get calendarDeleteEventTitle => 'Xóa sự kiện?';

  @override
  String get calendarDeleteEventMessage =>
      'Sự kiện và tất cả các lần lặp sẽ bị xóa khỏi thiết bị.';

  @override
  String get calendarEventSaved => 'Đã lưu sự kiện.';

  @override
  String get calendarEventDeleted => 'Đã xóa sự kiện.';

  @override
  String get calendarEventReminderPermissionDenied =>
      'Sự kiện đã được lưu nhưng nhắc nhở bị tắt. Bạn có thể bật quyền thông báo trong Cài đặt hệ thống.';

  @override
  String get calendarEventReminderLimit =>
      'Chỉ có thể bật tối đa 50 lời nhắc sự kiện.';

  @override
  String get calendarEventReminderPast =>
      'Thời gian nhắc cho sự kiện một lần đã qua.';

  @override
  String get eventTypeLabel => 'Loại sự kiện';

  @override
  String get eventTypeGeneral => 'Sự kiện';

  @override
  String get eventTypeDeathAnniversary => 'Ngày giỗ';

  @override
  String get eventTypeBaptismAnniversary => 'Kỷ niệm Rửa Tội';

  @override
  String get eventTypePatronalFeast => 'Lễ quan thầy';

  @override
  String get eventTypeWeddingAnniversary => 'Kỷ niệm Hôn phối';

  @override
  String get eventTitleLabel => 'Tên sự kiện';

  @override
  String get eventTitleHint => 'Ví dụ: Ngày giỗ ông ngoại';

  @override
  String get eventTitleRequired => 'Hãy nhập tên sự kiện.';

  @override
  String get eventNoteLabel => 'Ghi chú';

  @override
  String get eventNoteHint => 'Thông tin riêng bạn muốn ghi nhớ';

  @override
  String get eventPrivateNote => 'Chỉ lưu trên thiết bị của bạn.';

  @override
  String get eventCalendarSystemLabel => 'Hệ lịch';

  @override
  String get eventCalendarSolar => 'Dương lịch';

  @override
  String get eventCalendarLunar => 'Âm lịch';

  @override
  String get eventDateLabel => 'Ngày sự kiện';

  @override
  String get eventDayLabel => 'Ngày';

  @override
  String get eventMonthLabel => 'Tháng';

  @override
  String get eventYearLabel => 'Năm';

  @override
  String get eventLunarLeapMonth => 'Tháng nhuận';

  @override
  String eventSolarEquivalent(String date) {
    return 'Dương lịch: $date';
  }

  @override
  String eventLunarEquivalent(String date) {
    return 'Âm lịch: $date';
  }

  @override
  String get eventRecurrenceLabel => 'Lặp lại';

  @override
  String get eventRecurrenceOnce => 'Một lần';

  @override
  String get eventRecurrenceDaily => 'Hằng ngày';

  @override
  String get eventRecurrenceWeekly => 'Hằng tuần';

  @override
  String get eventRecurrenceMonthly => 'Hằng tháng';

  @override
  String get eventRecurrenceYearly => 'Hằng năm';

  @override
  String get eventEditSeriesNote => 'Thay đổi áp dụng cho toàn bộ chuỗi lặp.';

  @override
  String get eventAllDay => 'Cả ngày';

  @override
  String get eventStartTime => 'Giờ bắt đầu';

  @override
  String get eventColorLabel => 'Màu sự kiện';

  @override
  String get eventColorBurgundy => 'Đỏ rượu';

  @override
  String get eventColorBlue => 'Xanh dương';

  @override
  String get eventColorTeal => 'Xanh ngọc';

  @override
  String get eventColorGreen => 'Xanh lá';

  @override
  String get eventColorGold => 'Vàng';

  @override
  String get eventColorOrange => 'Cam';

  @override
  String get eventColorPurple => 'Tím';

  @override
  String get eventColorGray => 'Xám';

  @override
  String get eventReminderLabel => 'Nhắc sự kiện';

  @override
  String get eventReminderEnable => 'Bật nhắc nhở';

  @override
  String get eventReminderAtTime => 'Đúng giờ sự kiện';

  @override
  String eventReminderMinutesBefore(int minutes) {
    return 'Trước $minutes phút';
  }

  @override
  String eventReminderHoursBefore(int hours) {
    return 'Trước $hours giờ';
  }

  @override
  String eventReminderDaysBefore(int days) {
    return 'Trước $days ngày';
  }

  @override
  String get eventReminderWeekBefore => 'Trước một tuần';

  @override
  String get eventReminderSameDay => 'Cùng ngày';

  @override
  String get eventReminderDayBefore => 'Trước một ngày';

  @override
  String get eventReminderTime => 'Giờ nhắc';

  @override
  String get eventReminderTodayTitle => 'Sự kiện hôm nay';

  @override
  String get eventReminderUpcomingTitle => 'Sự kiện ngày mai';

  @override
  String get eventReminderScheduledTitle => 'Sự kiện sắp tới';

  @override
  String get eventReminderChannelName => 'Sự kiện cá nhân';

  @override
  String get eventReminderChannelDescription =>
      'Nhắc các ngày kỷ niệm bạn đã lưu trong Sống Đạo.';

  @override
  String get eventInvalidDate => 'Ngày đã chọn không hợp lệ.';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get calendarPracticeTitle => 'Việc sống đạo';

  @override
  String get calendarReadingsTitle => 'Bài đọc';

  @override
  String get calendarSeasonAdvent => 'Mùa Vọng';

  @override
  String get calendarSeasonChristmas => 'Mùa Giáng Sinh';

  @override
  String get calendarSeasonLent => 'Mùa Chay';

  @override
  String get calendarSeasonEaster => 'Mùa Phục Sinh';

  @override
  String get calendarSeasonOrdinary => 'Thường niên';

  @override
  String get calendarSeasonLocal => 'Dữ liệu địa phương';

  @override
  String get calendarColorGreen => 'Xanh';

  @override
  String get calendarColorWhite => 'Trắng';

  @override
  String get calendarColorGold => 'Vàng';

  @override
  String get calendarColorRed => 'Đỏ';

  @override
  String get calendarColorPurple => 'Tím';

  @override
  String get calendarColorRose => 'Hồng';

  @override
  String get calendarColorBlack => 'Đen';

  @override
  String get calendarColorLiturgical => 'Phụng vụ';

  @override
  String get calendarReadingFirst => 'Bài đọc I';

  @override
  String get calendarReadingSecond => 'Bài đọc II';

  @override
  String get calendarReadingPsalm => 'Đáp ca';

  @override
  String get calendarReadingAlleluia => 'Alleluia';

  @override
  String get calendarReadingGospel => 'Tin Mừng';

  @override
  String get calendarReadingDefault => 'Bài đọc';

  @override
  String get weekdayShortSunday => 'CN';

  @override
  String get weekdayShortMonday => 'T2';

  @override
  String get weekdayShortTuesday => 'T3';

  @override
  String get weekdayShortWednesday => 'T4';

  @override
  String get weekdayShortThursday => 'T5';

  @override
  String get weekdayShortFriday => 'T6';

  @override
  String get weekdayShortSaturday => 'T7';

  @override
  String get weekdaySunday => 'Chúa nhật';

  @override
  String get weekdayMonday => 'Thứ Hai';

  @override
  String get weekdayTuesday => 'Thứ Ba';

  @override
  String get weekdayWednesday => 'Thứ Tư';

  @override
  String get weekdayThursday => 'Thứ Năm';

  @override
  String get weekdayFriday => 'Thứ Sáu';

  @override
  String get weekdaySaturday => 'Thứ Bảy';
}
