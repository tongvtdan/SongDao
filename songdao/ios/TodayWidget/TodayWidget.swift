import SwiftUI
import WidgetKit

private let appGroupId = "group.com.dantino.songdao"
private let latestSnapshotKey = "latest_widget_snapshot"
private let todayDeepLink = URL(string: "songdao:///today")

struct SongDaoWidgetSnapshot: Decodable {
  struct LiturgicalContext: Decodable {
    let season: String?
    let color: String?
    let celebration: String?
  }

  struct Action: Decodable {
    let prompt: String?
    let completed: Bool?
    let status: String?
  }

  struct Reading: Decodable {
    let type: String?
    let label: String?
    let citation: String?
  }

  struct Mass: Decodable {
    let church: String?
    let time: String?
    let language: String?
    let label: String?
  }

  struct DailyQuote: Decodable {
    let text: String?
    let attribution: String?
  }

  let date: String?
  let locale: String?
  let liturgicalContext: LiturgicalContext?
  let dailyQuote: DailyQuote?
  let saintOfDay: String?
  let action: Action?
  let readings: [Reading]?
  let mass: Mass?

  enum CodingKeys: String, CodingKey {
    case date
    case locale
    case liturgicalContext = "liturgical_context"
    case dailyQuote = "daily_quote"
    case saintOfDay = "saint_of_day"
    case action
    case readings
    case mass
  }
}

struct SongDaoTodayEntry: TimelineEntry {
  let date: Date
  let snapshot: SongDaoWidgetSnapshot?

  var displayDate: Date {
    guard
      let dateKey = snapshot?.date,
      let parsed = Self.dateFormatter.date(from: dateKey)
    else {
      return date
    }
    return parsed
  }

  var dayNumber: String {
    Self.dayFormatter.string(from: displayDate)
  }

  var dateLabel: String {
    Self.dateLabelFormatter.string(from: displayDate)
  }

  var weekdayLabel: String {
    Self.weekdayFormatter.string(from: displayDate)
  }

  var celebration: String {
    snapshot?.liturgicalContext?.celebration
      ?? snapshot?.liturgicalContext?.season
      ?? "Sống Đạo hôm nay"
  }

  var saintOrFallback: String {
    if let saint = snapshot?.saintOfDay, !saint.isEmpty {
      return saint
    }
    return "Sống Đạo hôm nay"
  }

  var featureText: String {
    if let saint = snapshot?.saintOfDay, !saint.isEmpty {
      return saint
    }
    return quoteText
  }

  var quoteText: String {
    return snapshot?.dailyQuote?.text
      ?? "Một việc nhỏ được làm với lòng yêu mến có thể đổi hướng cả ngày."
  }

  var isCompleted: Bool {
    snapshot?.action?.completed == true || snapshot?.action?.status == "completed"
  }

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()

  private static let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "vi_VN")
    formatter.dateFormat = "d"
    return formatter
  }()

  private static let dateLabelFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "vi_VN")
    formatter.dateFormat = "EEE, d MMM"
    return formatter
  }()

  private static let weekdayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "vi_VN")
    formatter.dateFormat = "EEEE"
    return formatter
  }()
}

struct SongDaoTodayProvider: TimelineProvider {
  func placeholder(in context: Context) -> SongDaoTodayEntry {
    SongDaoTodayEntry(date: Date(), snapshot: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (SongDaoTodayEntry) -> Void) {
    completion(SongDaoTodayEntry(date: Date(), snapshot: readSnapshot()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SongDaoTodayEntry>) -> Void) {
    let entry = SongDaoTodayEntry(date: Date(), snapshot: readSnapshot())
    let nextRefresh = Calendar.current.nextDate(
      after: Date(),
      matching: DateComponents(hour: 0, minute: 5),
      matchingPolicy: .nextTime
    ) ?? Date().addingTimeInterval(60 * 60)
    completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
  }

  private func readSnapshot() -> SongDaoWidgetSnapshot? {
    guard
      let defaults = UserDefaults(suiteName: appGroupId),
      let payload = defaults.string(forKey: latestSnapshotKey),
      let data = payload.data(using: .utf8)
    else {
      return nil
    }

    guard let snapshot = try? JSONDecoder().decode(SongDaoWidgetSnapshot.self, from: data) else {
      return nil
    }

    return snapshot.date == Self.todayDateKey ? snapshot : nil
  }

  private static var todayDateKey: String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }
}

struct SongDaoTodayWidgetView: View {
  @Environment(\.widgetFamily) private var family

  let entry: SongDaoTodayEntry

  var body: some View {
    Group {
      if family == .systemMedium {
        mediumLayout
      } else {
        smallLayout
      }
    }
    .padding(family == .systemMedium ? 22 : 20)
    .songDaoWidgetBackground(canvas)
    .widgetURL(todayDeepLink)
  }

