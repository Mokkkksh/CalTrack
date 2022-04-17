import SwiftUI

struct LogInView: View {
    @EnvironmentObject var logIn: AuthViewModel
    @State var logInErrorAlert = false
    var body: some View {
     Form   {
            Section {
                TextField("Email Address", text: $logIn.formEmail)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                SecureField("Password", text: $logIn.formPass)
            }.font(.custom("Futura", size: 17))
        
        Button {
            if logIn.logInError != "" {logInErrorAlert.toggle()}
            else {logIn.firebaseSignIn()}
        }
                label: { Text("Submit")
                    .font(.custom("Futura", size: 20))
                    .fontWeight(.thin)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                    .cornerRadius(20.0)
                    .aspectRatio(contentMode:.fill)
                }
        }
     .navigationTitle("Log In")
     .alert(isPresented: $logInErrorAlert) {
         Alert(
             title: Text("Error"),
            message: Text(logIn.logInError),
             dismissButton: .default(Text("Got it!"))
         )}
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
