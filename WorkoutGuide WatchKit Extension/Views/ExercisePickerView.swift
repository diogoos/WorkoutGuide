//
//  ExercisePickerView.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 18/07/22.
//

import SwiftUI

struct ExercisePickerView: View {
    @EnvironmentObject var context: ViewContext
    var isFirstPick: Bool = false

    @ViewBuilder func completedExerciseRow(exercise: Routine.Exercise) -> some View {
        HStack {
            Text(exercise.name)
                .foregroundColor(.primary.opacity(0.6))

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }

    }

    var body: some View {
        List {
            Section(header: Text(isFirstPick ? "Select exercise:" : "Exercise done! Next up:")) {
                ForEach(context.routine?.getExercises(isStarted: false) ?? []) { ex in
                    Button(ex.name, action: {
                        context.currentExercise = ex
                        withAnimation {
                            ex.activity.startDate = .now
                            context.currentPage = .exerciseView
                        }
                    })
                }
            }

            if !isFirstPick {
                Section {
                    ForEach(context.routine?.getExercises(isCompleted: true) ?? []) { ex in
                        completedExerciseRow(exercise: ex)
                    }
                }

                Section {
                    Button("End routine", action: {})
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            if let r = context.routine, r.getExercises(isStarted: false).count == 0 {
                context.currentPage = .finishedView
            }
        }
    }
}
