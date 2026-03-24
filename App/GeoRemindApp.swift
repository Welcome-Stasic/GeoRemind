import SwiftUI

@main
struct GeoRemindApp: App {
    let user = UserProfile(
        id: "1",
        email: "123@123.com",
        name: "Станислав"
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView(user: user)
        }
    }
}
