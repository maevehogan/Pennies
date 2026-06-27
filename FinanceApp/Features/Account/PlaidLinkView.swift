//
//  PlaidLinkView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 6/27/26.
//
//  Wraps Plaid's LinkKit in a SwiftUI sheet.
//
//  LinkKit 7.x exposes a session-based API with native SwiftUI support,
//  so we no longer need a UIViewControllerRepresentable bridge. We create
//  a PlaidLinkSession from the token our server issued, then render the
//  session's own `sheet()` view. When the user completes the bank picker,
//  Plaid calls onSuccess with a public token and the institution name —
//  we forward those to the server to complete the connection.

import SwiftUI
import LinkKit

struct PlaidLinkView: View {

    let linkToken: String
    /// Called on success with (publicToken, institutionName)
    let onSuccess: (String, String) -> Void
    let onExit: () -> Void

    @State private var linkSession: PlaidLinkSession?
    @State private var setupError: String?

    var body: some View {
        Group {
            if let linkSession {
                linkSession.sheet()
            } else if let setupError {
                // If LinkKit can't initialise, show the reason so the user
                // can dismiss the sheet instead of staring at a blank screen.
                Text("Unable to start Plaid Link: \(setupError)")
                    .padding()
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: createSession)
    }

    private func createSession() {
        // Prevent redundant session initialisations if one already exists.
        guard linkSession == nil else { return }

        // Configure the Link session using the token we got from our server.
        let config = LinkTokenConfiguration(
            token: linkToken,
            onSuccess: { success in
                let name = success.metadata.institution.name
                onSuccess(success.publicToken, name)
            },
            onExit: { _ in
                onExit()
            },
            onEvent: { _ in },
            onLoad: { }
        )

        do {
            linkSession = try Plaid.createPlaidLinkSession(configuration: config)
        } catch {
            print("createPlaidLinkSession failed:", error)
            setupError = error.localizedDescription
        }
    }
}
