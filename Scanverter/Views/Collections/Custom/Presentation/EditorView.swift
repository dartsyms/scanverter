import SwiftUI
import PDFKit
import Combine

struct EditorView: View {
    @EnvironmentObject var navStack: NavigationStack
    @StateObject var dataSource: PhotoCollectionDataSource
    
    @State var hudVisible = false
    @State var hudConfig = CustomProgressConfig()
    @Binding var backToCamera: Bool
    
    @State var goToOCRResults: Bool = false
    @State var recognizedText: String = ""
    @State var isPresentingFolderChooser: Bool = false
    
    @State private var pdfToSave: PDFDocument?
    @State private var folderToSaveIn: Folder?
    
    @State private var saveRequest: AnyCancellable?
    
    var body: some View {
        ZStack {
            VStack {
                photoPager
                EditorTabBar(dataSource: EditTabBarDataSource(tools: Constants.editTools), photoDataSource: dataSource)
            }
            goBackButton
                .fullScreenCover(isPresented: $dataSource.isPresentingImagePicker, content: {
                    ImagePicker(sourceType: dataSource.sourceType, completionHandler: dataSource.didSelectImage)
                })
            showPhotoLibrary
                .sheet(isPresented: $isPresentingFolderChooser, onDismiss: {
                    savePDFDocOnDismiss(asFileNamed: "\(folderToSaveIn?.name ?? "folder")-\(Date().toFileNameString)")
                }) { FoldersScreen(selectedFolder: $folderToSaveIn, calledFromSaving: true) }
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
        .onReceive(dataSource.pdfGenerationPublisher) { data in
            pdfToSave = data.pdfDoc
            isPresentingFolderChooser = data.isPresentingFolderChooser
        }
        .onReceive(dataSource.dismissPublisher) { _ in
            print("Should be poped to camera")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                backToCamera = true
                navStack.pop()
            }
        }
        .onReceive(dataSource.ocrResultPublisher) { result in
            recognizedText = result.recognizedText
            goToOCRResults = result.goToOCRResults
        }
        .onReceive(dataSource.selectionPublisher, perform: { _ in
            dataSource.currentPage = dataSource.selection
        })
        .onDisappear {
            saveRequest?.cancel()
            saveRequest = nil
        }
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
                if dataSource.scannedDocs.isEmpty {
                    Text("No more pages")
                } else {
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
           }
//           .padding(.top, 20)
//            Spacer()
        }
    }
    
    private func savePDFDocOnDismiss(asFileNamed named: String) {
        if let doc = pdfToSave, let folder = folderToSaveIn {
            saveRequest = dataSource.save(pdfDoc: doc, namedAs: named, in: folder)
                .receive(on: DispatchQueue.main)
                .sink { saved in
                    DispatchQueue.main.async {
                        self.dataSource.selectedImages.removeAll()
                    }
                    print("pdf file saved in folder")
                }
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
