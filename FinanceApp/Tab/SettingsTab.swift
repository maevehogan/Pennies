//
//  SettingsTab.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/30/26.
//

import SwiftUI

struct SettingsTab: View {
    @Environment(AppRouter.self) private var router
    let onLogout: () -> Void

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.settingsPath) {
            SettingsView(onLogout: onLogout)
                .navigationDestination(for: SettingsNavigation.self) { destination in
                    switch destination {
                    case .settingsMain:
                        SettingsView(onLogout: onLogout)
                    }
                }
        }
    }
}

#Preview {
    SettingsTab(onLogout: {})
        .environment(AppRouter())
}
