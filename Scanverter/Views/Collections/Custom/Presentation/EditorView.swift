import SwiftUI

struct EditorView: View {
    @EnvironmentObject var navStack: NavigationStack
    @StateObject var dataSource: PhotoCollectionDataSource
    
    @State var hudVisible = false
    @State var hudConfig = CustomProgressConfig()
    @Binding var backToCamera: Bool
    
    @State var goToOCRResults: Bool = false
    @State var recognizedText: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                photoPager
                EditorTabBar(dataSource: EditTabBarDataSource(tools: Constants.editTools), photoDataSource: dataSource)
            }
            goBackButton
            showPhotoLibrary
                .fullScreenCover(isPresented: $dataSource.isPresentingImagePicker, content: {
                    ImagePicker(sourceType: dataSource.sourceType, completionHandler: dataSource.didSelectImage)
                })
            CustomProgressView($hudVisible, config: hudConfig)
            PushView(destination: OCRResultsView(message: $recognizedText), isActive: $goToOCRResults) {
                EmptyView()
            }.hidden()
        }
        .onReceive(dataSource.progressPublisher) { data in
            switch data.showProgressType {
            case .error:
                hudConfig.title = "Error!"
                hudConfig.errorImage = "xmark.circle"
            case .info:
                hudConfig.title = "Info"
                hudConfig.warningImage = "info.circle"
            case .success:
                hudConfig.title = "Success"
                hudConfig.successImage = "checkmark.circle"
            }
            hudConfig.caption = data.progressViewMessage
            hudVisible = data.showProgressView
        }
        .onReceive(dataSource.dismissPublisher) { shoudBeDismissed in
            if shoudBeDismissed {
                print("Should be poped to camera")
            }
        }
        .onReceive(dataSource.ocrResultPublisher) { result in
            recognizedText = result.recognizedText
            goToOCRResults = result.goToOCRResults
        }
        .onReceive(dataSource.selectionPublisher, perform: { _ in
            dataSource.currentPage += 1
        })
        .edgesIgnoringSafeArea(.all)
    }
    
    private var showPhotoLibrary: some View {
        HStack {
            Spacer()
            Button(action: {
                dataSource.isPresentingImagePicker = true
            }, label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .frame(width: 40, height: 30, alignment: .leading)
                    .foregroundColor(.secondary)
            })
        }.offset(x: -20, y: -380)
    }
    
    private var goBackButton: some View {
        HStack {
            Spacer()
            Button(action: {
                dataSource.recognitionRequest?.cancel()
                backToCamera = true
                navStack.pop()
            }, label: {
                HStack {
                    Text("Back to camera")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            })
        }.offset(x: -275, y: -380)
    }
    
    private var photoPager: some View {
        return VStack {
            PageView(selection: $dataSource.selection, indexBackgroundDisplayMode: .always) {
                ForEach(dataSource.scannedDocs, id: \.id) { item in
                        VStack {
                            EditImageCell(dataSource: EditCellDataSource(scannedDoc: item))
                            Text(item.date.toString) 
                                .foregroundColor(Color(UIColor.systemGray))
                                .font(.headline)
                        }
                        .padding(EdgeInsets(top: 20, leading: 4, bottom: 10, trailing: 4))
                        .border(Color(UIColor.systemPurple).opacity(0.8), width: 1)
                }
           }
           .padding(.top, 120)
            Spacer()
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var mockedDocs: [ScannedDoc] {
        var docs: [ScannedDoc] = .init()
        let names = ["imageWithText", "slideWithText"]
        for _ in 0..<2 {
            names.forEach {
                docs.append(ScannedDoc(image: UIImage(named: $0)!.cgImage!, date: Date()))
            }
        }
        return docs
    }
    
    static var previews: some View {
        EditorView(dataSource: PhotoCollectionDataSource(scannedDocs: mockedDocs), backToCamera: .constant(false))
    }
}
