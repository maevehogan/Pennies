// PlaidAPI.swift
// Networking calls for Plaid-related backend endpoints.
//
// Flow:
//   1. createLinkToken()     → get a short-lived token to open the Plaid UI
//   2. exchangeToken(...)    → swap the public token from Plaid for a stored access token
//   3. syncTransactions()    → pull new/modified/removed transactions from all linked accounts
//   4. listLinkedAccounts()  → fetch the list of connected banks for the Settings UI

import Foundation

struct PlaidAPI {

    // Asks the server to create a Plaid Link token for the current user.
    // Returns the raw `link_token` string that LinkKit needs to open the bank picker.
    static func createLinkToken() async throws -> String {
        let response: LinkTokenResponse = try await APIClient.shared.post(
            LinkTokenResponse.self,
            to: "/plaid/link-token",
            body: EmptyBody()
        )
        return response.linkToken
    }

    // Sends Plaid's public token (from the Link success callback) to the server,
    // which exchanges it for a permanent access token and stores it.
    // Returns the newly linked account so the UI can update immediately.
    static func exchangeToken(publicToken: String, institutionName: String) async throws -> LinkedAccount {
        let body = ExchangeTokenRequest(publicToken: publicToken, institutionName: institutionName)
        return try await APIClient.shared.post(LinkedAccount.self, to: "/plaid/exchange-token", body: body)
    }

    // Triggers a full transaction sync on the server for all linked accounts.
    // In sandbox, fires the webhook first so Plaid marks transactions as ready,
    // then waits briefly before syncing.
    static func syncTransactions() async throws {
        try await APIClient.shared.postVoid(to: "/plaid/sandbox-fire", body: EmptyBody())
        try await Task.sleep(for: .seconds(2))
        try await APIClient.shared.postVoid(to: "/plaid/sync", body: EmptyBody())
    }

    // Returns all bank accounts the user has connected via Plaid.
    static func listLinkedAccounts() async throws -> [LinkedAccount] {
        try await APIClient.shared.get([LinkedAccount].self, from: "/plaid/items")
    }

    // Disconnects a linked bank account and removes its imported transactions.
    static func disconnect(id: UUID) async throws {
        try await APIClient.shared.delete(path: "/plaid/items/\(id.uuidString)")
    }
}

// MARK: - Request / Response types

private struct LinkTokenResponse: Decodable {
    let linkToken: String

    enum CodingKeys: String, CodingKey {
        case linkToken = "link_token"
    }
}

private struct ExchangeTokenRequest: Encodable {
    let publicToken: String
    let institutionName: String
}

private struct EmptyBody: Encodable {}
