import SwiftUI

struct ModalCamera: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            CameraView()
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .foregroundColor(.gray)
                    
                })
            }.offset(x: -20, y: -350)
        }
        
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ModalCamera_Previews: PreviewProvider {
    static var previews: some View {
        ModalCamera()
    }
}
