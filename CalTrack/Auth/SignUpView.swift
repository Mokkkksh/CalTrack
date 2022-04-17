import SwiftUI
import Firebase

struct SignUpView: View {
    @EnvironmentObject var signUp: AuthViewModel
    @State var formErrorAlert = false
    @State var errorDescription = String()
    var body: some View {
        Form {
            
            Section {
                TextField("First Name", text: $signUp.formFirstName)
                TextField("Last Name", text: $signUp.formLastName)
            }.disableAutocorrection(true)
            
            Section {
                TextField("Target Weight", text: $signUp.formTargetWeight)
                TextField("Height", text: $signUp.formHeight)
            }.keyboardType(.numberPad)
            
            Section {
                DatePicker ("Date of birth", selection: $signUp.formBirthDate, displayedComponents: .date)
                DatePicker ("Target date for goal", selection: $signUp.formEndDate, displayedComponents: .date)
                Picker(selection: $signUp.SelectedDietaryPreference, label: Text("Dietary Preference"))
                    {ForEach(0 ..< signUp.DietaryPreferenceArray.count) {Text(signUp.DietaryPreferenceArray[$0])}}
            }.foregroundColor(.gray)
            
            Section {
                TextField("Email Address", text: $signUp.formEmail)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                TextField("Mobile number", text: $signUp.formPhoneNo)
                    .keyboardType(.numberPad)
                SecureField("Create Password", text: $signUp.formCreatePass)
                SecureField("Confirm Password", text: $signUp.formPass)
            }
            
            Button { errorDescription = signUp.validateFormFields()
                if errorDescription != "noerror" {formErrorAlert.toggle()}
                else{signUp.firebaseSignUp()}
            }
                label: { Text("Submit")
                    .font(.custom("Futura", size: 20))
                    .fontWeight(.thin)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                    .cornerRadius(20.0)
                    .aspectRatio(contentMode:.fill)
            }
        }
        .font(.custom("Futura", size: 17))
        .navigationBarTitle("Create Profile")
        .alert(isPresented: $formErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorDescription),
                dismissButton: .default(Text("Got it!"))
            )}
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

