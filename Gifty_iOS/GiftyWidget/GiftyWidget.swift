import WidgetKit
import SwiftUI

// Timeline Entry
struct GiftyEntry: TimelineEntry {
    let date: Date
    let expiryDate: Date?
    let daysRemaining: Int?
    let debugInfo: String
}

// Provider
struct GiftyProvider: TimelineProvider {
    func placeholder(in context: Context) -> GiftyEntry {
        GiftyEntry(date: Date(), expiryDate: Date(), daysRemaining: 1, debugInfo: "placeholder")
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
        do {
            let realmManager = RealmManager.shared
            let gifts = realmManager.getGifts(sortedBy: .byExpiryDate)

            let debugInfo = "총 \(gifts.count)개"

            guard let nearestGift = gifts.first(where: { !$0.checkIsExpired }) else {
                return GiftyEntry(date: Date(), expiryDate: nil, daysRemaining: nil, debugInfo: debugInfo + " / 유효한 교환권 없음")
            }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let expiryDay = calendar.startOfDay(for: nearestGift.expiryDate)
            let daysRemaining = calendar.dateComponents([.day], from: today, to: expiryDay).day ?? 0

            return GiftyEntry(
                date: Date(),
                expiryDate: nearestGift.expiryDate,
                daysRemaining: daysRemaining,
                debugInfo: debugInfo + " / 성공"
            )
        } catch {
            return GiftyEntry(date: Date(), expiryDate: nil, daysRemaining: nil, debugInfo: "에러: \(error.localizedDescription)")
        }
    }
}

// Widget View
struct GiftyWidgetEntryView: View {
    var entry: GiftyEntry

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.97, blue: 0.93)

            VStack(spacing: 5) {
                // 디버그 정보 (상단에 작게 표시)
                Text(entry.debugInfo)
                    .font(.system(size: 10))
                    .foregroundColor(.red)

                Spacer()
                    .frame(height: 10)

                // 만료 날짜
                if let expiryDate = entry.expiryDate {
                    Text("만료 날짜 \(formatDate(expiryDate))")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.42, green: 0.30, blue: 0.30))

                    Spacer()
                        .frame(height: 11)

                    // D-day
                    if let days = entry.daysRemaining {
                        Text("D - \(days)")
                            .font(.system(size: 50))
                            .foregroundColor(Color(red: 0.42, green: 0.30, blue: 0.30))
                            .frame(width: 94, height: 54)
                    }
                } else {
                    Text("교환권 없음")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.42, green: 0.30, blue: 0.30))
                }

                Spacer()
            }
            .padding(.top, 10)
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
                .containerBackground(Color(red: 1.0, green: 0.97, blue: 0.93), for: .widget)
        }
        .configurationDisplayName("Gifty")
        .description("가장 가까운 교환권의 만료일을 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    GiftyWidget()
} timeline: {
    GiftyEntry(date: .now, expiryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()), daysRemaining: 3, debugInfo: "총 5개 / 성공")
    GiftyEntry(date: .now, expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), daysRemaining: 1, debugInfo: "총 5개 / 성공")
}
