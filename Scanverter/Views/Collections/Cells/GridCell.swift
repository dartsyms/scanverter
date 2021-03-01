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
                .foregroundColor(.blue)
                .frame(maxWidth: 100, maxHeight: 80)
            Text(dataSource.folder.name)
                .fontWeight(.semibold)
                .padding([.leading, .trailing], 5)
            VStack {
                Text(dataSource.folder.date.toString)
                    .fontWeight(.regular)
                    .foregroundColor(.gray)
                .padding([.leading, .bottom], 5)
                Text("(\(numberOfItems) items)")
                    .fontWeight(.regular)
                    .foregroundColor(.gray)
                .padding([.trailing, .bottom], 5)
            }s
        }
    }
}


