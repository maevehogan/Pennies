//
//  SettingsTab.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/30/26.
//

import SwiftUI

struct SettingsTab: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.settingsPath) {
            SettingsView(
                //navSettings: {},
            )
                .navigationDestination(for: SettingsNavigation.self) { destination in
                    switch destination {
                    case .settingsMain:
                        SettingsView()
                    }
                }
        }

    }
}

#Preview {
    SettingsTab()
        .environment(AppRouter())
}
