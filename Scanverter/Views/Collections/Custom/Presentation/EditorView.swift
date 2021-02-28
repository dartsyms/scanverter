import SwiftUI
import ExyteGrid

struct EditorView: View {
    @StateObject var dataSource: PhotoCollectionDataSource
    
    @State private var flow: GridFlow = .rows
    
    var body: some View {
        ZStack {
            VStack {
                if flow == .rows {
                    photoGrid
                } else {
                    photoList
                }
                EditorTabBar(dataSource: EditTabBarDataSource(tools: Constants.editTools))
            }
            swithFlowButton
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var swithFlowButton: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation {
                    flow = flow == .rows ? .columns : .rows
                }
                
            }, label: {
                Image(systemName: flow == .rows ? "square.grid.3x3" : "list.bullet")
                    .resizable()
                    .frame(width: 25, height: 25, alignment: .leading)
                    .foregroundColor(.gray)
                
            })
        }.offset(x: -350, y: -380)
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
        EditorView(dataSource: PhotoCollectionDataSource(scannedDocs: mockedDocs))
    }
}
