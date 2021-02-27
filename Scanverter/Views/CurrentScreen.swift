import SwiftUI

struct CurrentScreen: View {
    @Binding var currentView: Tab

    var body: some View {
        VStack {
            if self.currentView == .folders {
                FoldersScreen()
            } else {
                SettingsScreen()
            }
        }
    }
}

struct CurrentScreen_Previews: PreviewProvider {
    static var previews: some View {
        CurrentScreen(currentView: .constant(.folders))
    }
}
