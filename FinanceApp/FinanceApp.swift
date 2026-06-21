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
                RootTabView(onLogout: { isLoggedIn = false })
                    .environment(router)
            } else {
                AuthView(onSuccess: { isLoggedIn = true })
            }
        }
        .modelContainer(Self.sharedModelContainer)
    }
}
