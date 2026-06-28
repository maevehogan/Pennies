//
//  SettingsView.swift
//  FinanceApp
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(UserSession.self) private var session
    @Environment(\.modelContext) private var context
    let onLogout: () -> Void

    @State private var editingEmail = false
    @State private var editingPassword = false
    @State private var emailDraft = ""
    @State private var passwordDraft = ""

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    HStack {
                        GradientLabel("Settings", font: .title.bold())
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Account card
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Account")
                            .padding(.bottom, 10)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            // Email row
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Email")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    if editingEmail {
                                        Button("Save") {
                                            session.updateEmail(emailDraft)
                                            editingEmail = false
                                        }
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color.electricBlue)
                                    } else {
                                        Button("Edit") {
                                            emailDraft = session.email
                                            editingEmail = true
                                            editingPassword = false
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(Color.electricBlue)
                                    }
                                }
                                if editingEmail {
                                    TextField("Email", text: $emailDraft)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding(10)
                                        .background(Color.white.opacity(0.07))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .foregroundStyle(.white)
                                } else {
                                    Text(session.email)
                                        .foregroundStyle(Color.white.opacity(0.45))
                                        .font(.subheadline)
                                }
                            }
                            .padding(16)

                            Divider().background(Color.white.opacity(0.08))

                            // Password row
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Password")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    if editingPassword {
                                        Button("Save") {
                                            session.updatePassword(passwordDraft)
                                            editingPassword = false
                                            passwordDraft = ""
                                        }
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color.electricBlue)
                                    } else {
                                        Button("Edit") {
                                            passwordDraft = ""
                                            editingPassword = true
                                            editingEmail = false
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(Color.electricBlue)
                                    }
                                }
                                if editingPassword {
                                    SecureField("New password", text: $passwordDraft)
                                        .textContentType(.newPassword)
                                        .padding(10)
                                        .background(Color.white.opacity(0.07))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .foregroundStyle(.white)
                                } else {
                                    Text("••••••••")
                                        .foregroundStyle(Color.white.opacity(0.45))
                                        .font(.subheadline)
                                }
                            }
                            .padding(16)
                        }
                        .glassCard(cornerRadius: 18)
                    }
                    .padding(.horizontal, 20)

                    // Linked Accounts
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Linked Accounts")
                            .padding(.bottom, 10)
                            .padding(.horizontal, 4)

                        LinkedAccountsView()
                            .glassCard(cornerRadius: 18)
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 16)

                    // Logout
                    Button(role: .destructive) {
                        session.logout(context: context)
                        onLogout()
                    } label: {
                        Text("Log Out")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.15))
                            .foregroundStyle(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 100)
                }
            }
        }
    }
}

#Preview {
    SettingsView(onLogout: {})
        .environment(UserSession())
}
