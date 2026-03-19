//
//  RootView.swift
//  Hair AI
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject var authVM: AuthViewModel
    @AppStorage("hasCompletedQuestionnaire") private var hasCompletedQuestionnaire = false

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                if hasCompletedQuestionnaire {
                    HomeDashboardView()
                } else {
                    NavigationStack {
                        QuestionnaireView()
                    }
                }
            } else {
                SplashView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authVM.isLoggedIn)
    }
}
