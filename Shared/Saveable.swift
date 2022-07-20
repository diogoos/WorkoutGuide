//
//  Saveable.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import Foundation

protocol Saveable: Codable {
    static func load(from savePath: URL) -> Self?
    func store(at savePath: URL) throws
}

extension Saveable {
    static func load(from savePath: URL) -> Self? {
        do {
            let data = try Data(contentsOf: savePath)
            let routines = try JSONDecoder().decode(Self.self, from: data)
            return routines
        } catch {
            print("Failed to load data from \(savePath)")
            return nil
        }
    }

    func store(at savePath: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: savePath, options: .atomic)
    }
}

extension Array: Saveable where Element: Saveable {}
