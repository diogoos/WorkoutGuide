//
//  MultipageContainerView.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 18/07/22.
//

import SwiftUI
import WatchKit

struct MultipageContainerView<Page: View>: View {
    @State var selectedTab: Int = 1
    var page: Page

    var body: some View {
        TabView(selection: $selectedTab) {
            ExerciseHistoryView().tag(0)
            page.tag(1)
            NowPlayingView().tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}
