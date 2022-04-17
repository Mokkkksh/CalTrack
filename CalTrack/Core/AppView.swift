import SwiftUI
import Firebase

struct AppView: View {
    @EnvironmentObject var authInfo: AuthViewModel
    var body: some View {
        Group {
            if authInfo.isUserAuthenticated == .undefined {
                Text("Loading...")
            } else if authInfo.isUserAuthenticated == .signedOut {
                AuthView()
            } else {
                HomeView()
            }
        }
        .onAppear {
            if Auth.auth().currentUser != nil {authInfo.isUserAuthenticated = .signedIn}
            else {authInfo.isUserAuthenticated = .signedOut}
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
