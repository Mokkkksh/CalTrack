import SwiftUI
import Firebase

@main
struct CalTrackApp: App {
    init() {FirebaseApp.configure()}
    var authInfo = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(authInfo)
        }
    }
}
