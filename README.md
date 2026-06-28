# FinanceApp

A personal finance tracker for iOS with a dark-mode glassmorphism UI. Track budgets, log transactions manually, and import bank activity via Plaid — all synced to a Vapor backend with JWT authentication.

![Screenshot placeholder](docs/screenshot.png)

---

## Features

- **Budget management** — create budgets with sub-budgets and visualize spending with donut charts
- **Transaction tracking** — log transactions manually or import them automatically from linked bank accounts
- **Plaid bank integration** — connect accounts via Plaid Link; transactions sync in the background
- **JWT authentication** — register and sign in against a Vapor backend; token stored locally
- **Glassmorphism UI** — dark-mode-first design with frosted glass cards, gradient labels, and a floating tab bar

---

## Requirements

- Xcode 15+
- iOS 17+ deployment target
- A running instance of [finance-app-server](https://github.com/maevehogan/finance-app-server)

---

## Setup

1. **Clone this repo**

   ```bash
   git clone https://github.com/maevehogan/FinanceApp.git
   cd FinanceApp
   ```

2. **Start the backend** — follow the instructions in [finance-app-server](https://github.com/maevehogan/finance-app-server) to get the Vapor server running.

3. **Set the base URL** — open `FinanceApp/Networking/APIClient.swift` and update `baseURL` to point at your server (see [Configuration](#configuration) below).

4. **Open in Xcode** — open `FinanceApp.xcodeproj`, select your simulator or device, and press Run.

---

## Configuration

The only required change before running is the server URL in `APIClient.swift`:

```swift
private let baseURL = "http://localhost:8080"
```

| Target | Value |
|---|---|
| iOS Simulator | Your Mac's LAN IP, e.g. `http://192.168.1.x:8080` (not `localhost` — the simulator has its own network stack). Run `ipconfig getifaddr en0` to find it. |
| Physical device | Same LAN IP as above, or your server's public URL. |
| Production | Your hosted server URL, e.g. `https://api.yourapp.com`. |

> **Note:** The JWT token is currently stored in `UserDefaults`. Swap this for Keychain before shipping to production.

---

## Architecture

| Layer | Details |
|---|---|
| **UI** | SwiftUI, iOS 17+. Four tabs — Home, Budgets, Transactions, Settings — rendered in `RootTabView` with a custom floating tab bar. |
| **Navigation** | `AppRouter` (Observable) owns per-tab `NavigationPath` stacks and the active tab selection. Tapping the active tab pops to root. |
| **Local storage** | SwiftData models: `Budget`, `SubBudget`, `Transaction`. These are separate from the network DTOs in `APIModels.swift`. |
| **Networking** | `APIClient` singleton handles JWT attachment, JSON encode/decode, and typed `APIError` cases. All requests target `baseURL`. |
| **Sync** | `SyncService` fetches from the server and upserts into the local SwiftData store. Called on app launch and after Plaid token exchange. |
| **Plaid** | `PlaidAPI` coordinates the link-token → Plaid Link sheet → public-token exchange → transaction sync flow. `LinkedAccountsView` owns the UI for this flow. |

---

## Backend

The server is a separate Swift / Vapor project:
[https://github.com/maevehogan/finance-app-server](https://github.com/maevehogan/finance-app-server)

It provides REST endpoints for auth, budgets, transactions, and Plaid token exchange/sync.
