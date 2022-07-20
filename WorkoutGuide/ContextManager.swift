//
//  ContextManager.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 20/07/22.
//

import Foundation
import WatchConnectivity

class ContextManager: NSObject, ObservableObject {

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
}
