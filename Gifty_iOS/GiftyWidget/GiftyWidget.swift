import WidgetKit
import SwiftUI
import RealmSwift

// Timeline Entry
struct GiftyEntry: TimelineEntry {
    let date: Date
    let expiryDate: Date?
    let daysRemaining: Int?
}

// Provider
struct GiftyProvider: TimelineProvider {
    func placeholder(in context: Context) -> GiftyEntry {
        GiftyEntry(date: Date(), expiryDate: Date(), daysRemaining: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (GiftyEntry) -> Void) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GiftyEntry>) -> Void) {
        let entry = getEntry()
        // 매일 자정에 업데이트
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func getEntry() -> GiftyEntry {
        // Realm에서 가장 가까운 만료일 교환권 조회
        let realmManager = RealmManager.shared
        let gifts = realmManager.getGifts(sortedBy: .byExpiryDate)

        guard let nearestGift = gifts.first(where: { !$0.checkIsExpired }) else {
            return GiftyEntry(date: Date(), expiryDate: nil, daysRemaining: nil)
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expiryDay = calendar.startOfDay(for: nearestGift.expiryDate)
        let daysRemaining = calendar.dateComponents([.day], from: today, to: expiryDay).day ?? 0

        return GiftyEntry(
            date: Date(),
            expiryDate: nearestGift.expiryDate,
            daysRemaining: daysRemaining
        )
    }
}

// Widget View
struct GiftyWidgetEntryView: View {
    var entry: GiftyEntry

    var body: some View {
        ZStack {
            Color(hex: "FFF7EC")

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)

                // 만료 날짜
                if let expiryDate = entry.expiryDate {
                    Text("만료 날짜 \(formatDate(expiryDate))")
                        .font(.custom("OwnglyphPDH-Regular", size: 20))
                        .foregroundColor(Color(hex: "6A4C4C"))

                    Spacer()
                        .frame(height: 11)

                    // D-day
                    if let days = entry.daysRemaining {
                        Text("D - \(days)")
                            .font(.custom("OwnglyphPDH-Regular", size: 50))
                            .foregroundColor(Color(hex: "6A4C4C"))
                            .frame(width: 94, height: 54)
                    }
                } else {
                    Text("교환권 없음")
                        .font(.custom("OwnglyphPDH-Regular", size: 20))
                        .foregroundColor(Color(hex: "6A4C4C"))
                }

                Spacer()
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd."
        return formatter.string(from: date)
    }
}

// Widget
struct GiftyWidget: Widget {
    let kind: String = "GiftyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GiftyProvider()) { entry in
            GiftyWidgetEntryView(entry: entry)
                .containerBackground(Color(hex: "FFF7EC"), for: .widget)
        }
        .configurationDisplayName("Gifty")
        .description("가장 가까운 교환권의 만료일을 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

// Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview(as: .systemSmall) {
    GiftyWidget()
} timeline: {
    GiftyEntry(date: .now, expiryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()), daysRemaining: 3)
    GiftyEntry(date: .now, expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), daysRemaining: 1)
}
