import SwiftUI
import Firebase

struct MealView: View {
    
    @EnvironmentObject var app: HomeViewModel
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                HStack{
                    TextField("Search for meal", text: $searchText)
                        .padding(.leading, 24)
                }
                .padding()
                .background(Color.secondary)
                .cornerRadius(6)
                .padding(.horizontal)
                .overlay(HStack{
                    Image(systemName: "magnifyingglass")
                    Spacer()
                }
                .padding(.horizontal, 32)
                .foregroundColor(.gray)
                )
                
                Text("Server Presets").font(.custom("Futura", size: 20))
                ForEach (app.mealPresets.filter({"\($0)".contains(searchText) || searchText.isEmpty}), id:\.self) {result in
                    HStack {
                        VStack(alignment: .leading) {
                            let servings = app.calculateServings(current: result.name)
                            Text("\(result.name)")
                                .font(.custom("Futura", size: 20))
                            Text("Servings consumed: \(servings)")
                                .font(.custom("Futura", size: 15))
                         
                        }
                        Spacer()
                        
                        Button {app.updateSummary(result: result, add: true)}
                            label: {Text("+")}
                        Button {app.updateSummary(result: result, add: false)}
                            label: {Text("-")}
                        Button {app.selectedPreset = result;
                            app.mealInfoSheet = true}
                            label: {Text("i")}

                    }
                    
                }.buttonStyle(BorderlessButtonStyle())
                
                Text("Your Presets").font(.custom("Futura", size: 20))
                ForEach(app.userMealPresets.filter({"\($0)".contains(searchText) || searchText.isEmpty})) {result in
                    
                    HStack {
                        VStack(alignment: .leading) {
                            
                            let servings = app.calculateServings(current: result.name)
                            Text("\(result.name)")
                                .font(.custom("Futura", size: 20))
                            
                            Text("Servings consumed: \(servings)")
                                .font(.custom("Futura", size: 15))
                        }
                        
                        Spacer()
                        
                        Button {app.updateSummary(result: result, add: true)}
                            label: {Text("+")}
                        Button {app.updateSummary(result: result, add: false)}
                            label: {Text("-")}
                        Button {app.selectedPreset = result;
                            app.mealInfoSheet = true}
                            label: {Text("i")}
                        Button {app.selectedPreset = result; app.deleteMealPresetAlert = true} label: {Text("Delete Preset")}
                    }
                }.buttonStyle(BorderlessButtonStyle())
                .alert(isPresented: $app.deleteMealPresetAlert) {
                    Alert(
                        title: Text("Warning"),
                        message: Text("Are you sure you want to delete this preset?"),
                        primaryButton: .destructive(Text("Yes")) {self.app.deleteMealPreset()},
                        secondaryButton: .cancel()
                    
                    )
                }
                
                
                
                Button {app.customMealPreset = true} label: {Text("Add your own preset")}

                Group {
                Text("Today's summary").fontWeight(.bold).padding()
                let ccc = app.firebaseSummary["Total Calories"]
                let temp = "Total Calories: \(ccc ?? 0)"
                Text(temp)
                let protein = app.firebaseSummary["Total Protein"]
                let temp1 = "Total Protein: \(protein ?? 0)"
                Text(temp1)
                let carb = app.firebaseSummary["Total Carbohydrates"]
                let temp2 = "Total Carbohydrates: \(carb ?? 0)"
                Text(temp2)
                let fat = app.firebaseSummary["Total Fat"]
                let temp3 = "Total Fat: \(fat ?? 0)"
                Text(temp3)
                }
            }.sheet(isPresented: $app.mealInfoSheet) {MealInfoView(data: $app.selectedPreset)}
            .sheet(isPresented: $app.customMealPreset) {CustomPresetView()}
            .alert(isPresented: $app.removeServingsAlert){
                Alert(title: Text("Error"),
                      message: Text("No servings consumed!"),
                      dismissButton: .default(Text("Got it!"))
            )}
            .navigationBarTitle("Meals", displayMode: .large)
            .navigationBarBackButtonHidden(true)
        }
       
        
    
    }
}


struct MealInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var data: MealTempelate
    
    var body: some View {
        
        VStack(alignment: .trailing) {
            
        
            
            Text("Meal name: \(data.name)").font(.custom("Futura", size: 20))
            Text("Calories: \(data.calories)").font(.custom("Futura", size: 20))
            Text("Fat Content: \(data.fat)").font(.custom("Futura", size: 20))
            Text("Protein Content: \(data.protein)").font(.custom("Futura", size: 20))
            Text("Carbohydrate content: \(data.carbohydrates)").font(.custom("Futura", size: 20))
            
        }
    }
}

struct CustomPresetView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var app: HomeViewModel
    
    @State var userPresetName = ""
    @State var  userPresetCalories = ""
    @State var userPresetProtein  = ""
    @State var  userPresetCarbohydrates = ""
    @State var  userPresetFat = ""
    
    @State var presets = [String:Any]()
    
    var body: some View {
        
        Form {
            TextField("Enter Custom meal name", text: $userPresetName)
            TextField("Enter calorie content", text: $userPresetCalories).keyboardType(.numberPad)
            TextField("Enter protein content", text: $userPresetProtein).keyboardType(.numberPad)
            TextField("Enter carbohydrate content", text: $userPresetCarbohydrates).keyboardType(.numberPad)
            TextField("Enter fat content", text: $userPresetFat).keyboardType(.numberPad)
            
            
            Button {
                
                let calories = Int(userPresetCalories) ?? 0
                let carbohydrates = Int(userPresetCarbohydrates) ?? 0
                let fat = Int(userPresetProtein) ?? 0
                let protein = Int(userPresetFat) ?? 0
                
                if userPresetName == ""
                || calories == 0 || calories < 0 || calories > 9999
                || carbohydrates == 0 || carbohydrates < 0 || carbohydrates > 9999
                || fat == 0 || fat < 0 || fat > 9999
                || protein == 0 || protein < 0 || protein > 9999 {app.invalidPresetDataAlert = true}

                else {
                presets[userPresetName] =
                    
                    ["Calories": calories,
                     "Carbohydrates": carbohydrates,
                     "Fat": fat,
                     "Protein": protein]
               
                
                app.mealSummaryPath.setData(["User Presets":presets], merge: true)
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {Text("Add Data")}

            
        }.alert(isPresented: $app.invalidPresetDataAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Please enter a valid value."),
                dismissButton: .default(Text("Got it!"))
            )}
        
    }
}


struct MealView_Previews: PreviewProvider {
    static var previews: some View {
        MealView()
    }
}
