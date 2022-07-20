//
//  ContentView.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI
import WatchKit


struct ContentView: View {
    @StateObject var context: ViewContext = .init(currentPage: .awaitActivation)

    var body: some View {
        VStack {
            switch context.currentPage {

            case .awaitActivation:
                ActivateView()

            case .firstPickView:
                ExercisePickerView(isFirstPick: true)

            case .exerciseView:
                MultipageContainerView(page: ExerciseInfoView())

            case .exercisePickView:
                ExercisePickerView()

            case .restView:
                MultipageContainerView(page: RestView())

            case .finishedView:
                FinishedView()

            }
        }
        .environmentObject(context)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
