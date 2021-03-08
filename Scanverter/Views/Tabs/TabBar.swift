import SwiftUI

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(currentView: .constant(.folders), showCameraModal: .constant(false), showMicModal: .constant(false), showSearchModal: .constant(false))
            .preferredColorScheme(.dark)
    }
}

struct TabBar: View {
    @Binding var currentView: Tab
    @Binding var showCameraModal: Bool
    @Binding var showMicModal: Bool
    @Binding var showSearchModal: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            VStack {
                TabBarItem(currentView: self.$currentView,
                           imageName: "folder",
                           paddingEdges: .leading,
                           tab: .folders)
                Text("Folders")
                    .foregroundColor(.primary)
                    .font(.caption2)
            }.padding(.leading, 5)
           
            HStack(spacing: 40) {
                VStack {
                    ModalScreenShowTabButton(name: "eye", radius: 20) {
                        self.showMicModal.toggle()
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                    Text("Vision")
                        .foregroundColor(.primary)
                        .font(.caption2)
                }
                VStack {
                    ModalScreenShowTabButton(name: "camera.fill", radius: 20) {
                        self.showCameraModal.toggle()
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                    Text("CamScan")
                        .foregroundColor(.primary)
                        .font(.caption2)
                }
                VStack {
                    ModalScreenShowTabButton(name: "magnifyingglass", radius: 20) {
                        self.showSearchModal.toggle()
                    }.foregroundColor(Color(.white))
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                    Text("Search")
                        .foregroundColor(.primary)
                        .font(.caption2)
                }
            }
            
            VStack {
                TabBarItem(currentView: self.$currentView,
                           imageName: "gearshape",
                           paddingEdges: .trailing,
                           tab: .settings)
                Text("Settings")
                    .foregroundColor(.primary)
                    .font(.caption2)
            }.padding(.trailing, 5)
        }
        .frame(minHeight: 70)
    }
}


