import SwiftUI
import ExyteGrid

struct EditorView: View {
    @EnvironmentObject var navStack: NavigationStack
    @StateObject var dataSource: PhotoCollectionDataSource
    
    @State private var flow: GridFlow = .rows
    @State var hudVisible = false
    @State var hudConfig = CustomProgressConfig()
    @Binding var backToCamera: Bool
    
    var body: some View {
        ZStack {
            VStack {
                if flow == .rows {
                    photoGrid
                } else {
                    photoList
                }
                EditorTabBar(dataSource: EditTabBarDataSource(tools: Constants.editTools), photoDataSource: dataSource)
            }
            goBackButton
            switchFlowButton
            CustomProgressView($hudVisible, config: hudConfig)
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
        .edgesIgnoringSafeArea(.all)
    }
    
    private var switchFlowButton: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation {
                    flow = flow == .rows ? .columns : .rows
                }
                
            }, label: {
                Image(systemName: flow == .rows ? "square.grid.3x3" : "list.bullet")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .leading)
                    .foregroundColor(.secondary)
                
            })
        }.offset(x: -20, y: -380)
    }
    
    private var goBackButton: some View {
        HStack {
            Spacer()
            Button(action: {
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
    
    private var photoGrid: some View {
        VStack {
            Grid(tracks: 3) {
                ForEach(dataSource.scannedDocs, id: \.id) { item in
                        VStack {
                            EditImageCell(dataSource: EditCellDataSource(scannedDoc: item))
                            Text(item.date.toString)
                                .foregroundColor(Color.gray)
                                .font(.caption)
                        }
                        .padding(EdgeInsets(top: 20, leading: 4, bottom: 0, trailing: 4))
    //                    .border(Color.secondary, width: 1)
                }
            }
            .padding(.top, 120)
            .gridContentMode(.scroll)
            .gridFlow(.rows)
            Spacer()
        }
    }
    
    private var photoList: some View {
        List {
            ForEach(dataSource.scannedDocs, id: \.id) { item in
                HStack {
                    EditImageCell(dataSource: EditCellDataSource(scannedDoc: item))
                    Text(item.date.toString)
                        .foregroundColor(Color.gray)
                        .font(.caption)
                }
                .padding(EdgeInsets(top: 20, leading: 4, bottom: 0, trailing: 2))
            }
        }
        .padding(.top, 90)
        .listStyle(PlainListStyle())
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
