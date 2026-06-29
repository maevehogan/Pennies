// AuthView.swift
// FinanceApp

import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    let onSuccess: (String) -> Void

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Spacer()

                // Logo / brand
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.electricBlue.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(colors: [.electricBlue, .hotPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }
                    .padding(.bottom, 8)

                    GradientLabel("Pennies", font: .largeTitle.bold())
                    Text(isRegistering ? "Create your account" : "Welcome back")
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .padding(.bottom, 48)

                // Form card
                VStack(spacing: 14) {
                    GlassTextField(placeholder: "Email", text: $email, isSecure: false)
                        .textContentType(.emailAddress)

                    GlassTextField(placeholder: "Password", text: $password, isSecure: true)
                        .textContentType(isRegistering ? .newPassword : .password)

                    if let msg = errorMessage {
                        Text(msg)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }

                    // Primary button
                    Button {
                        Task { await submit() }
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(isRegistering ? "Create Account" : "Sign In")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.electricBlue, Color(red: 0.3, green: 0.2, blue: 0.9)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.electricBlue.opacity(0.4), radius: 12, y: 6)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity(isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1)
                    .padding(.top, 8)
                }
                .padding(24)
                .glassCard(cornerRadius: 24)

                // Toggle link
                Button {
                    isRegistering.toggle()
                    errorMessage = nil
                } label: {
                    Text(isRegistering ? "Already have an account? **Sign in**" : "Don't have an account? **Register**")
                        .font(.footnote)
                        .foregroundStyle(Color.white.opacity(0.55))
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
    }

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
            onSuccess(email)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Glass Text Field

private struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                #if os(iOS)
                TextField(placeholder, text: $text)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                #else
                TextField(placeholder, text: $text)
                    .autocorrectionDisabled()
                #endif
            }
        }
        .foregroundStyle(.white)
        .padding(14)
        .background(Color.white.opacity(0.07))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AuthView(onSuccess: { _ in })
}
