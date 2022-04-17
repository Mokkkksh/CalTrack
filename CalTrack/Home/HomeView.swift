import SwiftUI

struct HomeView: View {
    @State var home = HomeViewModel()
    @State var selectedTab = "dashboard"
    var body: some View {
        TabView(selection: $selectedTab) {
            
            ProfileView().tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }.tag("profile")
            
            WeightView().tabItem {
                Image(systemName: "scalemass.fill")
                Text("Weight")
            }.tag("weight")
            
            DashboardView().tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }.tag("dashboard")
            
            MealView().tabItem {
                Image(systemName: "chart.pie")
                Text("Meals")
            }.tag("meal")
            
            ExerciseView().tabItem {
                Image(systemName: "sportscourt")
                Text("Exercise")
            }.tag("exercise")
        }.environmentObject(home)
        .onAppear {
        
            home.getDashboard()
            home.getweightChartEntries()
            home.getMealPresets()
            home.getUserMealPresets()
            home.populateFirebaseSummary()
            home.getExercisePresets()
            home.getUserExerciseData()
        
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
