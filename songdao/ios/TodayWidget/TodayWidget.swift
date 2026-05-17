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

  let date: String?
  let locale: String?
  let liturgicalContext: LiturgicalContext?
  let action: Action?
  let readings: [Reading]?
  let mass: Mass?

  enum CodingKeys: String, CodingKey {
    case date
    case locale
    case liturgicalContext = "liturgical_context"
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

  var celebration: String {
    snapshot?.liturgicalContext?.celebration
      ?? snapshot?.liturgicalContext?.season
      ?? "Sống Đạo hôm nay"
  }

  var actionPrompt: String {
    snapshot?.action?.prompt
      ?? "Mở Sống Đạo để nhận một việc nhỏ cho hôm nay."
  }

  var gospelCitation: String? {
    snapshot?.readings?.first(where: { $0.type == "gospel" })?.citation
  }

  var massSummary: String? {
    guard let mass = snapshot?.mass, let time = mass.time else {
      return nil
    }
    let label = mass.label ?? "Thánh lễ"
    if let church = mass.church, !church.isEmpty {
      return "\(label): \(time) - \(church)"
    }
    return "\(label): \(time)"
  }

  var massLanguage: String? {
    guard let language = snapshot?.mass?.language, !language.isEmpty else {
      return nil
    }
    return language
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
    return try? JSONDecoder().decode(SongDaoWidgetSnapshot.self, from: data)
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
    .padding(14)
    .songDaoWidgetBackground(canvas)
    .widgetURL(todayDeepLink)
  }

  private var smallLayout: some View {
    VStack(alignment: .leading, spacing: 9) {
      HStack(alignment: .top, spacing: 10) {
        dateTile

        VStack(alignment: .leading, spacing: 4) {
          Text(entry.dateLabel)
            .font(.caption2.weight(.semibold))
            .foregroundColor(secondaryInk)
            .textCase(.uppercase)
            .lineLimit(1)

          contextHeader
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      Text(entry.actionPrompt)
        .font(.system(.headline, design: .default).weight(.semibold))
        .foregroundColor(ink)
        .lineLimit(3)
        .minimumScaleFactor(0.76)

      if let gospelCitation = entry.gospelCitation {
        Text("Tin Mừng: \(gospelCitation)")
          .font(.caption2)
          .foregroundColor(secondaryInk)
          .lineLimit(1)
      }
    }
  }

  private var mediumLayout: some View {
    HStack(alignment: .top, spacing: 14) {
      dateTile

      VStack(alignment: .leading, spacing: 8) {
        contextHeader

        Text(entry.actionPrompt)
          .font(.headline)
          .foregroundColor(ink)
          .lineLimit(3)
          .minimumScaleFactor(0.82)
      }

      Divider()
        .background(border)

      VStack(alignment: .leading, spacing: 8) {
        if entry.isCompleted {
          Label("Đã ghi nhận", systemImage: "checkmark.circle.fill")
            .font(.caption.weight(.semibold))
            .foregroundColor(green)
            .lineLimit(1)
        }

        if let massSummary = entry.massSummary {
          Label {
            Text(massSummary)
              .lineLimit(2)
              .minimumScaleFactor(0.82)
          } icon: {
            Image(systemName: "bell")
          }
          .font(.caption.weight(.semibold))
          .foregroundColor(ink)

          if let language = entry.massLanguage {
            Text(language)
              .font(.caption2)
              .foregroundColor(secondaryInk)
              .lineLimit(1)
          }
        } else if let gospelCitation = entry.gospelCitation {
          Text("Tin Mừng")
            .font(.caption.weight(.semibold))
            .foregroundColor(green)
          Text(gospelCitation)
            .font(.caption)
            .foregroundColor(secondaryInk)
            .lineLimit(2)
        } else {
          Text("Mở Sống Đạo để xem chi tiết hôm nay.")
            .font(.caption)
            .foregroundColor(secondaryInk)
            .lineLimit(3)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var contextHeader: some View {
    HStack(spacing: 6) {
      RoundedRectangle(cornerRadius: 2)
        .fill(entry.isCompleted ? green : liturgicalAccent)
        .frame(width: 4, height: 28)
      Text(entry.celebration)
        .font(.system(.caption, design: .default).weight(.semibold))
        .foregroundColor(ink)
        .lineLimit(2)
    }
  }

  private var dateTile: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(entry.isCompleted ? green : liturgicalAccent)
        .frame(height: 7)

      Text(entry.dayNumber)
        .font(.system(size: 32, weight: .bold, design: .rounded))
        .foregroundColor(ink)
        .minimumScaleFactor(0.75)
        .lineLimit(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(width: 52, height: 58)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .stroke(border, lineWidth: 1)
    )
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
