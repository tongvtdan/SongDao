import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('vi'),
  ];

  /// No description provided for @tabToday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get tabToday;

  /// No description provided for @tabCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Lịch'**
  String get tabCalendar;

  /// No description provided for @tabPray.
  ///
  /// In vi, this message translates to:
  /// **'Cầu nguyện'**
  String get tabPray;

  /// No description provided for @tabChurch.
  ///
  /// In vi, this message translates to:
  /// **'Nhà thờ'**
  String get tabChurch;

  /// No description provided for @tabProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến trình'**
  String get tabProgress;

  /// No description provided for @prayerTagDaily.
  ///
  /// In vi, this message translates to:
  /// **'Hằng ngày'**
  String get prayerTagDaily;

  /// No description provided for @prayerTagMorning.
  ///
  /// In vi, this message translates to:
  /// **'Buổi sáng'**
  String get prayerTagMorning;

  /// No description provided for @prayerTagEvening.
  ///
  /// In vi, this message translates to:
  /// **'Buổi tối'**
  String get prayerTagEvening;

  /// No description provided for @prayerTagReflection.
  ///
  /// In vi, this message translates to:
  /// **'Xét mình'**
  String get prayerTagReflection;

  /// No description provided for @prayerTagWork.
  ///
  /// In vi, this message translates to:
  /// **'Công việc'**
  String get prayerTagWork;

  /// No description provided for @prayerTagPeace.
  ///
  /// In vi, this message translates to:
  /// **'Bình an'**
  String get prayerTagPeace;

  /// No description provided for @asyncErrorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải nội dung'**
  String get asyncErrorTitle;

  /// No description provided for @asyncErrorMessage.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu vẫn được lưu trên thiết bị. Hãy thử tải lại.'**
  String get asyncErrorMessage;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại'**
  String get retry;

  /// No description provided for @calendarEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lịch phụng vụ'**
  String get calendarEmptyTitle;

  /// No description provided for @calendarEmptyMessage.
  ///
  /// In vi, this message translates to:
  /// **'Gói nội dung trên thiết bị chưa có dữ liệu cho tháng này.'**
  String get calendarEmptyMessage;

  /// No description provided for @progressEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có việc hoàn thành'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptyMessage.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành một việc nhỏ hôm nay để bắt đầu nhịp sống đức tin.'**
  String get progressEmptyMessage;

  /// No description provided for @calendarTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch'**
  String get calendarTitle;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng trước'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng sau'**
  String get calendarNextMonth;

  /// No description provided for @calendarMonthYear.
  ///
  /// In vi, this message translates to:
  /// **'Tháng {month}, {year}'**
  String calendarMonthYear(int month, int year);

  /// No description provided for @calendarLocalDataSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu phụng vụ và sự kiện trên thiết bị'**
  String get calendarLocalDataSubtitle;

  /// No description provided for @calendarLiturgicalUnavailableTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thể cập nhật lịch phụng vụ'**
  String get calendarLiturgicalUnavailableTitle;

  /// No description provided for @calendarLiturgicalUnavailableMessage.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện cá nhân vẫn dùng được. Hãy thử tải lại dữ liệu phụng vụ.'**
  String get calendarLiturgicalUnavailableMessage;

  /// No description provided for @calendarNoLiturgicalDay.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu phụng vụ cho ngày này trong gói nội dung trên thiết bị.'**
  String get calendarNoLiturgicalDay;

  /// No description provided for @calendarEventsSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện của bạn'**
  String get calendarEventsSectionTitle;

  /// No description provided for @calendarNoEvents.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có sự kiện cho ngày này.'**
  String get calendarNoEvents;

  /// No description provided for @calendarAddEvent.
  ///
  /// In vi, this message translates to:
  /// **'Thêm sự kiện'**
  String get calendarAddEvent;

  /// No description provided for @calendarEditEvent.
  ///
  /// In vi, this message translates to:
  /// **'Sửa sự kiện'**
  String get calendarEditEvent;

  /// No description provided for @calendarDeleteEvent.
  ///
  /// In vi, this message translates to:
  /// **'Xóa sự kiện'**
  String get calendarDeleteEvent;

  /// No description provided for @calendarDeleteEventTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa sự kiện?'**
  String get calendarDeleteEventTitle;

  /// No description provided for @calendarDeleteEventMessage.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện và tất cả các lần lặp sẽ bị xóa khỏi thiết bị.'**
  String get calendarDeleteEventMessage;

  /// No description provided for @calendarEventSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu sự kiện.'**
  String get calendarEventSaved;

  /// No description provided for @calendarEventDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa sự kiện.'**
  String get calendarEventDeleted;

  /// No description provided for @calendarEventReminderPermissionDenied.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện đã được lưu nhưng nhắc nhở bị tắt. Bạn có thể bật quyền thông báo trong Cài đặt hệ thống.'**
  String get calendarEventReminderPermissionDenied;

  /// No description provided for @calendarEventReminderLimit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ có thể bật tối đa 50 lời nhắc sự kiện.'**
  String get calendarEventReminderLimit;

  /// No description provided for @calendarEventReminderPast.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian nhắc cho sự kiện một lần đã qua.'**
  String get calendarEventReminderPast;

  /// No description provided for @eventTypeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Loại sự kiện'**
  String get eventTypeLabel;

  /// No description provided for @eventTypeGeneral.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện'**
  String get eventTypeGeneral;

  /// No description provided for @eventTypeDeathAnniversary.
  ///
  /// In vi, this message translates to:
  /// **'Ngày giỗ'**
  String get eventTypeDeathAnniversary;

  /// No description provided for @eventTypeBaptismAnniversary.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm Rửa Tội'**
  String get eventTypeBaptismAnniversary;

  /// No description provided for @eventTypePatronalFeast.
  ///
  /// In vi, this message translates to:
  /// **'Lễ quan thầy'**
  String get eventTypePatronalFeast;

  /// No description provided for @eventTypeWeddingAnniversary.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm Hôn phối'**
  String get eventTypeWeddingAnniversary;

  /// No description provided for @eventTitleLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên sự kiện'**
  String get eventTitleLabel;

  /// No description provided for @eventTitleHint.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Ngày giỗ ông ngoại'**
  String get eventTitleHint;

  /// No description provided for @eventTitleRequired.
  ///
  /// In vi, this message translates to:
  /// **'Hãy nhập tên sự kiện.'**
  String get eventTitleRequired;

  /// No description provided for @eventNoteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get eventNoteLabel;

  /// No description provided for @eventNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin riêng bạn muốn ghi nhớ'**
  String get eventNoteHint;

  /// No description provided for @eventPrivateNote.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ lưu trên thiết bị của bạn.'**
  String get eventPrivateNote;

  /// No description provided for @eventCalendarSystemLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hệ lịch'**
  String get eventCalendarSystemLabel;

  /// No description provided for @eventCalendarSolar.
  ///
  /// In vi, this message translates to:
  /// **'Dương lịch'**
  String get eventCalendarSolar;

  /// No description provided for @eventCalendarLunar.
  ///
  /// In vi, this message translates to:
  /// **'Âm lịch'**
  String get eventCalendarLunar;

  /// No description provided for @eventDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sự kiện'**
  String get eventDateLabel;

  /// No description provided for @eventDayLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get eventDayLabel;

  /// No description provided for @eventMonthLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get eventMonthLabel;

  /// No description provided for @eventYearLabel.
  ///
  /// In vi, this message translates to:
  /// **'Năm'**
  String get eventYearLabel;

  /// No description provided for @eventLunarLeapMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng nhuận'**
  String get eventLunarLeapMonth;

  /// No description provided for @eventSolarEquivalent.
  ///
  /// In vi, this message translates to:
  /// **'Dương lịch: {date}'**
  String eventSolarEquivalent(String date);

  /// No description provided for @eventLunarEquivalent.
  ///
  /// In vi, this message translates to:
  /// **'Âm lịch: {date}'**
  String eventLunarEquivalent(String date);

  /// No description provided for @eventRecurrenceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Lặp lại'**
  String get eventRecurrenceLabel;

  /// No description provided for @eventRecurrenceOnce.
  ///
  /// In vi, this message translates to:
  /// **'Một lần'**
  String get eventRecurrenceOnce;

  /// No description provided for @eventRecurrenceDaily.
  ///
  /// In vi, this message translates to:
  /// **'Hằng ngày'**
  String get eventRecurrenceDaily;

  /// No description provided for @eventRecurrenceWeekly.
  ///
  /// In vi, this message translates to:
  /// **'Hằng tuần'**
  String get eventRecurrenceWeekly;

  /// No description provided for @eventRecurrenceMonthly.
  ///
  /// In vi, this message translates to:
  /// **'Hằng tháng'**
  String get eventRecurrenceMonthly;

  /// No description provided for @eventRecurrenceYearly.
  ///
  /// In vi, this message translates to:
  /// **'Hằng năm'**
  String get eventRecurrenceYearly;

  /// No description provided for @eventEditSeriesNote.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi áp dụng cho toàn bộ chuỗi lặp.'**
  String get eventEditSeriesNote;

  /// No description provided for @eventAllDay.
  ///
  /// In vi, this message translates to:
  /// **'Cả ngày'**
  String get eventAllDay;

  /// No description provided for @eventStartTime.
  ///
  /// In vi, this message translates to:
  /// **'Giờ bắt đầu'**
  String get eventStartTime;

  /// No description provided for @eventColorLabel.
  ///
  /// In vi, this message translates to:
  /// **'Màu sự kiện'**
  String get eventColorLabel;

  /// No description provided for @eventColorBurgundy.
  ///
  /// In vi, this message translates to:
  /// **'Đỏ rượu'**
  String get eventColorBurgundy;

  /// No description provided for @eventColorBlue.
  ///
  /// In vi, this message translates to:
  /// **'Xanh dương'**
  String get eventColorBlue;

  /// No description provided for @eventColorTeal.
  ///
  /// In vi, this message translates to:
  /// **'Xanh ngọc'**
  String get eventColorTeal;

  /// No description provided for @eventColorGreen.
  ///
  /// In vi, this message translates to:
  /// **'Xanh lá'**
  String get eventColorGreen;

  /// No description provided for @eventColorGold.
  ///
  /// In vi, this message translates to:
  /// **'Vàng'**
  String get eventColorGold;

  /// No description provided for @eventColorOrange.
  ///
  /// In vi, this message translates to:
  /// **'Cam'**
  String get eventColorOrange;

  /// No description provided for @eventColorPurple.
  ///
  /// In vi, this message translates to:
  /// **'Tím'**
  String get eventColorPurple;

  /// No description provided for @eventColorGray.
  ///
  /// In vi, this message translates to:
  /// **'Xám'**
  String get eventColorGray;

  /// No description provided for @eventReminderLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc sự kiện'**
  String get eventReminderLabel;

  /// No description provided for @eventReminderEnable.
  ///
  /// In vi, this message translates to:
  /// **'Bật nhắc nhở'**
  String get eventReminderEnable;

  /// No description provided for @eventReminderAtTime.
  ///
  /// In vi, this message translates to:
  /// **'Đúng giờ sự kiện'**
  String get eventReminderAtTime;

  /// No description provided for @eventReminderMinutesBefore.
  ///
  /// In vi, this message translates to:
  /// **'Trước {minutes} phút'**
  String eventReminderMinutesBefore(int minutes);

  /// No description provided for @eventReminderHoursBefore.
  ///
  /// In vi, this message translates to:
  /// **'Trước {hours} giờ'**
  String eventReminderHoursBefore(int hours);

  /// No description provided for @eventReminderDaysBefore.
  ///
  /// In vi, this message translates to:
  /// **'Trước {days} ngày'**
  String eventReminderDaysBefore(int days);

  /// No description provided for @eventReminderWeekBefore.
  ///
  /// In vi, this message translates to:
  /// **'Trước một tuần'**
  String get eventReminderWeekBefore;

  /// No description provided for @eventReminderSameDay.
  ///
  /// In vi, this message translates to:
  /// **'Cùng ngày'**
  String get eventReminderSameDay;

  /// No description provided for @eventReminderDayBefore.
  ///
  /// In vi, this message translates to:
  /// **'Trước một ngày'**
  String get eventReminderDayBefore;

  /// No description provided for @eventReminderTime.
  ///
  /// In vi, this message translates to:
  /// **'Giờ nhắc'**
  String get eventReminderTime;

  /// No description provided for @eventReminderTodayTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện hôm nay'**
  String get eventReminderTodayTitle;

  /// No description provided for @eventReminderUpcomingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện ngày mai'**
  String get eventReminderUpcomingTitle;

  /// No description provided for @eventReminderScheduledTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện sắp tới'**
  String get eventReminderScheduledTitle;

  /// No description provided for @eventReminderChannelName.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện cá nhân'**
  String get eventReminderChannelName;

  /// No description provided for @eventReminderChannelDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc các ngày kỷ niệm bạn đã lưu trong Sống Đạo.'**
  String get eventReminderChannelDescription;

  /// No description provided for @eventInvalidDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đã chọn không hợp lệ.'**
  String get eventInvalidDate;

  /// No description provided for @commonCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get commonDelete;

  /// No description provided for @calendarPracticeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Việc sống đạo'**
  String get calendarPracticeTitle;

  /// No description provided for @calendarReadingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bài đọc'**
  String get calendarReadingsTitle;

  /// No description provided for @calendarSeasonAdvent.
  ///
  /// In vi, this message translates to:
  /// **'Mùa Vọng'**
  String get calendarSeasonAdvent;

  /// No description provided for @calendarSeasonChristmas.
  ///
  /// In vi, this message translates to:
  /// **'Mùa Giáng Sinh'**
  String get calendarSeasonChristmas;

  /// No description provided for @calendarSeasonLent.
  ///
  /// In vi, this message translates to:
  /// **'Mùa Chay'**
  String get calendarSeasonLent;

  /// No description provided for @calendarSeasonEaster.
  ///
  /// In vi, this message translates to:
  /// **'Mùa Phục Sinh'**
  String get calendarSeasonEaster;

  /// No description provided for @calendarSeasonOrdinary.
  ///
  /// In vi, this message translates to:
  /// **'Thường niên'**
  String get calendarSeasonOrdinary;

  /// No description provided for @calendarSeasonLocal.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu địa phương'**
  String get calendarSeasonLocal;

  /// No description provided for @calendarColorGreen.
  ///
  /// In vi, this message translates to:
  /// **'Xanh'**
  String get calendarColorGreen;

  /// No description provided for @calendarColorWhite.
  ///
  /// In vi, this message translates to:
  /// **'Trắng'**
  String get calendarColorWhite;

  /// No description provided for @calendarColorGold.
  ///
  /// In vi, this message translates to:
  /// **'Vàng'**
  String get calendarColorGold;

  /// No description provided for @calendarColorRed.
  ///
  /// In vi, this message translates to:
  /// **'Đỏ'**
  String get calendarColorRed;

  /// No description provided for @calendarColorPurple.
  ///
  /// In vi, this message translates to:
  /// **'Tím'**
  String get calendarColorPurple;

  /// No description provided for @calendarColorRose.
  ///
  /// In vi, this message translates to:
  /// **'Hồng'**
  String get calendarColorRose;

  /// No description provided for @calendarColorBlack.
  ///
  /// In vi, this message translates to:
  /// **'Đen'**
  String get calendarColorBlack;

  /// No description provided for @calendarColorLiturgical.
  ///
  /// In vi, this message translates to:
  /// **'Phụng vụ'**
  String get calendarColorLiturgical;

  /// No description provided for @calendarReadingFirst.
  ///
  /// In vi, this message translates to:
  /// **'Bài đọc I'**
  String get calendarReadingFirst;

  /// No description provided for @calendarReadingSecond.
  ///
  /// In vi, this message translates to:
  /// **'Bài đọc II'**
  String get calendarReadingSecond;

  /// No description provided for @calendarReadingPsalm.
  ///
  /// In vi, this message translates to:
  /// **'Đáp ca'**
  String get calendarReadingPsalm;

  /// No description provided for @calendarReadingAlleluia.
  ///
  /// In vi, this message translates to:
  /// **'Alleluia'**
  String get calendarReadingAlleluia;

  /// No description provided for @calendarReadingGospel.
  ///
  /// In vi, this message translates to:
  /// **'Tin Mừng'**
  String get calendarReadingGospel;

  /// No description provided for @calendarReadingDefault.
  ///
  /// In vi, this message translates to:
  /// **'Bài đọc'**
  String get calendarReadingDefault;

  /// No description provided for @weekdayShortSunday.
  ///
  /// In vi, this message translates to:
  /// **'CN'**
  String get weekdayShortSunday;

  /// No description provided for @weekdayShortMonday.
  ///
  /// In vi, this message translates to:
  /// **'T2'**
  String get weekdayShortMonday;

  /// No description provided for @weekdayShortTuesday.
  ///
  /// In vi, this message translates to:
  /// **'T3'**
  String get weekdayShortTuesday;

  /// No description provided for @weekdayShortWednesday.
  ///
  /// In vi, this message translates to:
  /// **'T4'**
  String get weekdayShortWednesday;

  /// No description provided for @weekdayShortThursday.
  ///
  /// In vi, this message translates to:
  /// **'T5'**
  String get weekdayShortThursday;

  /// No description provided for @weekdayShortFriday.
  ///
  /// In vi, this message translates to:
  /// **'T6'**
  String get weekdayShortFriday;

  /// No description provided for @weekdayShortSaturday.
  ///
  /// In vi, this message translates to:
  /// **'T7'**
  String get weekdayShortSaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In vi, this message translates to:
  /// **'Chúa nhật'**
  String get weekdaySunday;

  /// No description provided for @weekdayMonday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Hai'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Ba'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Tư'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Năm'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Sáu'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Bảy'**
  String get weekdaySaturday;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
