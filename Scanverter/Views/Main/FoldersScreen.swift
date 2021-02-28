import SwiftUI
import ExyteGrid

struct FoldersScreen: View {
    @State private var flow: GridFlow = .rows
    @State private var showCreateFolderDialogue: Bool = false
    @State private var newFolderName: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Folders Screen").font(.system(size: 20)).bold()
                        Spacer()
                    }
                    HStack {
                        NavigationLink(destination: DetailScreen()) { Text("Show detail") }
                    }
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.black).opacity(0.3)
                .navigationBarTitle("Folders", displayMode: .inline)
                .navigationBarItems(leading: createFolderButton, trailing: trailingButtonGroup)
                
                if $showCreateFolderDialogue.wrappedValue {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        CreateFolderView(showCreateDirectoryModal: $showCreateFolderDialogue, folderName: $newFolderName)
                        .frame(width: geometry.size.width - geometry.size.width/4, height: geometry.size.height - geometry.size.height/2)
                        .background(Color.white)
                        .cornerRadius(20).shadow(radius: 20)
                    }.navigationBarHidden(true)
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
}

struct FoldersScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoldersScreen()
    }
}
