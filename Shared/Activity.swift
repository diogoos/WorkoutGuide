//
//  Activity.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import Foundation

struct Activity {
    var startDate: Date?
    var endDate: Date?

    var setsCompleted: Int
    var setsSkipped: Int = 0
}

extension Routine {
    /// Returns a list of exercises that have been started
    func getExercises(isStarted: Bool) -> [Exercise] {
        if isStarted {
            return exercises.filter { $0.activity.setsCompleted != 0 }
        }
        return exercises.filter { $0.activity.setsCompleted == 0 }
    }

    /// Returns a list of exercises that are completed
    func getExercises(isCompleted: Bool) -> [Exercise] {
        if isCompleted {
            return exercises.filter { $0.activity.setsCompleted == $0.configuration.sets }
        }
        return exercises.filter { $0.activity.setsCompleted != $0.configuration.sets }
    }
}
