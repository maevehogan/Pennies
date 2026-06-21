//
//  finance_appApp.swift
//  finance-app
//
//  Created by Maeve Hogan on 1/3/26.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct FinanceApp: App {

    @State private var router = AppRouter()
    @State private var session = UserSession()
    // Tracks whether the user has a valid JWT. Flips to true after login/register,
    // false after logout. Drives the AuthView ↔ RootTabView swap.
    @State private var isLoggedIn = APIClient.shared.isLoggedIn

    static let sharedModelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for:
                Budget.self,
                SubBudget.self,
                Transaction.self
            )
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                RootTabView(onLogout: { context in
                    session.logout(context: context)
                    isLoggedIn = false
                })
                .environment(router)
                .environment(session)
            } else {
                AuthView(onSuccess: { email in
                    session.login(email: email)
                    isLoggedIn = true
                })
            }
        }
        .modelContainer(Self.sharedModelContainer)
    }
}
