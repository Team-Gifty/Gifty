//
//  GiftyWigetBundle.swift
//  GiftyWiget
//
//  Created by 이지훈 on 10/30/25.
//

import WidgetKit
import SwiftUI

@main
struct GiftyWigetBundle: WidgetBundle {
    var body: some Widget {
        GiftyWiget()
        GiftyWigetControl()
        GiftyWigetLiveActivity()
    }
}
