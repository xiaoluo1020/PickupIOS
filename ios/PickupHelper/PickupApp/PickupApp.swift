import SwiftUI

@main
struct PickupApp: App {
    @StateObject private var store = PackageStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
