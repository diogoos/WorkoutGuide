//
//  Workout.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import Foundation

final class Routine: Codable, Saveable, Identifiable {
    var id = UUID()

    init(label: String, exercises: [Routine.Exercise], defaultConfiguration: Routine.Configuration) {
        self.label = label
        self.exercises = exercises
//        self.defaultConfiguration = defaultConfiguration
    }

    var label: String // Name of routine (A, B, C)
    var exercises: [Exercise] // list of exercises to be done

    struct Configuration: Codable, Equatable {
        var repetitions: Int
        var sets: Int
        var restInterval: Int

        func debugString() -> String {
            "\(sets)x\(repetitions) - \(restInterval)"
        }
    }

    final class Exercise: Codable, Identifiable, Equatable {
        static func == (lhs: Routine.Exercise, rhs: Routine.Exercise) -> Bool {
            lhs.id == rhs.id
        }

        var id = UUID()

        init(name: String, weight: Int?, configuration: Routine.Configuration,  notes: String) {
            self.name = name
            self.weight = weight
            self.configuration = configuration
            self.notes = notes
        }

        var name: String // Name of Exercise (bench press)
        var weight: Int?

        var configuration: Configuration

        var notes: String // user field for notes about the exercise

        enum CodingKeys: CodingKey {
            case name, weight, configuration, notes
        }

        var activity: Activity = Activity(startDate: nil, endDate: nil, setsCompleted: 0) // not codable
    }

    // var defaultConfiguration: Configuration // Repetition config, such as 4x12

    static var savePath: URL = {
        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = documentDir.appendingPathComponent("saved_routines.json")
        return path
    }()

    func debugPrint() {
        print("------")
        print("Label: \(label)")
//        print("Default configuration: \(defaultConfiguration.debugString())")
        print("Exercises:")
        for e in exercises {
            print("   Name: \(e.name)")
            print("   Weight: \(e.weight)")
            print("   Configuration: \(e.configuration.debugString())")
            print("   Notes: \(e.notes)")
            print("   ---")
        }
        print("-------")
    }
}

