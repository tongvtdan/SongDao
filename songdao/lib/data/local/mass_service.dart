import 'app_database.dart';
import 'user_settings_repository.dart';

class ImportantMass {
  const ImportantMass({
    required this.church,
    required this.massTime,
    required this.label,
  });

  final Church church;
  final MassTime massTime;
  final String label;
}

class MassService {
  MassService(this.db);

  final AppDatabase db;

  Future<ImportantMass?> nextImportantMassForDate(String date) async {
    final selectedChurchId = await UserSettingsRepository(
      db,
    ).selectedChurchId();
    if (selectedChurchId == null || selectedChurchId.isEmpty) {
      return null;
    }
    final church = await (db.select(
      db.churches,
    )..where((t) => t.id.equals(selectedChurchId))).getSingleOrNull();
    if (church == null) {
      return null;
    }

    final parsedDate = DateTime.parse(date);
    final weekday = _weekdayForDate(parsedDate);
    final calendarDay = await (db.select(
      db.calendarDays,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
    final celebrations = await (db.select(
      db.celebrations,
    )..where((t) => t.date.equals(date))).get();
    final isSunday = weekday == 'sunday';
    final isHolyDay = celebrations.any(
      (item) =>
          item.rank == 'solemnity' ||
          item.rank == 'holy_day' ||
          item.rank == 'holy_day_of_obligation',
    );

    final candidates = await (db.select(
      db.massTimes,
    )..where((t) => t.churchId.equals(church.id))).get();
    final valid = candidates
        .where((mass) => _isValidOn(mass, parsedDate))
        .where((mass) {
          if (isSunday) {
            return mass.context == 'sunday' ||
                mass.context == 'saturday_vigil' ||
                mass.weekday == 'sunday';
          }
          if (isHolyDay) {
            return mass.context == 'solemnity' ||
                mass.context == 'holy_day' ||
                mass.isImportantDefault;
          }
          return mass.isImportantDefault || mass.weekday == weekday;
        })
        .toList();
    if (valid.isEmpty) {
      return null;
    }
    valid.sort((a, b) {
      final importance =
          _importanceScore(
            b,
            isSunday: isSunday,
            isHolyDay: isHolyDay,
          ).compareTo(
            _importanceScore(a, isSunday: isSunday, isHolyDay: isHolyDay),
          );
      if (importance != 0) {
        return importance;
      }
      return a.time.compareTo(b.time);
    });

    final label = isSunday
        ? 'Thánh lễ Chúa nhật'
        : isHolyDay
        ? 'Thánh lễ trọng'
        : _seasonLabel(calendarDay?.season);
    return ImportantMass(church: church, massTime: valid.first, label: label);
  }

  bool _isValidOn(MassTime mass, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final from = DateTime(
      mass.validFrom.year,
      mass.validFrom.month,
      mass.validFrom.day,
    );
    final to = mass.validTo == null
        ? null
        : DateTime(mass.validTo!.year, mass.validTo!.month, mass.validTo!.day);
    return !day.isBefore(from) && (to == null || !day.isAfter(to));
  }

  int _importanceScore(
    MassTime mass, {
    required bool isSunday,
    required bool isHolyDay,
  }) {
    if (isSunday && mass.context == 'sunday') {
      return 4;
    }
    if (isHolyDay &&
        (mass.context == 'solemnity' || mass.context == 'holy_day')) {
      return 4;
    }
    if (mass.isImportantDefault) {
      return 3;
    }
    if (mass.context == 'saturday_vigil') {
      return 2;
    }
    return 1;
  }

  String _weekdayForDate(DateTime date) {
    return const {
      DateTime.monday: 'monday',
      DateTime.tuesday: 'tuesday',
      DateTime.wednesday: 'wednesday',
      DateTime.thursday: 'thursday',
      DateTime.friday: 'friday',
      DateTime.saturday: 'saturday',
      DateTime.sunday: 'sunday',
    }[date.weekday]!;
  }

  String _seasonLabel(String? season) {
    return switch (season) {
      'advent' => 'Mùa Vọng',
      'christmas' => 'Mùa Giáng Sinh',
      'lent' => 'Mùa Chay',
      'easter' => 'Mùa Phục Sinh',
      'ordinary' => 'Thường niên',
      _ => 'Thánh lễ tiếp theo',
    };
  }
}
