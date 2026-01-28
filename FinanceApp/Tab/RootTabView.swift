//
//  RootTabView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var homePath: [HomeNavigation] = []
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab(path: $homePath)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(TabItem.home)
            
            
        }
    }
}

extension RootTabView {
    private func tabSelection() -> Binding<TabItem> {
        Binding {
            selectedTab
        } set: { newTab in
            if selectedTab == newTab {
                switch newTab {
                case .home:
                    homePath = []
                default:
                    break
                }
            }
            selectedTab = newTab
        }
    }
}

#Preview {
    RootTabView()
        .environment(BudgetsViewModel())
        .environment(TransactionsViewModel())
}
