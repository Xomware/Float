import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Nearby", systemImage: "map.fill")
                }
            DealListView()
                .tabItem {
                    Label("Deals", systemImage: "tag.fill")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            FriendActivityView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(FloatColors.primary)
    }
}
