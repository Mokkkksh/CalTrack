
import SwiftUI

struct ExerciseView: View {
    @EnvironmentObject var app: HomeViewModel
    @State var searchText = ""
    @State var customDurationSheet = false
    @State var customPresetSheet = false
    @State var deletePresetAlert = false
 
    
    var body: some View {
        
        NavigationView{
            List {
                
                HStack {
                    TextField ("Search for exercise",text: $searchText)
                        .padding(.leading, 24)
                }
                .padding()
                .background(Color.secondary)
                .cornerRadius(6)
                .padding(.horizontal)
                .overlay( HStack { Image(systemName: "magnifyingglass"); Spacer()}
                            .padding(.horizontal, 32).foregroundColor(.gray))
                
                ForEach(app.exercisePresets.filter({"\($0)".contains(searchText) || searchText.isEmpty}), id:\.self) { result in
                    HStack {
                    Text("\(result.name)")
                    Spacer()
                        Button{app.calculateSummary(result: result, mins: 10, add: true)}
                            label: {Text("+10")}
                        Button{app.calculateSummary(result: result, mins: 10, add: false)}
                            label: {Text("-10")}
                        Button{app.selectedExercisePreset = result; customDurationSheet = true; } label: {Text("duration")}
                    
                    }
                    
                }
                
                ForEach(app.userExercisePresets.filter({"\($0)".contains(searchText) || searchText.isEmpty}), id:\.self) { result in
                    HStack {
                    Text("\(result.name)")
                    Spacer()
                        Button{app.calculateSummary(result: result, mins: 10, add: true)}
                            label: {Text("+10")}
                        Button{app.calculateSummary(result: result, mins: 10, add: false)}
                            label: {Text("-10")}
                        Button{app.selectedExercisePreset = result; customDurationSheet = true; } label: {Text("duration")}
                        Button {app.selectedExercisePreset = result; deletePresetAlert = true} label: {Text("Delete")}
                    }
                    
                }
                
                Text("Today's summary")
                
                ForEach(app.summary, id: \.self){ result in
                    Text("\(result): \(app.exerciseSummary[result] ?? 0) mins")
                }
                    
                
                Text("Active minutes: \(app.calculateActiveMinutes())").foregroundColor(.accentColor)
                Button {customPresetSheet = true} label: {Text("Add your preset")}
                
            
            } .navigationBarTitle("Exercise")
            .navigationBarBackButtonHidden(true)
            .buttonStyle(BorderlessButtonStyle())
            .sheet(isPresented: $customPresetSheet) { ExercisePresetSheet() }
            .sheet(isPresented: $customDurationSheet) {CustomDurationSheet()}
            .alert(isPresented: $deletePresetAlert) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Are you sure you want to delete this preset?"),
                    primaryButton: .destructive(Text("Yes")) {app.deleteExercisePreset()},
                    secondaryButton: .cancel())}
        }
    }
}

struct ExercisePresetSheet: View {
    @EnvironmentObject var app: HomeViewModel
    @State var name: String = ""
    
    var body: some View {
        Form {
            TextField("Enter Exercise name", text: $name)
                Button {
                    if name != "" {
                    app.userPresets.append(name)
                        app.exerciseSummaryPath.setData(["User Presets":app.userPresets], merge: true)}
                } label: {Text("Add Preset")}
            
            
            }
    }
}

struct CustomDurationSheet: View {
    @EnvironmentObject var app: HomeViewModel
    @State var duration: String = ""
    @State var invalidDurationAlert = false
    
    var body: some View {
        Form {
            TextField("Enter duration in minutes", text: $duration).keyboardType(.numberPad)
            Button {
                let intDuration = Int(duration) ?? 0
                if intDuration == 0  {invalidDurationAlert = true}
                else{app.calculateSummary(result: app.selectedExercisePreset, mins: intDuration, add: true)}
                
            } label: {Text("Add duration")}
            
            Button {
                let intDuration = Int(duration) ?? 0
                if intDuration == 0  {invalidDurationAlert = true}
                else{app.calculateSummary(result: app.selectedExercisePreset, mins: intDuration, add: false)}
                
            } label: {Text("Remove duration")}

        }.alert(isPresented: $invalidDurationAlert) {
            Alert(title: Text("Error"),
                  message: Text("Please enter a valid duration"),
                  dismissButton: .cancel())
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}
