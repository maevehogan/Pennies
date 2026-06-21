//
//  UserSession.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 6/21/26.
//

import Foundation
import SwiftData

@Observable
@MainActor
class UserSession {
    var email: String = ""

    var isLoggedIn: Bool { APIClient.shared.isLoggedIn }

    func login(email: String) {
        self.email = email
    }

    func updateEmail(_ newEmail: String) {
        // TODO: call PATCH /auth/update-email API, then set on success
        email = newEmail
    }

    func updatePassword(_ newPassword: String) {
        // TODO: call PATCH /auth/update-password API
    }

    func logout(context: ModelContext) {
        AuthAPI.logout()
        email = ""
        clearLocalData(context: context)
    }

    private func clearLocalData(context: ModelContext) {
        let budgets = (try? context.fetch(FetchDescriptor<Budget>())) ?? []
        for budget in budgets {
            context.delete(budget) // cascades to SubBudgets → Transactions
        }
        try? context.save()
    }
}
