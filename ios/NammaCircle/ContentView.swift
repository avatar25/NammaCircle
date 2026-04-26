import SwiftUI

struct ContentView: View {
    private let modules = [
        "Locality map and scores",
        "Rent fairness check",
        "Kannada daily lessons",
        "Forum posts and comments",
        "Quests and points",
        "Mentor profiles and bookings"
    ]

    var body: some View {
        NavigationStack {
            List(modules, id: \.self) { module in
                Text(module)
            }
            .navigationTitle("NammaCircle")
        }
    }
}

#Preview {
    ContentView()
}
