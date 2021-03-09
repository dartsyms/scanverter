import SwiftUI

struct MainTabBarView: View {
    @State private var currentView: Tab = .folders
    @State private var showCameraModal: Bool = false
    @State private var showMicModal: Bool = false
    @State private var showSearchModal: Bool = false
    
    init() {
        UINavigationBar.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CurrentScreen(currentView: self.$currentView)
                    .fullScreenCover(isPresented: self.$showMicModal, content: TextRecognizerScreen.init)
                TabBar(currentView: self.$currentView,
                       showCameraModal: self.$showCameraModal,
                       showMicModal: self.$showMicModal,
                       showSearchModal: self.$showSearchModal)
                    .fullScreenCover(isPresented: self.$showCameraModal, content: { ModalCamera(model: CameraViewModel()) })
            }
            .edgesIgnoringSafeArea(.all)
        }
        .background(Color(.white))
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: self.$showSearchModal, content: ModalSearchScreen.init)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
