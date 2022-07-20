//
//  ViewContext.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 18/07/22.
//

import SwiftUI
import WatchConnectivity

class ViewContext: ObservableObject {
    var session: WCSession
    private var delegate: WatchContextDelegate? = nil

    init(routine: Routine? = nil, routineStartTime: Date? = nil, routineEndTime: Date? = nil, currentExercise: Routine.Exercise? = nil, currentPage: ViewContext.Page) {
        self.routine = routine
        self.routineStartTime = routineStartTime
        self.routineEndTime = routineEndTime
        self.currentExercise = currentExercise
        self.currentPage = currentPage

        self.session = WCSession.default
        self.delegate = WatchContextDelegate()

        connect()
    }

    func connect() {
        delegate?.viewContext = self
        session.delegate = delegate
        session.activate()
    }

    enum Page {
        case awaitActivation

        case firstPickView

        case exerciseView
        case restView

        case exercisePickView
        case finishedView
    }

    @Published var routine: Routine?
    var routineStartTime: Date?
    var routineEndTime: Date?

    @Published var currentExercise: Routine.Exercise?
    @Published var currentPage: Page

}


fileprivate class WatchContextDelegate: NSObject, WCSessionDelegate {
    weak var viewContext: ViewContext? = nil

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("recieved message")

        if let request = message["activationRequest"] as? String, request == "routine" {
            print("recieved activation request")

            guard let routineData = message["routineInfo"] as? Data, let startTime = message["startTime"] as? Date else {
                print("unable to load info/time")
                return }
            guard let routineInfo = try? JSONDecoder().decode(Routine.self, from: routineData) else {
                print("unable to decode routine")
                return }

            DispatchQueue.main.async { [weak self] in
                self?.viewContext?.routine = routineInfo
                self?.viewContext?.routineStartTime = startTime

                withAnimation {
                    self?.viewContext?.currentPage = .firstPickView
                }
            }

            print("loaded routine!")
        }
    }
}
