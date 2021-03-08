import SwiftUI

struct GridCell_Previews: PreviewProvider {
    static var previews: some View {
        GridCell(dataSource: FolderCellDataSource(folder: Folder(name: "TestFolder", date: Date(), isPasswordProtected: false, uid: UUID(), files: [])), folderSelector: FolderSelector())
    }
}

struct GridCell: View {
    @StateObject var dataSource: FolderCellDataSource
    
    @State private var isSelected: Bool = false
    
    var folderSelector: FolderSelector

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(isSelected ? Color(UIColor.systemRed) : Color(UIColor.systemBlue))
                .frame(maxWidth: 80, maxHeight: 60)
            Text(dataSource.folder.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(Color(UIColor.label))
                .padding([.leading, .trailing], 5)
            VStack(alignment: .center) {
                Text(dataSource.folder.date.toString)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color(UIColor.systemGray))
                Text("(\(dataSource.folder.files.count) \(dataSource.folder.files.count == 1 ? "item" : "items"))")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color(UIColor.systemGray))
                .padding([.bottom], 5)
            }
        }
        .onReceive(folderSelector.publisher) { selection in
            isSelected = selection.id == dataSource.folder.uid.uuidString && selection.selected
        }
    }
}


