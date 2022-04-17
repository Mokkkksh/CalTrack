import SwiftUI
import Firebase
import Charts

struct MealTempelate: Identifiable, Hashable {
    
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let fat: Int
    let carbohydrates: Int
    
}

struct ExerciseTempelate: Identifiable, Hashable {
    
    let id = UUID()
    var name: String
    
}

class HomeViewModel: ObservableObject {
    
    @Published var name = String()
    @Published var currentWeight = Double()
    @Published var calculatedWeight = Double()
    @Published var targetWeight = Double()
    @Published var calculatedDays = Int()
    
    @Published var instructions = String()
    
    @Published var weightChartEntries = [ChartDataEntry]()
    @Published var sortedDateArray = [String]()
    @Published var sortedWeightArray = [Double]()
    @Published var weightFormDate = Date.init()
    @Published var weightFormWeight = ""
    
    @Published var showingEmptyWeightAlert = false
    @Published var showingExistingWeightAlert = false
    
    @Published var mealPresets = [MealTempelate]()
    @Published var userMealPresets = [MealTempelate]()
    @Published var currentMeals = [String]()
    @Published var selectedPreset = MealTempelate(name: "", calories: 0, protein: 0, fat: 0, carbohydrates: 0)
    
    @Published var firebaseSummary = ["Meals":[],
                                     "Total Calories": 0,
                                     "Total Fat": 0,
                                     "Total Protein": 0,
                                     "Total Carbohydrates": 0]
    
    @Published var deleteMealPresetAlert = false
    @Published var removeServingsAlert = false
    @Published var invalidPresetDataAlert = false
    
    @Published var mealInfoSheet = false
    @Published var customMealPreset = false
    
    @Published var exercisePresets = [ExerciseTempelate]()
    @Published var userPresets = [String]()
    @Published var selectedExercisePreset = ExerciseTempelate(name: "")
    @Published var summary = [String]()
    @Published var userExercisePresets = [ExerciseTempelate]()
    @Published var exerciseSummary = [String:Int]()
    
    @Published var removeDurationAlert = false
    
    
    let dashboardSummaryPath = Firestore.firestore().collection("customers").document(Auth.auth().currentUser!.uid)
    let weightSummaryPath = Firestore.firestore().collection("weightdata").document(Auth.auth().currentUser!.uid)
    let mealSummaryPath = Firestore.firestore().collection("mealdata").document(Auth.auth().currentUser!.uid)
    let mealPresetPath = Firestore.firestore().collection("mealdata").document("presets")
    let exerciseSummaryPath = Firestore.firestore().collection("exercisedata").document(Auth.auth().currentUser!.uid)
    let exercisePresetPath = Firestore.firestore().collection("exercisedata").document("presets")
    
    func getDashboard() {
        
        dashboardSummaryPath.addSnapshotListener { [self] document, error in
            
            name = document!.data()!["firstname"] as! String
            targetWeight = document!.data()!["targetweight"] as! Double
            calculatedDays = Calendar.current.dateComponents([.day], from: Date.init(),
                to: stringToDate(string: document!.data()!["enddate"] as! String)).day!
            instructions = document!.data()!["instructions"] as? String ?? ""
            
        }
    }
    
    func getweightChartEntries() {
        
        weightSummaryPath.addSnapshotListener { [self] document, error in
            var entries = [ChartDataEntry]()
            var array = [String]()
            var weightarray = [Double]()
            let weightData = document?.data()
            if weightData != nil {
                
                for date in document!.data()!.keys {array.append(date)}
                array.sort(by: <)
                sortedDateArray = array
                for x in 0..<sortedDateArray.count {
                    weightarray.append(weightData![sortedDateArray[x]] as! Double)
                    entries.append(ChartDataEntry(x: Double(x), y:weightarray[x]))
                }
                currentWeight = weightData![sortedDateArray.last!] as? Double ?? 0
            }
            else {currentWeight = 0}
            weightChartEntries = entries
        }
        calculatedWeight = abs(currentWeight - targetWeight)
    }
    
    func weightForm() {

        if isValidFloat(input: weightFormWeight).valid == false {showingEmptyWeightAlert.toggle()}
        
        else {
            let weight = isValidFloat(input: weightFormWeight).output
            let date = dateToString(date: weightFormDate)
            weightSummaryPath.getDocument { document, error in
                if document?.data()?[date] != nil {self.showingExistingWeightAlert.toggle()}
                else {self.weightSummaryPath.setData([date:weight], merge: true)}
            }
        }
    }
    
    func uploadWeight(date: Date, weight: String) {
    
        let weight = isValidFloat(input: weightFormWeight).output
        let date = dateToString(date: weightFormDate)
        weightSummaryPath.setData([date:weight], merge: true)
    }
    
    func uploadInstructions() {
        dashboardSummaryPath.setData(["instructions":instructions], merge: true)
    }
    
    func getMealPresets() {
        
        mealPresetPath.getDocument { document, error in
            var entries = [MealTempelate]()
            for (key, info) in document!.data()! {
                
                let result = info as! [String:Int]
                entries.append(MealTempelate(name: key,
                                             calories: result["Calories"]!,
                                             protein: result["Protein"]!,
                                             fat: result["Fat"]!,
                                             carbohydrates: result["Carbohydrates"]!))
            }
            self.mealPresets = entries
        }
    }
    
