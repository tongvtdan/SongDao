import SwiftUI
import WidgetKit

private let appGroupId = "group.com.dantino.songdao"
private let latestSnapshotKey = "latest_widget_snapshot"
private let todayDeepLink = URL(string: "songdao://today")

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

  let date: String?
  let locale: String?
  let liturgicalContext: LiturgicalContext?
  let action: Action?
  let readings: [Reading]?

  enum CodingKeys: String, CodingKey {
    case date
    case locale
    case liturgicalContext = "liturgical_context"
    case action
    case readings
  }
}

struct SongDaoTodayEntry: TimelineEntry {
  let date: Date
  let snapshot: SongDaoWidgetSnapshot?

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

  var isCompleted: Bool {
    snapshot?.action?.completed == true || snapshot?.action?.status == "completed"
  }
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
  let entry: SongDaoTodayEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 6) {
        Circle()
          .fill(entry.isCompleted ? Color(red: 0.12, green: 0.48, blue: 0.39) : Color(red: 0.72, green: 0.54, blue: 0.18))
          .frame(width: 8, height: 8)
        Text(entry.celebration)
          .font(.system(.caption, design: .default).weight(.semibold))
          .foregroundColor(Color(red: 0.12, green: 0.15, blue: 0.13))
          .lineLimit(2)
      }

      Text(entry.actionPrompt)
        .font(.headline)
        .foregroundColor(Color(red: 0.12, green: 0.15, blue: 0.13))
        .lineLimit(4)
        .minimumScaleFactor(0.78)

      if let gospelCitation = entry.gospelCitation {
        Text("Tin Mừng: \(gospelCitation)")
          .font(.caption2)
          .foregroundColor(Color(red: 0.37, green: 0.40, blue: 0.38))
          .lineLimit(1)
      }
    }
    .padding(14)
    .background(Color(red: 0.98, green: 0.97, blue: 0.95))
    .widgetURL(todayDeepLink)
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
