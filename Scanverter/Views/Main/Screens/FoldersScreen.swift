import SwiftUI
import ExyteGrid
import Combine

struct FoldersScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var dataSource: FoldersDataSource = .init()
    @State private var flow: GridFlow = .rows
    @State private var showCreateFolderDialogue: Bool = false
    @State private var newFolderName: String = ""
    @State private var isSecureLocked: Bool = false
    
    @State private var showDeleteAlert: Bool = false
    @State private var offsets: IndexSet?
    @State private var showDeleteIcon: Bool = false
    
    @Binding var selectedFolder: Folder?
    var calledFromSaving: Bool = false
    
    @State private var subscriptions: Set<AnyCancellable> = .init()
    
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
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TextRecognizerScreenDismissed")), perform: { _ in
                        dataSource.loadFolders()
                    })
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
                                        .receive(on: DispatchQueue.main)
                                        .sink { done in
                                            if done {
                                                newFolderName = ""
                                            }
                                        }
                                        .store(in: &subscriptions)
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
        .disabled(calledFromSaving ? true : false)
        .opacity(calledFromSaving ? 0 : 1)
    }
    
    private var foldersGrid: some View {
        VStack {
            Grid(tracks: 3) {
                ForEach(dataSource.folders, id: \.uid) { item in
                        VStack {
                            if calledFromSaving {
                                GridCell(dataSource: FolderCellDataSource(folder: item), folderSelector: dataSource.folderSelector)
                                    .onTapGesture {
                                        dataSource.setSelected(folder: item)
                                        selectedFolder = item
                                        presentationMode.wrappedValue.dismiss()
                                    }
                            } else {
                                PushView(destination: FolderDetailScreen(dataSource: DocsDataSource(files: item.files))) {
                                    GridCell(dataSource: FolderCellDataSource(folder: item), folderSelector: dataSource.folderSelector)
                                }
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
                    PushView(destination: FolderDetailScreen(dataSource: DocsDataSource(files: item.files))) {
                        ListCell(dataSource: FolderCellDataSource(folder: item), folderSelector: dataSource.folderSelector)
                    }
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

struct FoldersScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoldersScreen(selectedFolder: .constant(nil), calledFromSaving: false)
    }
}
