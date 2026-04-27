import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                LocalityMapView()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                RentCheckView()
            }
            .tabItem {
                Label("Rent", systemImage: "indianrupeesign.circle")
            }

            NavigationStack {
                KannadaLessonView()
            }
            .tabItem {
                Label("Learn", systemImage: "text.book.closed")
            }

            NavigationStack {
                ForumView()
            }
            .tabItem {
                Label("Community", systemImage: "bubble.left.and.bubble.right")
            }

            NavigationStack {
                QuestsView()
            }
            .tabItem {
                Label("Quests", systemImage: "sparkles")
            }
        }
        .tint(NammaColor.deepGreen)
    }
}
