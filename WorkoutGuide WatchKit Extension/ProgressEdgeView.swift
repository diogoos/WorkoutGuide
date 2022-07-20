//
//  ProgressEdgeView.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 18/07/22.
//

import SwiftUI
import WatchKit


struct ProgressEdgeView: View {
    var progress: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 41)
                .trim(from: 0, to: progress)
                .stroke(.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .padding(.all, 3)
                .ignoresSafeArea()
        }
    }
}
