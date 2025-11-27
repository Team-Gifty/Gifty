//
//  GiftyWidgetLiveActivity.swift
//  GiftyWidget
//
//  Created by 이지훈 on 11/27/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GiftyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GiftyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GiftyWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GiftyWidgetAttributes {
    fileprivate static var preview: GiftyWidgetAttributes {
        GiftyWidgetAttributes(name: "World")
    }
}

extension GiftyWidgetAttributes.ContentState {
    fileprivate static var smiley: GiftyWidgetAttributes.ContentState {
        GiftyWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GiftyWidgetAttributes.ContentState {
         GiftyWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GiftyWidgetAttributes.preview) {
   GiftyWidgetLiveActivity()
} contentStates: {
    GiftyWidgetAttributes.ContentState.smiley
    GiftyWidgetAttributes.ContentState.starEyes
}
