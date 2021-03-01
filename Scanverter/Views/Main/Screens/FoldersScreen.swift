import SwiftUI
import ExyteGrid
import Combine

struct FoldersScreen: View {
    @StateObject private var dataSource: FoldersDataSource = .init()
    @State private var flow: GridFlow = .rows
    @State private var showCreateFolderDialogue: Bool = false
    @State private var newFolderName: String = ""
    @State private var isSecureLocked: Bool = false
    
    @State private var showDeleteAlert: Bool = false
    @State private var offsets: IndexSet?
    @State private var showDeleteIcon: Bool = false
    
    var body: some View {
        NavigationStackView {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        if flow == .rows {
                            foldersGrid
                        } else {
                            foldersList
                        }
                    }
                    .onAppear {
                        dataSource.loadFolders()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .navigationBarTitle("Folders", displayMode: .inline)
                    .navigationBarItems(leading: createFolderButton, trailing: trailingButtonGroup)
                    
                    if $showCreateFolderDialogue.wrappedValue {
                        ZStack {
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                            CreateFolderView(showCreateDirectoryModal: $showCreateFolderDialogue, folderName: $newFolderName, isSecured: $isSecureLocked) {
                                    dataSource.createNewFolder(withName: newFolderName, secureLock: isSecureLocked)
                            }
                            .frame(width: geometry.size.width - geometry.size.width/4, height: geometry.size.height - geometry.size.height/2)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(20).shadow(radius: 20)
                        }
                        .navigationBarHidden(true)
                    }
                }
                .alert(isPresented: self.$showDeleteAlert) {
                    Alert(title: Text("Deletion Alert!"),
                          message: Text("You're about to delete the folder."),
                          primaryButton: .destructive(Text("Delete")) {
                            dataSource.remove(indexSet: offsets)
                          },
                          secondaryButton: .cancel())
                }
            }
        }
    }
    
    private var createFolderButton: some View {
        Button(action: {
            withAnimation {
                showCreateFolderDialogue.toggle()
            }
        }, label: { Image(systemName: "filemenu.and.cursorarrow").foregroundColor(.primary) })
    }
    
    private var trailingButtonGroup: some View {
        HStack {
            Button(action: {
                
            }, label: { Image(systemName: "pencil.circle").foregroundColor(.primary) })
            
            Button(action: {
                withAnimation {
                    flow = flow == .rows ? .columns : .rows
                }
            }, label: { Image(systemName: flow == .rows ? "square.grid.3x3" : "list.bullet").foregroundColor(.primary) })
        }
    }
    
    private var foldersGrid: some View {
        VStack {
            Grid(tracks: 3) {
                ForEach(dataSource.folders, id: \.uid) { item in
                        VStack {
                            PushView(destination: FolderDetailScreen()) {
                                GridCell(dataSource: FolderCellDataSource(folder: item))
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
    
    private var foldersList: some View {
        List {
            ForEach(dataSource.folders, id: \.uid) { item in
                HStack {
                    PushView(destination: FolderDetailScreen()) {
                        ListCell(dataSource: FolderCellDataSource(folder: item))
                    }
                }
                .padding(EdgeInsets(top: 20, leading: 4, bottom: 0, trailing: 2))
            }.onDelete(perform: delete)
        }
        .padding(.top, 90)
        .listStyle(PlainListStyle())
    }
    
    func delete(at offsets: IndexSet) {
        self.showDeleteAlert = true
        self.offsets = offsets
    }
}

struct FoldersScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoldersScreen()
    }
}
