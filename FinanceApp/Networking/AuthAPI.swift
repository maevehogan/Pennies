// AuthAPI.swift
// Networking calls for user authentication.
//
// After a successful login or register, the JWT is saved to APIClient.shared.token
// so all subsequent requests are automatically authenticated.
//
// The caller is responsible for navigating to the main app on success
// and showing an error message on failure.

import Foundation

@MainActor
struct AuthAPI {

    // Registers a new account and saves the returned JWT.
    // Throws APIError.serverError("Email already registered") if the email is taken.
    static func register(email: String, password: String) async throws {
        let body = ["email": email, "password": password]
        let response: TokenResponse = try await APIClient.shared.post(
            TokenResponse.self,
            to: "/auth/register",
            body: body
        )
        APIClient.shared.token = response.token
    }

    // Logs in with an existing account and saves the returned JWT.
    // Throws APIError.unauthorized if credentials are wrong.
    static func login(email: String, password: String) async throws {
        let body = ["email": email, "password": password]
        let response: TokenResponse = try await APIClient.shared.post(
            TokenResponse.self,
            to: "/auth/login",
            body: body
        )
        APIClient.shared.token = response.token
    }

    // Clears the stored JWT, effectively logging out.
    // The next request to any protected endpoint will throw APIError.unauthorized.
    static func logout() {
        APIClient.shared.token = nil
    }
}
