import WidgetKit
import SwiftUI

struct GiftyEntry: TimelineEntry {
    let date: Date
    let expiryDate: Date?
    let daysRemaining: Int?
    let validGiftsCount: Int
}

struct GiftyProvider: TimelineProvider {
    func placeholder(in context: Context) -> GiftyEntry {
        GiftyEntry(date: Date(), expiryDate: Date(), daysRemaining: 1, validGiftsCount: 4)
    }

    func getSnapshot(in context: Context, completion: @escaping (GiftyEntry) -> Void) {
        completion(getEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GiftyEntry>) -> Void) {
        let entry = getEntry()
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func getEntry() -> GiftyEntry {
        let realmManager = RealmManager.shared
        let gifts = realmManager.getGifts(sortedBy: .byExpiryDate)

        let validGifts = gifts.filter { !$0.checkIsExpired }
        let validGiftsCount = validGifts.count

        guard let nearestGift = validGifts.first else {
            return GiftyEntry(date: Date(), expiryDate: nil, daysRemaining: nil, validGiftsCount: validGiftsCount)
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expiryDay = calendar.startOfDay(for: nearestGift.expiryDate)
        let daysRemaining = calendar.dateComponents([.day], from: today, to: expiryDay).day ?? 0

        return GiftyEntry(
            date: Date(),
            expiryDate: nearestGift.expiryDate,
            daysRemaining: daysRemaining,
            validGiftsCount: validGiftsCount
        )
    }
}

struct GiftyWidgetEntryView: View {
    var entry: GiftyEntry

    var body: some View {
        ZStack {
            Color.widgetBackground

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)

                if let expiryDate = entry.expiryDate {
                    Text("만료 날짜 \(formatDate(expiryDate))")
                        .font(.giftyFont(size: 14))
                        .foregroundColor(.widgetText)

                    Spacer()
                        .frame(height: 11)

                    if let days = entry.daysRemaining {
                        Text("D - \(days)")
                            .font(.giftyFont(size: 40))
                            .foregroundColor(.widgetText)
                    }

                    Spacer()
                        .frame(height: 10)

                    HStack(spacing: 7) {
                        Image("GiftyBox")
                            .resizable()
                            .frame(width: 27, height: 32)

                        Text(": \(entry.validGiftsCount)개")
                            .font(.giftyFont(size: 25))
                            .foregroundColor(.widgetText)
                    }
                } else {
                    Text("교환권 없음")
                        .font(.giftyFont(size: 14))
                        .foregroundColor(.widgetText)
                }

                Spacer()
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter.string(from: date)
    }
}

struct GiftyWidget: Widget {
    let kind: String = "GiftyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GiftyProvider()) { entry in
            GiftyWidgetEntryView(entry: entry)
                .containerBackground(Color.widgetBackground, for: .widget)
        }
        .configurationDisplayName("Gifty")
        .description("가장 가까운 교환권의 만료일을 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    GiftyWidget()
} timeline: {
    GiftyEntry(date: .now, expiryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()), daysRemaining: 3, validGiftsCount: 4)
    GiftyEntry(date: .now, expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), daysRemaining: 1, validGiftsCount: 2)
}
