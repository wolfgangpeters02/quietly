import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case goals
    case notes
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Library"
        case .goals: return "Goals"
        case .notes: return "Notes"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "books.vertical"
        case .goals: return "target"
        case .notes: return "note.text"
        case .settings: return "gearshape"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "books.vertical.fill"
        case .goals: return "target"
        case .notes: return "note.text"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(
                            tab.title,
                            systemImage: selectedTab == tab ? tab.selectedIcon : tab.icon
                        )
                    }
                    .tag(tab)
            }
        }
        .tint(Color.quietly.primary)
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .goals:
            GoalsView()
        case .notes:
            NotesView()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
}
