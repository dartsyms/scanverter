import SwiftUI

struct ModalCamera: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var model: CameraViewModel
    @State private var showOneLevelIn: Bool = false
    @State private var fromEditor: Bool = false
    
    init(model: CameraViewModel) {
        self.model = model
    }
    
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
                PushView(destination: EditorView(dataSource: PhotoCollectionDataSource(scannedDocs: model.scannedDocs), backToCamera: $fromEditor), isActive: $showOneLevelIn) {
                    EmptyView()
                }.hidden()
            }.onReceive(model.publisher) { status in
                showOneLevelIn = status
            }
            .onAppear {
                if fromEditor {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ModalCamera_Previews: PreviewProvider {
    static var previews: some View {
        ModalCamera(model: CameraViewModel())
    }
}
