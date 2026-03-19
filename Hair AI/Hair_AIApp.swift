import SwiftUI
import Firebase

@main
struct Hair_AIApp: App {

    @StateObject private var authVM = AuthViewModel()

    init() {
        // Only configure Firebase if GoogleService-Info.plist exists
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           !path.isEmpty {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
        }
    }
}
