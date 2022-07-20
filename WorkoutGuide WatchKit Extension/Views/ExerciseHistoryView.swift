//
//  ExerciseHistoryView.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 18/07/22.
//

import SwiftUI

fileprivate struct ExerciseHistoryEntryView: View {
    let exercise: Routine.Exercise

    var body: some View {
        HStack {
            Text(exercise.name)

            Spacer()

            Text("\(exercise.activity.setsCompleted == 0 ? "" : String(exercise.activity.setsCompleted - exercise.activity.setsSkipped))/\(exercise.configuration.sets)")
        }
        .padding()
        .background(Color(red: 0x22/255, green: 0x22/255, blue: 0x22/255))
        .clipShape(Capsule())
        .padding(.horizontal)
    }
}

struct ExerciseHistoryView: View {
    @EnvironmentObject var context: ViewContext
    let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .short
        return f
    }()

    @State var timeElapsed: TimeInterval = 0

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(formatter.string(from: timeElapsed) ?? "")
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                        .padding(.trailing, 12)
                        .padding(.top, -7)

                    Text("Completed")
                        .font(.headline)
                        .padding(.top)

                    ForEach(context.routine?.getExercises(isCompleted: true) ?? []) { ex in
                        ExerciseHistoryEntryView(exercise: ex)
                    }

                    Text("Up next")
                        .font(.headline)
                        .padding(.top, 20)

                    ForEach(context.routine?.getExercises(isCompleted: false) ?? []) { ex in
                        ExerciseHistoryEntryView(exercise: ex)
                    }
                }
            }
        }
        .onAppear(perform: {
            timeElapsed = context.routineStartTime?.distance(to: .now) ?? 0
        })
    }
}
