//
//  ContentView.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI

struct ContentView: View {
    @State var routines = [Routine].load(from: Routine.savePath) ?? []

    var body: some View {
        NavigationView {
            VStack {
                if routines.count > 0 {
                    List {
                        ForEach(routines, id: \.id) { routine in
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
                            routines.remove(atOffsets: indexSet)
                            try? routines.store(at: Routine.savePath)

                        })
                        .onMove(perform: { from, to in
                            routines.move(fromOffsets: from, toOffset: to)
                        })

                        NavigationLink(destination: RoutineBuilderView(completion: { routine in
                            routines.append(routine)
                            print(try? routines.store(at: Routine.savePath))
                            routine.debugPrint()
                        })) {
                            Text("Add new routine")
                                .foregroundColor(.blue)
//                            Image(systemName: "plus")
                        }
                    }
                } else {
                    VStack {
                        Text("No routines configured yet!")
                        NavigationLink("Add routine now", destination: RoutineBuilderView(completion: { routine in
                            routines.append(routine)
                            print(try? routines.store(at: Routine.savePath))
                            routine.debugPrint()
                        }))
                    }
                }
            }
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if routines.count > 0 {
                    EditButton()
                }
            }
        }
    }

    func prettyLetter(label: String) -> (letter: String?, label: String) {
        let suffix = label.suffix(3)
        guard suffix.count == 3 else { return (nil, label) }

        if suffix.first == "(" && suffix.last == ")" {
            let middleIndex = suffix.index(after: suffix.startIndex)

            if suffix[middleIndex].isLetter {
                let letter = String(suffix[middleIndex])

                let newEndIndex = label.index(label.endIndex, offsetBy: -4)
                let newLabel = label[label.startIndex ... newEndIndex]

                return (letter, String(newLabel))
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
