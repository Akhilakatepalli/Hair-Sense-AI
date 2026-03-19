import SwiftUI
import Firebase

@main
struct Hair_AIApp: App {

    @StateObject private var authVM = AuthViewModel()
    @StateObject private var healthKit = HealthKitService.shared
    @StateObject private var notifications = NotificationService.shared

    init() {
        // Only configure Firebase if GoogleService-Info.plist exists
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           !path.isEmpty {
            FirebaseApp.configure()
        }
        // Request notification permission on first launch
        NotificationService.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environmentObject(healthKit)
                .environmentObject(notifications)
        }
    }
}
