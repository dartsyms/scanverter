import SwiftUI
import VisionKit
import PDFKit

struct TextRecognizerScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingScannerSheet = false
    @State private var text: String = ""
    
    @State var isPresentingFolderChooser: Bool = false
    @State private var folderToSaveIn: Folder?
    @State private var savedScan: VNDocumentCameraScan?

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Text("Vision Kit Example")
                HStack(spacing: 55) {
                    saveToPdf
                        .sheet(isPresented: $isPresentingFolderChooser, onDismiss: {}) {
                            FoldersScreen(selectedFolder: $folderToSaveIn, calledFromSaving: true)
                        }
                        .opacity(0)
                    Spacer()
                    scanButton
                        .opacity(UIDevice.isSimulator ? 0.4 : 1)
                        .disabled(UIDevice.isSimulator)
                    Spacer()
                    closeButton
                }
                .offset(x: -30, y: 0)
                Text("Not working in simulator!").opacity(UIDevice.isSimulator ? 1 : 0)
                Spacer()
                Text(text)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .lineLimit(nil)
                Spacer()
            }
            .sheet(isPresented: self.$isShowingScannerSheet) { self.makeScannerView() }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .edgesIgnoringSafeArea(.all)
    }
    
    private var scanButton: some View {
        Button(action: openCamera) {
            Text("Scan")
                .foregroundColor(.white)
        }
        .frame(width: 40, height: 20)
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .background(Color(UIColor.darkGray))
        .cornerRadius(3.0)
    }
    
    private var closeButton: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("TextRecognizerScreenDismissed"), object: nil)
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: 30, height: 30, alignment: .leading)
                .foregroundColor(Color(UIColor.systemGray2))
        })
    }
    
    private var saveToPdf: some View {
        HStack {
            Spacer()
            Button(action: {
                isPresentingFolderChooser = true
            }, label: {
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .leading)
                    .foregroundColor(.gray)
            })
        }
    }
    
    private func openCamera() {
        isShowingScannerSheet = true
    }
    
    private func makeScannerView() -> TextScannerView {
        TextScannerView(completion: { textPerPage in
            if let text = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) {
//                self.text = text
                self.text = "Saved"
            }
            self.isShowingScannerSheet = false
        })
    }
}

struct TextRecognizerScreen_Previews: PreviewProvider {
    static var previews: some View {
        TextRecognizerScreen()
    }
}

