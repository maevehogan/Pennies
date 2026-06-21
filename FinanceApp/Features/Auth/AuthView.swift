// AuthView.swift
// The login/register screen shown when the user is not authenticated.
// Toggles between login and register mode with a single button.
//
// On success, the JWT is saved by AuthAPI and isLoggedIn flips to true,
// which causes FinanceApp.swift to swap this view out for RootTabView.
//
// Error messages are shown inline below the form so the user knows what went wrong
// without leaving the screen (e.g. "Email already registered", "Invalid credentials").

import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    // Called by FinanceApp when auth succeeds so it can swap in RootTabView
    let onSuccess: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // App title
                Text("FinanceApp")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.blue)

                Text(isRegistering ? "Create an account" : "Sign in to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                // Form fields
                VStack(spacing: 16) {
                    emailField
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundStyle(.white)

                    SecureField("Password", text: $password)
                        .textContentType(isRegistering ? .newPassword : .password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                }

                // Inline error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                // Primary action button
                Button {
                    Task { await submit() }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isRegistering ? "Create Account" : "Sign In")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                // Toggle between login and register
                Button {
                    isRegistering.toggle()
                    errorMessage = nil
                } label: {
                    Text(isRegistering ? "Already have an account? Sign in" : "Don't have an account? Register")
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Subviews

    private var emailField: some View {
        #if os(iOS) || os(visionOS)
        TextField("Email", text: $email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #else
        TextField("Email", text: $email)
            .autocorrectionDisabled()
        #endif
    }

    // MARK: - Actions

    private func submit() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            if isRegistering {
                try await AuthAPI.register(email: email, password: password)
            } else {
                try await AuthAPI.login(email: email, password: password)
            }
            onSuccess()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AuthView(onSuccess: {})
}
