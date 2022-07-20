//
//  ContentView.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var context: ContextManager

    var body: some View {
        NavigationView {
            VStack {
                if context.routines.count > 0 {
                    routineListView
                } else {
                    VStack {
                        Text("No routines configured yet!")
                        NavigationLink("Add routine now", destination: RoutineBuilderView(completion: { routine in
                            context.routines.append(routine)
                            try? context.saveState()
                        }))
                    }
                }
            }
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if context.routines.count > 0 {
                    EditButton()
                }
            }
        }
    }

    var routineListView: some View {
        List {
            ForEach(context.routines, id: \.id) { routine in
                let (letter, label) = prettyLetter(label: routine.label)

                NavigationLink(destination: RoutineView(routine: routine)) {
                    HStack {
                        if let letter = letter {
                            Text(letter)
                                .font(.system(size: 30))
                                .padding(.trailing, 5)
                        }

                        VStack(alignment: .leading) {
                            Text(label)
                                .font(.headline)

                            Text("\(routine.exercises.count) exercises")
                        }
                    }
                }
            }
            .onDelete(perform: { indexSet in
                context.routines.remove(atOffsets: indexSet)
                try? context.saveState()

            })
            .onMove(perform: { from, to in
                context.routines.move(fromOffsets: from, toOffset: to)
                try? context.saveState()
            })

            NavigationLink(destination: RoutineBuilderView(completion: { routine in
                context.routines.append(routine)
                try? context.saveState()
            })) {
                Text("Add new routine")
                    .foregroundColor(.blue)
            }
        }
    }

    func prettyLetter(label: String) -> (letter: String?, label: String) {
        let suffix = label.suffix(3)
        guard suffix.count == 3 else { return (nil, label) }

        if suffix.first == "(" && suffix.last == ")" {
            let middleIndex = suffix.index(after: suffix.startIndex)
            let middleLetter = suffix[middleIndex]

            if middleLetter.isLetter {
                let newEndIndex = label.index(label.endIndex, offsetBy: -4)
                let newLabel = label[label.startIndex ... newEndIndex]

                return (String(middleLetter), String(newLabel))
            }

        }

        return (nil, label)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
