import Foundation
import Combine
import SwiftUI

struct TabBarItem: View {
    @Binding var currentView: Tab
    let imageName: String
    let paddingEdges: Edge.Set
    let tab: Tab
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: self.currentView == tab ? "\(imageName).fill" : imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(self.currentView == tab ? Color(.systemBlue) : Color(.label))
                .cornerRadius(6)
        }
        .frame(width: 30, height: 30)
        .onTapGesture { self.currentView = self.tab }
    }
}

struct TabBarItem_Previews: PreviewProvider {
    static var previews: some View {
        TabBarItem(currentView: .constant(.settings), imageName: "camera", paddingEdges: .leading, tab: .settings)
    }
}
