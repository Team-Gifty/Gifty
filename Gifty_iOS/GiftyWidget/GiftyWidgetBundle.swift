//
//  GiftyWidgetBundle.swift
//  GiftyWidget
//
//  Created by 이지훈 on 11/27/25.
//

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
