
import SwiftUI
import Charts

struct WeightView: View {
    @EnvironmentObject var app: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                
                WeightChartView( entries: $app.weightChartEntries)
                
                Form {
                    DatePicker ("Enter Date", selection: $app.weightFormDate, displayedComponents: .date)
                    TextField("Enter Weight", text: $app.weightFormWeight)
                        .keyboardType(.decimalPad)
                    Button("Add weight") {app.weightForm();hideKeyboard()}
                        .frame(maxWidth: .infinity, alignment: .center)

                }
            }
            .navigationBarTitle("Weight", displayMode: .large)
            .alert(isPresented:$app.showingExistingWeightAlert) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Weight data for the date already exsists, do you want to replace it?"),
                    primaryButton: .destructive(Text("Yes"))
                    {app.uploadWeight(date: app.weightFormDate, weight: app.weightFormWeight)},
                    secondaryButton: .cancel()
                )}
        }.alert(isPresented: $app.showingEmptyWeightAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Please enter a valid weight value."),
                dismissButton: .default(Text("Got it!"))
            )}

    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct WeightView_Previews: PreviewProvider {
    static var previews: some View {
        WeightView()
    }
}