  private var smallLayout: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(entry.weekdayLabel.uppercased())
        .font(.system(size: 23, weight: .bold, design: .default))
        .foregroundColor(liturgicalAccent)
        .lineLimit(1)
        .minimumScaleFactor(0.68)

      Text(entry.dayNumber)
        .font(.system(size: 66, weight: .regular, design: .default))
        .foregroundColor(.black)
        .lineLimit(1)
        .minimumScaleFactor(0.84)

      Spacer(minLength: 10)

      Text(entry.featureText)
        .font(.system(size: 22, weight: .regular, design: .default))
        .foregroundColor(secondaryInk)
        .lineLimit(3)
        .minimumScaleFactor(0.74)
    }
  }

  private var mediumLayout: some View {
    HStack(alignment: .top, spacing: 18) {
      mediumDateColumn
        .frame(width: 116, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .topLeading)

      Divider()
        .background(border)
        .padding(.vertical, 2)

      VStack(alignment: .leading, spacing: 12) {
        Text(entry.dateLabel.uppercased())
          .font(.system(size: 18, weight: .bold, design: .default))
          .foregroundColor(secondaryInk)
          .lineLimit(1)
          .minimumScaleFactor(0.78)

        agendaBlock

        completionStatus
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
  }

  private var mediumDateColumn: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(entry.weekdayLabel.uppercased())
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(liturgicalAccent)
        .lineLimit(1)
        .minimumScaleFactor(0.72)

      Text(entry.dayNumber)
        .font(.system(size: 58, weight: .regular, design: .default))
        .foregroundColor(.black)
        .lineLimit(1)
        .minimumScaleFactor(0.86)

      Spacer(minLength: 10)

      Text(entry.saintOrFallback)
        .font(.system(size: 16, weight: .regular, design: .default))
        .foregroundColor(secondaryInk)
        .lineLimit(3)
        .minimumScaleFactor(0.76)
    }
  }

  private var agendaBlock: some View {
    HStack(alignment: .top, spacing: 8) {
      RoundedRectangle(cornerRadius: 2)
        .fill(liturgicalAccent)
        .frame(width: 4)
        .frame(maxHeight: .infinity)

      VStack(alignment: .leading, spacing: 0) {
        Text(entry.quoteText)
          .font(.system(size: 18, weight: .semibold, design: .default))
          .foregroundColor(ink)
          .lineLimit(4)
          .minimumScaleFactor(0.78)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 11)
    .background(softGreen)
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
  }

  @ViewBuilder
  private var completionStatus: some View {
    if entry.isCompleted {
      Label("Đã ghi nhận", systemImage: "checkmark.circle.fill")
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(green)
        .lineLimit(1)
    }
  }

  private var ink: Color {
    Color(red: 0.12, green: 0.15, blue: 0.13) // #1F2522
  }

  private var secondaryInk: Color {
    Color(red: 0.37, green: 0.40, blue: 0.38) // #5F6761
  }

  private var green: Color {
    Color(red: 0.12, green: 0.48, blue: 0.39) // #1F7A64
  }

  private var softGreen: Color {
    Color(red: 0.89, green: 0.95, blue: 0.92) // #E2F1EA
      .opacity(0.56)
  }

  private var gold: Color {
    Color(red: 0.72, green: 0.54, blue: 0.18) // #B8892E
  }

  private var canvas: Color {
    Color(red: 0.98, green: 0.97, blue: 0.95) // #FAF8F3
  }

  private var border: Color {
    Color(red: 0.89, green: 0.87, blue: 0.82) // #E2DDD1
  }

  private var liturgicalAccent: Color {
    switch entry.snapshot?.liturgicalContext?.color {
    case "red":
      return Color(red: 0.70, green: 0.23, blue: 0.23) // #B33A3A
    case "purple":
      return Color(red: 0.42, green: 0.29, blue: 0.48) // #6B4A7A
    case "rose":
      return Color(red: 0.79, green: 0.47, blue: 0.55) // #C9788D
    case "white", "gold":
      return gold
    case "black":
      return ink
    default:
      return green
    }
  }
}

private extension View {
  @ViewBuilder
  func songDaoWidgetBackground(_ color: Color) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(color, for: .widget)
    } else {
      background(color)
    }
  }
}

@main
struct SongDaoTodayWidget: Widget {
  let kind = "SongDaoTodayWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: SongDaoTodayProvider()) { entry in
      SongDaoTodayWidgetView(entry: entry)
    }
    .configurationDisplayName("Sống Đạo")
    .description("Việc sống đạo hôm nay.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
