//
//  RoutineBuilderView.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI

fileprivate struct _BuilderExercise: Identifiable, Equatable {
    let id = UUID()

    var name: String = ""
    var weight: Int?
    var notes: String = ""
    var configuration: Routine.Configuration?
}

struct RoutineBuilderView: View {
    @Environment(\.dismiss) var dismiss

    var completion: (Routine) -> ()
    @State var routine: Routine
    private var isEdit: Bool


    init(routine: Routine? = nil, completion: @escaping (Routine) -> (), isEdit: Bool = false) {
        self.completion = completion
        self.isEdit = isEdit


        guard let routine = routine else {
            self._routine = .init(wrappedValue: Routine(label: "", exercises: [], defaultConfiguration: .init(repetitions: 0, sets: 0, restInterval: 70)))
            self._dataStore = .init(wrappedValue: (label: "", configuration: Routine.Configuration(repetitions: 0, sets: 0, restInterval: 70)))
            self._exercises = .init(wrappedValue: [])
            return
        }

        self._routine = .init(wrappedValue: routine)
        let dataStore = (label: routine.label, configuration: Routine.Configuration(repetitions: -1, sets: -1, restInterval: 0))
        self._dataStore = .init(wrappedValue: dataStore)


        let exercises = routine.exercises.map {
            _BuilderExercise(name: $0.name, weight: $0.weight, notes: $0.notes, configuration: $0.configuration)
        }
        self._exercises = .init(wrappedValue: exercises)

    }

    @State private var exercises: [_BuilderExercise]
    @State private var dataStore: (label: String, configuration: Routine.Configuration)

    @State private var showError: Bool = false
    @State private var errorMessage: String = "Unknown error"

    var body: some View {
        Form {
            Section {
                TextField("Routine label", text: $dataStore.label)
            }

            Section {
                RepConfigurationView(configuration: $dataStore.configuration)
            }

            Section {
                ForEach($exercises, id: \.id) { exercise in
                    ExerciseConfigurationView(parent: self, exercise: exercise)
                }

                Button(action: {
                    withAnimation {
                        exercises.append(_BuilderExercise())
                    }
                }) {
                    Text("Add exercise")
                }
            }

            Section {
                Button(action: save) {
                    Text("Save")
                        .bold()
                }

                Button(action: dismiss.callAsFunction) {
                    Text("Discard \(isEdit ? "changes" : "routine")")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Build routine")
        .navigationBarBackButtonHidden(true)
        .onChange(of: dataStore.label) { routine.label = $0 }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("Dismiss")))
        }
    }

    fileprivate func removeExercise(exercise: _BuilderExercise) {
        if let index = exercises.firstIndex(of: exercise) {
            exercises.remove(at: index)
        }
    }

    func save() {
        // must have valid label, set, and repetition
        if routine.label.isEmpty {
            errorMessage = "Routine must have a name"
            showError = true
            return
        }

        if dataStore.configuration.sets == 0 || dataStore.configuration.repetitions == 0 {
            errorMessage = "Default repetitions and sets must be a non-zero number"
            showError = true
            return
        }

        // ignore exercises without a name
        let exercises = exercises.filter { !$0.name.isEmpty }
        if exercises.count == 0 {
            errorMessage = "Routine must have at least one exercise"
            showError = true
            return
        }

        // build exercise list
        routine.exercises = exercises.map { e -> Routine.Exercise in
            var configuration = dataStore.configuration

            if let customConfig = e.configuration, customConfig.sets != 0 && customConfig.repetitions != 0 {
                configuration = customConfig
            }

            return Routine.Exercise(name: e.name, weight: e.weight, configuration: configuration, notes: e.notes)
        }

        completion(routine)
        dismiss()
    }
}


struct ExerciseConfigurationView: View {
    var parent: RoutineBuilderView
    @Binding fileprivate var exercise: _BuilderExercise
    @State var name: String = ""

    fileprivate init(parent: RoutineBuilderView, exercise: Binding<_BuilderExercise>) {
        self.parent = parent

        self._exercise = exercise
        self._name = .init(wrappedValue: exercise.name.wrappedValue)
    }


    var body: some View {
        NavigationLink(destination: ExerciseConfigurationDetailView(parent: parent, exercise: $exercise, name: $name)) {
            TextField("Exercise", text: $name)
        }
        .onChange(of: name) { exercise.name = $0 }

    }
}

struct ExerciseConfigurationDetailView: View {
    @Environment(\.dismiss) var dismiss
    var parent: RoutineBuilderView

