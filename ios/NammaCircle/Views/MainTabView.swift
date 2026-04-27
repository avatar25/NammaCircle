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
                Label("Areas", systemImage: "map")
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
                Label("Kannada", systemImage: "text.book.closed")
            }

            NavigationStack {
                ForumView()
            }
            .tabItem {
                Label("Forum", systemImage: "bubble.left.and.bubble.right")
            }

            NavigationStack {
                QuestsView()
            }
            .tabItem {
                Label("More", systemImage: "sparkles")
            }
        }
    }
}
