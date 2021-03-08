import SwiftUI
import PDFKit

struct PDFViewverUI: View {
    @EnvironmentObject var navStack: NavigationStack
    
    var url: URL
   
    var body: some View {
        VStack {
            PDFViewer(url)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .navigationBarTitle("PDF Viewer", displayMode: .inline)
        .navigationBarItems(leading: backButton,
                            trailing: trailingGroup)
        .edgesIgnoringSafeArea(.bottom)
        
    }
    
    private var backButton: some View {
        Button(action: { self.navStack.pop() }, label: {
            HStack {
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color(UIColor.label))
                Text("Back")
                    .font(.callout)
                    .foregroundColor(Color(UIColor.label))
            }
        })
    }
    
    private var trailingGroup: some View {
        Button(action: {}, label: { })
    }
}

struct PDFViewer: UIViewRepresentable {
    var url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func makeUIView(context: Context) -> UIView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
}
