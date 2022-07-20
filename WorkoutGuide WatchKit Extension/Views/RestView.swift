//
//  RestView.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 18/07/22.
//

import SwiftUI

struct RestView: View {
    @EnvironmentObject var context: ViewContext

    @State var isTimedRecovery: Bool = true

    @State var elapsedTime: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var timedRecoveryDuration: Int {
        context.currentExercise!.configuration.restInterval
    }

    @State var showActionMenu: Bool = false
    @State var showEndAlert: Bool = false




    let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .second]
        f.unitsStyle = .short
        return f
    }()

    var body: some View {
        VStack {
            if isTimedRecovery {
                Text("Recover")
                    .font(.title2)

                Text(String(format: "%02d", timedRecoveryDuration - elapsedTime))
                    .font(.title2.monospacedDigit())
                    .padding(15)
                    .overlay(CircularProgressView(progress: Double(max(timedRecoveryDuration - elapsedTime, 0)) / Double(timedRecoveryDuration)))
                    .padding()

            } else {
                Spacer()

                Text(formatter.string(from: TimeInterval(elapsedTime)) ?? "\(elapsedTime) sec")
                    .font(.title2.monospacedDigit())

                Spacer()

                Text("Double tap screen to end recovery")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .onReceive(timer) { _ in
            elapsedTime += 1

            if isTimedRecovery && elapsedTime >= timedRecoveryDuration {
                context.currentPage = .exerciseView
            }
        }
        .onTapGesture(count: 2, perform: {
            if isTimedRecovery {
                showActionMenu = true
            } else {
                showEndAlert = true
            }
        })
        .actionSheet(isPresented: $showActionMenu) {
            ActionSheet(title: Text("Modify rest?"), buttons: [
                .default(Text("Skip"), action: {
                    context.currentPage = .exerciseView
                }),
                .default(Text("Extend"), action: { isTimedRecovery = false })
            ])
        }
        .alert("End rest?", isPresented: $showEndAlert) {
            Button("End", action: {
                context.currentPage = .exerciseView
            })
            Button("Cancel", action: {})
        }
    }
}
