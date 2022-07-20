//
//  RoutineView.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI
import WatchConnectivity

class SessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }

    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
}

let connectivityDelegate = SessionDelegate()
let session: WCSession = {
    let session = WCSession.default
    session.delegate = connectivityDelegate
    return session
}()

struct RoutineView: View {
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
//                    Button("Activate routine", action: { withAnimation { isRoutineActive = true } })
                    Button("Activate on Apple Watch", action: {
                        guard WCSession.isSupported() else { return }

                        // activate session if inactive
                        if session.activationState != .activated {
                            session.activate()
                        }

                        // send message querying for
                        session.sendMessage([
                            "activationRequest": "routine",
                            "routineInfo": (try? JSONEncoder().encode(routine)) ?? "null",
                            "startTime": Date()
                        ], replyHandler: { _ in }, errorHandler: { err in
                            print(err)
                        })
                    })
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
                    routine = newRoutine
                    print("How do I replace this now?")
//                    routines.append(routine)
//                    print(try? routines.store(at: Routine.savePath))
//                    routine.debugPrint()
                }, isEdit: true)) {
                    Text("Edit")
                }
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}


struct ExerciseView: View {
    var offset: Int
    var exercise: Routine.Exercise
    var progressDidChange: (Double) -> ()

    @Binding var isRoutineActive: Bool
    @State private var selections = [Bool]()

    init(offset: Int, exercise: Routine.Exercise, isRoutineActive: Binding<Bool>, progressDidChange: @escaping (Double) -> ()) {
        self.offset = offset
        self.exercise = exercise
        self._isRoutineActive = isRoutineActive

        self._selections = .init(wrappedValue: Array(repeating: false, count: exercise.configuration.sets))

        self.progressDidChange = progressDidChange
    }

    private var exerciseProgress: Double {
        Double(selections.filter({ $0 }).count) / Double(exercise.configuration.sets)
    }

    func formattedRest() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: TimeInterval(exercise.configuration.restInterval))!
    }

    var body: some View {
        HStack(alignment: .center) {
            if isRoutineActive {
                Text("#\(offset + 1)")
                    .font(.system(size: 25))
                    .padding()
                    .overlay(CircularProgressView(progress: exerciseProgress))
            }

            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.title2)
                    .padding(.bottom, isRoutineActive ? 2 : 0)

                Text(isRoutineActive ? "\(exercise.configuration.repetitions) reps per set" : "\(exercise.configuration.sets) sets of \(exercise.configuration.repetitions)")
                    .bold()
                Text("\(formattedRest()) rest")

                if isRoutineActive {
                    HStack {
                        ForEach(0..<(exercise.configuration.sets)) { i in
                            SetIndicatorView(i: i + 1, isSelected: $selections[i])
                        }
                    }
                }
            }
            .padding(.vertical, 15)
            .padding(.leading, isRoutineActive ? 10 : 0)
            .onChange(of: exerciseProgress) { progressDidChange($0) }
        }
    }
}

struct SetIndicatorView: View {
    var i: Int
    @Binding var isSelected: Bool

    var body: some View {
        Text("S\(i)")
            .font(.callout.monospacedDigit())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.green : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(5)
            .onTapGesture {
                withAnimation {
                    isSelected.toggle()
                }
            }
    }
}
