import SwiftUI
import Firebase

class AuthViewModel: ObservableObject {
    
    @Published var isUserAuthenticated: FBAuthState = .undefined
    @Published var formFirstName = ""
    @Published var formLastName = ""
    
    @Published var formTargetWeight = ""
    @Published var formHeight = ""
    
    @Published var formBirthDate = Date()
    @Published var formEndDate = Date()
    @Published var SelectedDietaryPreference = 0
    @Published var DietaryPreferenceArray = ["Vegetarian", "Non vegetarian", "Vegan", "Jain", "Gluten Free"]
    @Published var formDietaryPreference = ""
    
    @Published var formEmail = ""
    @Published var formPhoneNo = ""
    @Published var formCreatePass = ""
    @Published var formPass = ""
    
    @Published var logInError = ""
    
    enum FBAuthState { case undefined, signedOut, signedIn }
    
    func validateFormFields() -> String {
        
        if formFirstName == "" ||
            formLastName == "" ||
            
            formEmail == "" ||
            formPhoneNo == "" ||
            formCreatePass == "" ||
            formPass == "" {return "Please fill out all the fields"}
        
        if isValidInt(input: formTargetWeight).valid == false {
            return "Please enter a valid weight."}
        if isValidInt(input: formHeight).valid == false {
            return "Please enter a valid height."}
        if isValidDate(input: formBirthDate).valid == false {
            return "Please enter a valid date of birth."}
        if isValidDate(input: formEndDate).valid == false {
            return "Please enter a valid target date."}
        if isValidEmail(email: formEmail) == false {
            return "Please enter valid email"}
        if isValidPhoneNo(phoneNo: formPhoneNo) == false {
            return "Please enter a valid phone number"}
        if isValidPass(password: formPass) == false {
            return "Please make sure your password has at least 8 characters, a number, and a special character such as !?"}
        if formCreatePass != formPass {
            return "Please make sure your passwords match"}
        
        return "noerror"
        
    }
    
    func firebaseSignUp() {
        Auth.auth().createUser(withEmail: formEmail, password: formPass) { [self] result, error in
            self.formDietaryPreference = DietaryPreferenceArray[SelectedDietaryPreference]
            
            if error != nil {print("Error creating user, please try again")}
            else {
                Firestore.firestore().collection("customers").document(result!.user.uid)
                    .setData(["firstname":formFirstName,
                              "lastname":self.formLastName,
                              "targetweight" : isValidInt(input: formTargetWeight).output,
                              "height": isValidInt(input: formHeight).output,
                              "birthdate": isValidDate(input: formBirthDate).output,
                              "enddate": isValidDate(input: formEndDate).output,
                              "dietarypref":self.formDietaryPreference, "email": self.formEmail,
                              "phoneeno":self.formPhoneNo,"instructions":NSNull(),"uid":result!.user.uid])
                
                Firestore.firestore().collection("mealdata").document(result!.user.uid)
                    .setData(["User Presets":NSNull()])
                self.isUserAuthenticated = .signedIn
            }
        }
    }
    
    func firebaseSignIn() {
        
        Auth.auth().signIn(withEmail:formEmail, password: formPass) { result, error in
            if error != nil {self.logInError = error!.localizedDescription}
            else {self.isUserAuthenticated = .signedIn}}
        print(logInError)
    }
    
    func fireBaseSignOut() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.isUserAuthenticated = .signedOut
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

func isValidInt(input: String) -> (valid: Bool, output: Int) {
    let output = Int(input) ?? 0
    var valid = false
    if output != 0 &&
        output > 0 &&
        output < 999 {valid = true}
    return (valid, output)
}

func isValidFloat(input: String) -> (valid: Bool, output: Float) {
    var output = Float(input) ?? 0
    var valid = false
    if output != 0 &&
        output > 0 &&
        output < 999 {valid = true; output = round(output * 10) / 10.0}
    return (valid, output)
}

func isValidDate(input:Date) -> (valid: Bool, output: String) {
    let output = dateToString(date: input)
    var valid = false
    if output != dateToString(date: Date.init()) {valid = true}
    return (valid, output)
}

func isValidEmail(email:String) -> Bool {
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
        
    }

func isValidPhoneNo(phoneNo: String) -> Bool {
        
    let phoneRegEx = "^\\d{10}$"
    let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
    return phoneTest.evaluate(with: phoneNo)
    
    }
    
func isValidPass(password : String) -> Bool {
    
    let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordTest.evaluate(with: password)
    
    }


func stringToDate(string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: string) ?? Date.init()
}

func dateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
