//
//  SettingsView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
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
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Account")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
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
                                        // TODO: call update API
                                        session.updateEmail(emailDraft)
                                        editingEmail = false
                                    }
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.blue)
                                } else {
                                    Button("Edit") {
                                        emailDraft = session.email
                                        editingEmail = true
                                        editingPassword = false
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                }
                            }
                            if editingEmail {
                                TextField("Email", text: $emailDraft)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(8)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(8)
                                    .foregroundStyle(.white)
                            } else {
                                Text(session.email)
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                        }
                        .padding()

                        Divider().background(Color.white.opacity(0.1))

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
                                    .foregroundStyle(.blue)
                                } else {
                                    Button("Edit") {
                                        passwordDraft = ""
                                        editingPassword = true
                                        editingEmail = false
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                }
                            }
                            if editingPassword {
                                SecureField("New password", text: $passwordDraft)
                                    .textContentType(.newPassword)
                                    .padding(8)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(8)
                                    .foregroundStyle(.white)
                            } else {
                                Text("••••••••")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.top, 40)

                Spacer()

                Button(role: .destructive) {
                    session.logout(context: context)
                    onLogout()
                } label: {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.15))
                        .foregroundStyle(.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    SettingsView(onLogout: {})
        .environment(UserSession())
}
