//
//  RoutineView.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI
import WatchConnectivity


struct RoutineView: View {
    @EnvironmentObject var context: ContextManager
    @State var routine: Routine

    @State private var isRoutineActive: Bool = false
    @State private var exerciseProgress: [Double]


    init(routine: Routine) {
        self._routine = .init(wrappedValue: routine)
        self._exerciseProgress = .init(wrappedValue: [Double](repeating: 0, count: routine.exercises.count))
    }

    private var overallProgress: Double {
        exerciseProgress.reduce(0.0, +) / Double(routine.exercises.count)
    }

    @State private var isAppleWatchSessionActivated: Bool = false
    var body: some View {
        List {
            if !isRoutineActive {
                Section {
                    Button("Activate routine", action: { withAnimation { isRoutineActive = true } })

                    if context.watchSession.isReachable {
                        Button("Activate on Apple Watch", action: {
                            // send message querying for
                            context.watchSession.sendMessage([
                                "activationRequest": "routine",
                                "routineInfo": (try? JSONEncoder().encode(routine)) ?? "null",
                                "startTime": Date()
                            ], replyHandler: { _ in }, errorHandler: { err in
                                print(err)
                            })
                        })
                    }

                }
            }

            if isRoutineActive {
                Section {
                    ProgressView("Routine progress", value: overallProgress)
                        .accentColor(overallProgress == 1 ? Color.green : Color.accentColor)
                        .padding(.vertical)
                }
            }



            ForEach(Array(routine.exercises.enumerated()), id: \.offset) { offset, exercise in
                Section {
                    ExerciseView(offset: offset, exercise: exercise, isRoutineActive: $isRoutineActive, progressDidChange: { p in
                        withAnimation {
                            exerciseProgress[offset] = p
                        }
                    })
                }
            }

            if isRoutineActive {
                Section(footer: Text("This will deactivate this routine and erase all progress")) {
                    Button("Cancel routine", action: { isRoutineActive = false })
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(routine.label)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: RoutineBuilderView(routine: routine, completion: { newRoutine in
                    guard let index = context.routines.firstIndex(where: { $0.id == routine.id }) else { return }

                    newRoutine.id = routine.id // make sure the ids match
                    context.routines[index] = newRoutine // update the routine
                    try? context.saveState()
                }, isEdit: true)) {
                    Text("Edit")
                }
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}
