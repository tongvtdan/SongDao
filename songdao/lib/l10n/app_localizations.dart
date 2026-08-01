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