    func getUserMealPresets() {
        
        mealSummaryPath.addSnapshotListener { document, error in
            let data = document?.data()?["User Presets"]
            let result = data as? [String: Any]
            if result != nil {
                var entries = [MealTempelate]()
                for (key, info) in result! {
                    let result = info as! [String:Int]
                    entries.append(MealTempelate(name: key,
                                                 calories: result["Calories"]!,
                                                 protein: result["Protein"]!,
                                                 fat: result["Fat"]!,
                                                 carbohydrates: result["Carbohydrates"]!))
                }
                self.userMealPresets = entries
            }
        }
    }
    
    func populateFirebaseSummary() {
        
        mealSummaryPath.getDocument { [self] (document, error) in
            
            let date = dateToString(date: Date.init())
            let result = document!.data()![date]
            if result == nil
            {mealSummaryPath.setData([date: firebaseSummary], merge: true)}
            else {firebaseSummary = result as! [String : Any]}
            currentMeals = firebaseSummary["Meals"]! as! [String]
            
        }
    }

    func deleteMealPreset() {
        var result = [String: Any]()
        mealSummaryPath.getDocument { document, error in
            result = document?.data()?["User Presets"] as! [String : Any]
            result.removeValue(forKey: self.selectedPreset.name)
            print(result)
            self.mealSummaryPath.updateData(["User Presets":result])
        }
        print(result)
        
    }
    
    func calculateServings(current:String) -> Int {
        
        var counter = 0
        for temp in currentMeals {if current == temp {counter += 1}}
        return counter
        
    }
    
    func updateSummary(result: MealTempelate, add:Bool) {
        
        
        let calories = result.calories
        let fat = result.fat
        let protein = result.protein
        let carbohydrates = result.carbohydrates
        
        let tempcalories = firebaseSummary["Total Calories"] as! Int
        let tempfat = firebaseSummary["Total Fat"] as! Int
        let tempprotein = firebaseSummary["Total Protein"] as! Int
        let tempcarbohydrates = firebaseSummary["Total Carbohydrates"] as! Int
        
        if add == true {
        
            currentMeals.append(result.name)
            firebaseSummary["Total Calories"] = calories + tempcalories
            firebaseSummary["Total Fat"] = fat + tempfat
            firebaseSummary["Total Protein"] = protein + tempprotein
            firebaseSummary["Total Carbohydrates"] = carbohydrates + tempcarbohydrates

            
        }
        
        if add == false {
            
            let servings = calculateServings(current: result.name)
            if servings == 0 {removeServingsAlert = true}
            
            else {
                
                if let index = currentMeals.firstIndex(of: result.name)
                {currentMeals.remove(at: index)}
        
                firebaseSummary["Total Calories"] = tempcalories - calories
                firebaseSummary["Total Fat"] = tempfat - fat
                firebaseSummary["Total Protein"] = tempprotein - protein
                firebaseSummary["Total Carbohydrates"] = tempcarbohydrates - carbohydrates
                
            }
            
        }
        
        let date = dateToString(date: Date.init())
        firebaseSummary["Meals"] = currentMeals
        mealSummaryPath.setData([date:firebaseSummary], merge: true)
        
    }
    
    func getExercisePresets() {
        exercisePresetPath.getDocument { document, error in
            for x in document?.data()?["presets"] as? [String] ?? [] {
                self.exercisePresets.append(ExerciseTempelate(name: x))
            }
        }
    }
    
    func getUserExerciseData() {
        let date = dateToString(date: Date.init())
        let nilSummary = [String:Int]()
        exerciseSummaryPath.addSnapshotListener { [self] document, error in
            var temp = [ExerciseTempelate]()
            self.userPresets = document?.data()?["User Presets"] as? [String] ?? []
            if userPresets != [""]{for x in userPresets {temp.append(ExerciseTempelate(name: x))}}
            let result = document?.data()?[date]
            if result == nil {exerciseSummaryPath.setData([date:nilSummary], merge:true)}
            else {exerciseSummary = result as! [String:Int]}
            self.userExercisePresets = temp
            
            var temps = [String]()
            for x in exerciseSummary.keys {temps.append(x)}
            summary = temps
            summary.sort(by: <)
        }
        
    }
    
    func calculateSummary(result:ExerciseTempelate, mins:Int, add:Bool) {
        let date = dateToString(date: Date.init())
        let duration = exerciseSummary[result.name] ?? 0
        if add == true {exerciseSummary[result.name] = duration + mins}
        if add == false {
            if duration - mins < 1 {exerciseSummary[result.name] = 0 ;exerciseSummary.removeValue(forKey: result.name);
                exerciseSummaryPath.updateData([date:exerciseSummary])}
            else {exerciseSummary[result.name] = duration - mins}
        }
        
        exerciseSummaryPath.setData([date:exerciseSummary], merge:true)

    }
    
    func deleteExercisePreset() {
        if let index = userPresets.firstIndex(of: selectedExercisePreset.name) {userPresets.remove(at: index)}
        if userPresets.isEmpty {exerciseSummaryPath.updateData(["User Presets":FieldValue.delete()])}
        exerciseSummaryPath.updateData(["User Presets":userPresets])
    }
    
    func calculateActiveMinutes() -> Int {
        var duration = 0
        for names in exerciseSummary.keys {duration += exerciseSummary[names] ?? 0}
        return duration
    }
}
