import SwiftUI

@main
struct ScanverterApp: App {
    
    init() {
        AppContainer.makeDefault()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabBarView()
        }
    }
}
