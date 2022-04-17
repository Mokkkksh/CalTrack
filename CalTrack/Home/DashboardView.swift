import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var app: HomeViewModel
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Hi,")
                    Text(app.name).foregroundColor(.accentColor)
                }.font(.custom("Futura", size: 30))
                
                Text("Your current weight is: ").font(.custom("Futura", size: 25))
                
                HStack {
                    Text("\(app.currentWeight, specifier: "%.1f")").foregroundColor(.accentColor); Text("kilograms.")
                }.font(.custom("Futura", size: 25))
                
                HStack {
                    Text("Only")
                    Text("\(abs(app.currentWeight - app.targetWeight), specifier: "%.1f")")
                        .foregroundColor(.accentColor)
                    Text("kilograms to go.")
                }.font(.custom("Futura", size: 25))
                
                HStack {
                    Text("To reach your goal of: ")
                }.font(.custom("Futura", size: 20))
                
                HStack {
                    Text("\(app.targetWeight, specifier: "%.1f")").foregroundColor(.accentColor)
                    Text("kilograms in")
                    Text("\(app.calculatedDays)").foregroundColor(.accentColor)
                    Text("days.")
                }.font(.custom("Futura", size: 25))
                
                Spacer().frame( height: 20, alignment: .center)
                
                HStack{
                    Text("Total calories consumed: \("\(app.firebaseSummary["Total Calories"]!)")").foregroundColor(.accentColor)
                }.font(.custom("Futura", size: 25))
                HStack{
                    Text("Active minutes: \(app.calculateActiveMinutes())").foregroundColor(.accentColor)
                }.font(.custom("Futura", size: 25))
                
            }
            .navigationBarTitle("Dashboard")
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
