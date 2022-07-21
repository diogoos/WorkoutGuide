//
//  FinishedView.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 18/07/22.
//

import SwiftUI

struct FinishedView: View {
    @EnvironmentObject var context: ViewContext
    let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .full
        return f
    }()

    @State var timeInterval: TimeInterval = 0

    var body: some View {
        VStack {
            Text("Finished!")
                .font(.largeTitle)

            if let duration = formatter.string(for: timeInterval) {
                Text(duration)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green.ignoresSafeArea())
        .onAppear(perform: {
            context.routineEndTime = .now
            timeInterval = context.routineStartTime!.distance(to: .now)

            // - TODO: deinit app
            // -- send activity back to ios app to be logged
            // -- erase context to prepare for another routine
        })
    }
}
