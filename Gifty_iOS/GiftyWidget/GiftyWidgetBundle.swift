import WidgetKit
import SwiftUI

@main
struct GiftyWidgetBundle: WidgetBundle {
    var body: some Widget {
        GiftyWidget()
        GiftyWidgetControl()
        GiftyWidgetLiveActivity()
    }
}
