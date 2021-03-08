import SwiftUI
import ExyteGrid
import PDFKit

struct FolderDetailScreen: View {
    @EnvironmentObject var navStack: NavigationStack
    
    @StateObject var dataSource: DocsDataSource
    @State private var flow: GridFlow = .rows
    
    @State private var showDeleteAlert: Bool = false
    @State private var offsets: IndexSet?
    
    var body: some View {
        NavigationStackView {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        if flow == .rows {
                            filesGrid
                        } else {
                            filesList
                        }
                    }
                }
                .alert(isPresented: self.$showDeleteAlert) {
                    Alert(title: Text("Deletion Alert!"),
                          message: Text("You're about to delete the file."),
                          primaryButton: .destructive(Text("Delete")) {
                            dataSource.remove(indexSet: offsets)
                          },
                          secondaryButton: .cancel())
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .navigationBarTitle("Files (Scanned)", displayMode: .inline)
            .navigationBarItems(leading: backButton,
                                trailing: trailingGroup)
            .edgesIgnoringSafeArea(.bottom)
        }
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
    
    private var filesGrid: some View {
        VStack {
            Grid(tracks: 3) {
                ForEach(dataSource.files, id: \.uid) { item in
                        VStack {
                            PushView(destination: PDFViewverUI(url: dataSource.getUrl(forDoc: item)!)) {
                                FileGridCell(dataSource: FileCellDataSource(file: item))
                            }
                        }
                        .padding(EdgeInsets(top: 20, leading: 4, bottom: 0, trailing: 4))
                }
            }
            .padding(.top, 120)
            .gridContentMode(.scroll)
            .gridFlow(.rows)
            Spacer()
        
        }
    }
    
    private var filesList: some View {
        List {
            ForEach(dataSource.files, id: \.uid) { item in
                HStack {
                    FileListCell(dataSource: FileCellDataSource(file: item))
                }
                .padding(EdgeInsets(top: 20, leading: 4, bottom: 0, trailing: 2))
            }
            .onDelete(perform: delete)
        }
        .padding(.top, 90)
        .listStyle(PlainListStyle())
    }
    
    func delete(at offsets: IndexSet) {
        self.showDeleteAlert = true
        self.offsets = offsets
    }
}

struct FolderDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailScreen()
    }
}
