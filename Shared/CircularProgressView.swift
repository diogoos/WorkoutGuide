//
//  CircularProgressView.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    @State private var color = Color.blue

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.5),
                    lineWidth: 5
                )

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
                .onChange(of: progress) { newProgress in
                    if newProgress == 1 {
                        color = .green
                        return
                    }

                    if newProgress != 1 && color == .green {
                        color = .blue
                    }
                }

        }
    }
}
