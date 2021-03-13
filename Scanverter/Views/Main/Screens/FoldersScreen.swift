import SwiftUI
import ExyteGrid
import Combine
import PopupView

enum UnlockStatus {
    case failure
    case success
}

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
    
    @State private var canBeUnlocked: Bool = false
    @State private var showingBottomFloater = false
    
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
                            .frame(width: geometry.size.width - 20, height: geometry.size.height - geometry.size.height/2)
                        }
                        .navigationBarHidden(true)
                    }
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text("Deletion Alert!"),
                          message: Text("You're about to delete the folder."),
                          primaryButton: .destructive(Text("Delete")) {
                            dataSource.remove(indexSet: offsets)
                          },
                          secondaryButton: .cancel())
                }
//                .popup(isPresented: $showingBottomFloater, type: .floater(), position: .bottom, animation: Animation.spring(), autohideIn: 5) {
//                    createBottomFloater(withStatus: $canBeUnlocked.wrappedValue ? .success : .failure)
//                }
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
                                if item.isPasswordProtected && !canBeUnlocked {
                                    GridCell(dataSource: FolderCellDataSource(folder: item), folderSelector: dataSource.folderSelector)
                                        .onTapGesture { unlock() }
                                } else {
                                    PushView(destination: FolderDetailScreen(dataSource: DocsDataSource(files: item.files))) {
                                        GridCell(dataSource: FolderCellDataSource(folder: item), folderSelector: dataSource.folderSelector)
                                    }
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
                if item.isPasswordProtected && !canBeUnlocked {
                    ListCell(dataSource: FolderCellDataSource(folder: item), folderSelector: dataSource.folderSelector)
                        .padding(EdgeInsets(top: 20, leading: 4, bottom: 0, trailing: 2))
                } else {
                    HStack {
                        PushView(destination: FolderDetailScreen(dataSource: DocsDataSource(files: item.files))) {
                            ListCell(dataSource: FolderCellDataSource(folder: item), folderSelector: dataSource.folderSelector)
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 4, bottom: 0, trailing: 2))
                }
                
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
    
    func unlock() {
        tryUnlock() {
            DispatchQueue.main.async {
                self.dataSource.loadFolders()
//                self.showingBottomFloater = true
            }
        }
    }
    
    private func tryUnlock(completion: @escaping () -> Void) {
        if !canBeUnlocked {
            let bioAuthentication = BiometricAuthentication()
            bioAuthentication.authenticateUser { errorMessage in
                if errorMessage != nil {
                    canBeUnlocked = false
                    completion()
                } else {
                    canBeUnlocked = true
                    completion()
                }
            }
        }
    }
    
    func createBottomFloater(withStatus status: UnlockStatus) -> some View {
            HStack(spacing: 15) {
                Image("\(status == .failure ? "error" : "success")")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(10.0)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(status == .failure ? "Unable To Authenticate 😬" : "Secure Access Enabled 😃")")
                        .foregroundColor(Color(UIColor.label))
                        .fontWeight(.bold)

                    Text("\(status == .failure ? "The folder is locked." : "To access this folder you will be required to use FaceID/TouchID")")
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.label))
                }
            }
            .padding(15)
            .frame(width: 300, height: 160)
            .background(Color(hex: "ee6c4d"))
            .cornerRadius(20.0)
        }
}

struct FoldersScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoldersScreen(selectedFolder: .constant(nil), calledFromSaving: false)
    }
}
