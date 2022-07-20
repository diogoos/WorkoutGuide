//
//  ContextManager.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 20/07/22.
//

import Foundation
import WatchConnectivity

class ContextManager: NSObject, ObservableObject {
    @Published var routines: [Routine]
    var watchSession: WCSession

    override init() {
        self.routines = [Routine].load(from: Routine.savePath) ?? [] // load routines from file
        self.watchSession = WCSession.default
        super.init()

        if WCSession.isSupported() {
            watchSession.delegate = self
            watchSession.activate()
        }
    }

    func saveState() throws {
        try routines.store(at: Routine.savePath)
    }
}


extension ContextManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Protocol conformance
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Protocol conformance
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Protocol conformance
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        objectWillChange.send() // reload views
    }
}
