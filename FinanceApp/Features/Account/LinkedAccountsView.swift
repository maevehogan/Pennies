//
//  LinkedAccountsView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 6/27/26.
//
//  Shows the user's connected bank accounts and lets them link a new one.
//
//  Flow:
//    1. Tap "Connect Bank Account"
//    2. We fetch a link token from our server (POST /plaid/link-token)
//    3. The Plaid Link sheet opens (PlaidLinkView)
//    4. User picks their bank and logs in via Plaid's UI
//    5. On success we exchange the public token (POST /plaid/exchange-token)
//    6. We trigger a transaction sync (POST /plaid/sync)
//    7. The new account appears in the list

import SwiftUI
import SwiftData

struct LinkedAccountsView: View {

    @Environment(\.modelContext) private var context
    @State private var accounts: [LinkedAccount] = []
    @State private var linkToken: String? = nil
    @State private var isLoadingToken = false
    @State private var isSyncing = false
    @State private var errorMessage: String? = nil
    @State private var accountToDisconnect: LinkedAccount? = nil
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Connected Banks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if !accounts.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing.toggle()
                        }
                    } label: {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle")
                            .foregroundStyle(isEditing ? .green : .secondary)
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                if accounts.isEmpty && !isLoadingToken {
                    Text("No accounts connected yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ForEach(accounts) { account in
                        HStack {
                            Image(systemName: "building.columns")
                                .foregroundStyle(.blue)
                            Text(account.institutionName)
                                .foregroundStyle(.white)
                            Spacer()
                            if isEditing {
                                Button {
                                    accountToDisconnect = account
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red.opacity(0.8))
                                }
                                .buttonStyle(.plain)
                                .transition(.opacity.combined(with: .scale))
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding()

                        if account.id != accounts.last?.id {
                            Divider().background(Color.white.opacity(0.1))
                        }
                    }
                }

                Divider().background(Color.white.opacity(0.1))

                // Connect button
                Button {
                    Task { await startLinkFlow() }
                } label: {
                    HStack {
                        if isLoadingToken {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.blue)
                            Text("Connect Bank Account")
                                .foregroundStyle(.blue)
                        }
                        Spacer()
                    }
                    .padding()
                }
                .disabled(isLoadingToken)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, 6)
                    .padding(.horizontal, 4)
            }

            if isSyncing {
                HStack(spacing: 6) {
                    ProgressView()
                        .tint(.secondary)
                    Text("Syncing transactions…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 6)
                .padding(.horizontal, 4)
            }
        }
        // Plaid Link sheet — presented as soon as we have a link token
        .sheet(isPresented: Binding(get: { linkToken != nil }, set: { if !$0 { linkToken = nil } })) {
            if let token = linkToken {
                PlaidLinkView(
                    linkToken: token,
                    onSuccess: { publicToken, institutionName in
                        Task { await handleLinkSuccess(publicToken: publicToken, institutionName: institutionName) }
                    },
                    onExit: {
                        linkToken = nil
                    }
                )
            }
        }
        .task { await loadAccounts() }
        .alert("Disconnect \(accountToDisconnect?.institutionName ?? "Bank")?", isPresented: Binding(
            get: { accountToDisconnect != nil },
            set: { if !$0 { accountToDisconnect = nil } }
        )) {
            Button("Disconnect", role: .destructive) {
                if let account = accountToDisconnect {
                    Task { await disconnect(account) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the connection and delete all imported transactions from this bank.")
        }
    }

    // MARK: - Actions

    private func startLinkFlow() async {
        isLoadingToken = true
        errorMessage = nil
        defer { isLoadingToken = false }
        do {
            linkToken = try await PlaidAPI.createLinkToken()
        } catch {
            errorMessage = "Couldn't start bank connection: \(error.localizedDescription)"
        }
    }

    private func handleLinkSuccess(publicToken: String, institutionName: String) async {
        linkToken = nil
        errorMessage = nil
        do {
            // Exchange the short-lived public token for a stored access token
            let newAccount = try await PlaidAPI.exchangeToken(
                publicToken: publicToken,
                institutionName: institutionName
            )
            accounts = try await PlaidAPI.listLinkedAccounts()

            // Pull in the first batch of transactions from the newly linked account
            isSyncing = true
            defer { isSyncing = false }
            try await PlaidAPI.syncTransactions()
            // Refresh local SwiftData cache so transactions appear immediately
            try await SyncService(context: context).syncBudgets()
        } catch {
            errorMessage = "Failed to connect account: \(error.localizedDescription)"
        }
    }

    private func disconnect(_ account: LinkedAccount) async {
        accountToDisconnect = nil
        errorMessage = nil
        do {
            try await PlaidAPI.disconnect(id: account.id)
            accounts.removeAll { $0.id == account.id }
            if accounts.isEmpty { isEditing = false }
            // Wipe and re-sync local SwiftData so deleted transactions disappear immediately
            let allBudgets = (try? context.fetch(FetchDescriptor<Budget>())) ?? []
            for budget in allBudgets { context.delete(budget) }
            try? context.save()
            try await SyncService(context: context).syncBudgets()
        } catch {
            errorMessage = "Failed to disconnect: \(error.localizedDescription)"
        }
    }

    private func loadAccounts() async {
        do {
            accounts = try await PlaidAPI.listLinkedAccounts()
        } catch {
            // Silently ignore — if this fails the list stays empty
        }
    }
}
