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
    @State private var selectedTab: AppTab = .home
    @State private var showAddBook = false
    @State private var showReadingSession = false

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
        .background(Color.quietly.background.ignoresSafeArea())
        .onReceive(NotificationCenter.default.publisher(for: .openReadingSession)) { _ in
            selectedTab = .home
            // The HomeView will handle showing the reading session
            NotificationCenter.default.post(name: .triggerReadingSession, object: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: .openGoalsView)) { _ in
            selectedTab = .goals
        }
        .onReceive(NotificationCenter.default.publisher(for: .openLibrary)) { _ in
            selectedTab = .home
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAddBook)) { _ in
            selectedTab = .home
            showAddBook = true
        }
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
        .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
