import SwiftUI

public struct ModalScreenShowTabButton: View {
    let imageName: String
    let radius: CGFloat
    let action: () -> Void

    public init(name: String, radius: CGFloat, action: @escaping () -> Void) {
        self.imageName = name
        self.radius = radius
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: radius, height: radius, alignment: .center)
                .foregroundColor(.primary)
        }
        .frame(width: radius, height: radius)
        .onTapGesture(perform: action)
    }
}

struct ModalScreenShowTabButton_Previews_Previews: PreviewProvider {
    static var previews: some View {
        ModalScreenShowTabButton(name: "gears", radius: 55) { }
    }
}
