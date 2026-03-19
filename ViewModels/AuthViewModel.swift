//
//  AuthViewModel.swift
//  Hair AI
//

import SwiftUI
import Combine
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var currentUser: FirebaseAuth.User? = nil

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        guard FirebaseApp.app() != nil else {
            // Firebase not configured (GoogleService-Info.plist missing) — bypass auth
            isLoggedIn = true
            return
        }
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isLoggedIn = user != nil
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Sign Up
    func signUp(name: String, email: String, password: String) {
        guard FirebaseApp.app() != nil else { isLoggedIn = true; return }
        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = self.friendlyError(error)
                    self.isLoading = false
                }
                return
            }

            guard let user = result?.user else { return }

            // Save display name
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { _ in }

            DispatchQueue.main.async {
                self.currentUser = user
                self.isLoggedIn  = true
                self.isLoading   = false
            }
        }
    }

    // MARK: - Login
    func login(email: String, password: String) {
        guard FirebaseApp.app() != nil else { isLoggedIn = true; return }
        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = self.friendlyError(error)
                } else {
                    self.currentUser = result?.user
                    self.isLoggedIn  = true
                }
                self.isLoading = false
            }
        }
    }

    // MARK: - Logout
    func logout() {
        guard FirebaseApp.app() != nil else { isLoggedIn = false; return }
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn  = false
                self.currentUser = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Reset Password
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = "Reset email sent! Check your inbox."
                }
            }
        }
    }

    // MARK: - Helper
    private func friendlyError(_ error: Error) -> String {
        let errCode = AuthErrorCode(rawValue: (error as NSError).code)
        switch errCode {
        case .emailAlreadyInUse: return "That email is already registered."
        case .invalidEmail:      return "Please enter a valid email address."
        case .weakPassword:      return "Password must be at least 6 characters."
        case .wrongPassword:     return "Incorrect password. Please try again."
        case .userNotFound:      return "No account found with that email."
        case .networkError:      return "Network error. Check your connection."
        default:                 return error.localizedDescription
        }
    }
}