    @Binding fileprivate var exercise: _BuilderExercise
    @Binding var name: String

    @State private var dataStore = (weight: "", notes: "", reps: Routine.Configuration(repetitions: 0, sets: 0, restInterval: 70))
    @State private var overrideSetDefaults: Bool = false

    fileprivate init(parent: RoutineBuilderView, exercise: Binding<_BuilderExercise>, name: Binding<String>) {
        self.parent = parent
        self._exercise = exercise
        self._name = name

        var weightString: String = ""
        if let weight = exercise.weight.wrappedValue {
            weightString = String(weight)
        }

        self._dataStore = .init(wrappedValue: (weight: weightString, notes: exercise.notes.wrappedValue, reps: exercise.configuration.wrappedValue ?? Routine.Configuration(repetitions: 0, sets: 0, restInterval: 70)))


    }

    var body: some View {
        Group {
            Form {
                Section {
                    TextField("Exercise name", text: $name)

                    HStack {
                        TextField("Weight", text: $dataStore.weight)
                        Text("kg")
                    }
                }


                Section(header: Text("Sets")) {
                    Toggle("Custom sets", isOn: $overrideSetDefaults)
                    RepConfigurationView(configuration: $dataStore.reps)
                        .disabled(!overrideSetDefaults)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $dataStore.notes)
                }

                Section {
                    Button(action: {
                        dismiss()
                        parent.removeExercise(exercise: exercise)
                    }) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Exercise details")
        }
        .onChange(of: dataStore.weight) { weightString in
            let weight = Int(weightString)
            if weight == nil { dataStore.weight = "" }
            exercise.weight = weight
        }
        .onChange(of: dataStore.notes) { exercise.notes = $0 }
        .onChange(of: dataStore.reps) {
            if overrideSetDefaults {
                exercise.configuration = $0
            } else {
                exercise.configuration = nil
            }
        }
        .onChange(of: overrideSetDefaults) { _ in
            if overrideSetDefaults {
                exercise.configuration = dataStore.reps
            } else {
                exercise.configuration = nil
            }
        }
    }
}

struct RepConfigurationView: View {
    @Binding var configuration: Routine.Configuration
    @State var dataStore: (sets: String, reps: String, restMinutes: Int, restSeconds: Int)

    init(configuration: Binding<Routine.Configuration>) {
        self._configuration = configuration


        // setup data store
        var dataStore = (sets: "", reps: "", restMinutes: 0, restSeconds: 0)
        if configuration.wrappedValue.sets != 0 {
            dataStore.sets = String(configuration.wrappedValue.sets)
        }

        if configuration.wrappedValue.repetitions != 0 {
            dataStore.reps = String(configuration.wrappedValue.repetitions)
        }

        dataStore.restMinutes = (configuration.wrappedValue.restInterval % 3600) / 60
        dataStore.restSeconds = (configuration.wrappedValue.restInterval % 60) / 5 // (5 second increments)

        self.dataStore = dataStore
    }

    var body: some View {
        HStack {
            Text("Sets:")
            TextField("Number of sets", text: $dataStore.sets)
                .keyboardType(.numberPad)
        }

        HStack {
            Text("Reps:")

            TextField("Number of reps", text: $dataStore.reps)
                .keyboardType(.numberPad)
        }

        HStack {
            Text("Rest:")

            Picker("Minutes", selection: $dataStore.restMinutes) {
                ForEach(0..<6) { index in
                    Text("\(index) min")
                }
            }
            .pickerStyle(MenuPickerStyle())

            Picker("Seconds", selection: $dataStore.restSeconds) {
                ForEach(0..<13) { index in
                    Text("\(index * 5) sec")
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .onChange(of: dataStore.sets) { string in
            guard let sets = Int(string) else {
                dataStore.sets = ""
                configuration.sets = 0
                return
            }
            configuration.sets = sets
        }
        .onChange(of: dataStore.reps) { string in
            guard let reps = Int(string) else {
                dataStore.reps = ""
                configuration.repetitions = 0
                return
            }

            configuration.repetitions = reps
        }
        .onChange(of: dataStore.restMinutes) { _ in
            configuration.restInterval = (dataStore.restMinutes * 60) + (dataStore.restSeconds * 5)
        }
        .onChange(of: dataStore.restSeconds) { _ in
            configuration.restInterval = (dataStore.restMinutes * 60) + (dataStore.restSeconds * 5)
        }
    }
}
