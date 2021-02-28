import SwiftUI

struct ModalCamera: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var model: CameraViewModel = .init()
    @State private var showOneLevelIn: Bool = false
    
    var body: some View {
        NavigationStackView {
            ZStack {
                CameraView(model: model)
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
                PushView(destination: EditorView(dataSource: PhotoCollectionDataSource(scannedDocs: model.scannedDocs)), isActive: $showOneLevelIn) {
                    EmptyView()
                }.hidden()
            }.onReceive(model.publisher) { status in
                showOneLevelIn = status
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ModalCamera_Previews: PreviewProvider {
    static var previews: some View {
        ModalCamera()
    }
}
