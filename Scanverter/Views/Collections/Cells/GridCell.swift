import SwiftUI

struct GridCell_Previews: PreviewProvider {
    static var previews: some View {
        GridCell(dataSource: FolderCellDataSource(folder: Folder(name: "TestFolder", date: Date(), isPasswordProtected: false, uid: UUID())))
    }
}

struct GridCell: View {
    @StateObject var dataSource: FolderCellDataSource
    
    @State private var numberOfItems: Int = 4
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(UIColor.systemBlue))
                .frame(maxWidth: 80, maxHeight: 60)
            Text(dataSource.folder.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(UIColor.label))
                .padding([.leading, .trailing], 5)
            VStack(alignment: .center) {
                Text(dataSource.folder.date.toString)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color(UIColor.systemGray))
                Text("(\(numberOfItems) items)")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color(UIColor.systemGray))
                .padding([.bottom], 5)
            }
        }
    }
}


