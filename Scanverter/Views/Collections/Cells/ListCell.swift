import SwiftUI

struct ListCell_Previews: PreviewProvider {
    static var previews: some View {
        ListCell(dataSource: GridCellDataSource(folder: Folder(name: "TestFolder", date: Date(), isPasswordProtected: false, uid: UUID())))
    }
}

struct ListCell: View {
    @StateObject var dataSource: GridCellDataSource
    
    @State private var numberOfItems: Int = 4
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "folder.fill")
                .resizable()
                .foregroundColor(.blue)
                .frame(maxWidth: 120, maxHeight: 100)
            
            VStack(alignment: .leading, spacing: 15) {
                Text(dataSource.folder.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding([.top, .leading, .trailing, .bottom], 5)
                    .offset(x: 0, y: /*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                HStack {
                    Text(dataSource.folder.date.toString)
                        .fontWeight(.regular)
                        .foregroundColor(.gray)
                    .padding([.leading, .bottom], 5)
                    Text("(\(numberOfItems) items)")
                        .fontWeight(.regular)
                        .foregroundColor(.gray)
                    .padding([.trailing, .bottom], 5)
                }
                
            }
            
        }
    }
}
