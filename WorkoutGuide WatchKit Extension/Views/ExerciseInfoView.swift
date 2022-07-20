//
//  ExerciseInfoView.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 18/07/22.
//

import SwiftUI

struct ExerciseInfoView: View {
    @EnvironmentObject var context: ViewContext

    @State var showModal: Bool = false
    @State var showSkipConfirmation: Bool = false

    var overallProgress: Double {
        let completed = context.routine!.exercises.map { $0.activity.setsCompleted }.reduce(0, +)
        let total = context.routine!.exercises.map { $0.configuration.sets }.reduce(0, +)
        return Double(completed) / Double(total)
    }


    var body: some View {
        VStack {
            Text(context.currentExercise!.name)
                .font(.title2)

            Text("Set #\(context.currentExercise!.activity.setsCompleted + 1)")
                .font(.title3)

            Text("\(context.currentExercise!.configuration.repetitions) reps")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture(count: 2, perform: { showModal = true })
        .overlay(ProgressEdgeView(progress: overallProgress))
        .confirmationDialog("Finished?", isPresented: $showModal) {
            Button("Next set", action: {
                context.currentExercise!.activity.setsCompleted += 1

                if context.currentExercise!.activity.setsCompleted == context.currentExercise!.configuration.sets {

                    withAnimation {
                        context.currentPage = .exercisePickView
                        context.currentExercise!.activity.endDate = .now
                    }
                    return
                } else {
                    context.currentPage = .restView
                }

            })
            Button("Skip set", action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showSkipConfirmation = true
                }
            })
        }
        .alert("Skip set", isPresented: $showSkipConfirmation, actions: {
            Button("Skip", action: {
                context.currentExercise!.activity.setsCompleted += 1
                context.currentExercise!.activity.setsSkipped += 1

                if context.currentExercise!.activity.setsCompleted == context.currentExercise!.configuration.sets {
                    withAnimation {
                        context.currentPage = .exercisePickView
                        context.currentExercise!.activity.endDate = .now
                    }
                    return
                }
            })
            Button("Cancel", action: {})
        }, message: { Text("Are you sure you would like to skip this set, marking it as incomplete?") })
    }
}
