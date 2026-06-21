// APIClient.swift
// The core networking layer. All API requests go through this singleton.
//
// Responsibilities:
//   - Attaches the JWT token to every request via the Authorization header
//   - Encodes request bodies as JSON and decodes responses into Codable types
//   - Maps HTTP error status codes into typed APIError cases for consistent handling
//   - Stores and retrieves the JWT token from UserDefaults (swap for Keychain in production)
//
// Usage:
//   let budgets = try await APIClient.shared.get([BudgetResponse].self, from: "/budgets")
//   let budget  = try await APIClient.shared.post(BudgetResponse.self, to: "/budgets", body: req)

import Foundation

// Typed errors returned by all API calls.
// Callers can switch on these to show appropriate UI (e.g. redirect to login on .unauthorized).
enum APIError: Error, LocalizedError {
    case unauthorized           // 401 — token missing or expired, redirect to login
    case notFound               // 404
    case serverError(String)    // 4xx/5xx with a message from the server
    case decodingError(Error)   // response didn't match the expected Codable type
    case unknown(Error)         // unexpected URLSession or other error

    var errorDescription: String? {
        switch self {
        case .unauthorized:           return "You are not logged in."
        case .notFound:               return "The requested resource was not found."
        case .serverError(let msg):   return msg
        case .decodingError(let err): return "Response format error: \(err.localizedDescription)"
        case .unknown(let err):       return err.localizedDescription
        }
    }
}

@MainActor
final class APIClient {
    static let shared = APIClient()

    // For the iOS Simulator use your Mac's local IP (not localhost — the simulator
    // has its own network stack). For a physical device, use the same IP.
    // Change to your production URL before shipping.
    private let baseURL = "http://192.168.1.27:8080"

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // Token is stored in UserDefaults for simplicity.
    // TODO: move to Keychain before shipping — UserDefaults is not encrypted.
    var token: String? {
        get { UserDefaults.standard.string(forKey: "auth_token") }
        set { UserDefaults.standard.set(newValue, forKey: "auth_token") }
    }

    var isLoggedIn: Bool { token != nil }

    private init() {
        session = URLSession.shared

        decoder = JSONDecoder()
        // Matches the ISO8601 date format Vapor sends by default
        decoder.dateDecodingStrategy = .iso8601

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - HTTP Methods

    func get<T: Decodable>(_ type: T.Type, from path: String) async throws -> T {
        let req = try makeRequest(method: "GET", path: path, body: nil as EmptyBody?)
        return try await send(req, decoding: type)
    }

    func post<Body: Encodable, Response: Decodable>(
        _ type: Response.Type,
        to path: String,
        body: Body
    ) async throws -> Response {
        let req = try makeRequest(method: "POST", path: path, body: body)
        return try await send(req, decoding: type)
    }

    func put<Body: Encodable, Response: Decodable>(
        _ type: Response.Type,
        to path: String,
        body: Body
    ) async throws -> Response {
        let req = try makeRequest(method: "PUT", path: path, body: body)
        return try await send(req, decoding: type)
    }

    @discardableResult
    func delete(path: String) async throws -> Bool {
        let req = try makeRequest(method: "DELETE", path: path, body: nil as EmptyBody?)
        let (_, response) = try await session.data(for: req)
        try validateStatus(response)
        return true
    }

    // MARK: - Internals

    private func makeRequest<Body: Encodable>(
        method: String,
        path: String,
        body: Body?
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.serverError("Invalid URL: \(path)")
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try encoder.encode(body)
        }

        return req
    }

    private func send<T: Decodable>(_ request: URLRequest, decoding type: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)
        try validateStatus(response, data: data)
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    private func validateStatus(_ response: URLResponse, data: Data? = nil) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200...299: return
        case 401: throw APIError.unauthorized
        case 404: throw APIError.notFound
        default:
            let message = data.flatMap { try? JSONDecoder().decode(VaporError.self, from: $0) }?.reason
                ?? "Server error (\(http.statusCode))"
            throw APIError.serverError(message)
        }
    }
}

// Vapor's default error response shape: { "error": true, "reason": "..." }
private struct VaporError: Decodable {
    let reason: String
}

// Used as a placeholder type for requests with no body (GET, DELETE)
private struct EmptyBody: Encodable {}
