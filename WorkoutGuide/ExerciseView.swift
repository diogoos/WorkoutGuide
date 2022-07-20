//
//  ExerciseView.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 20/07/22.
//

import SwiftUI

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

