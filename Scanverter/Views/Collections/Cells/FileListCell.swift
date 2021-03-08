import SwiftUI

struct FileListCell_Previews: PreviewProvider {
    static var previews: some View {
        FileListCell(dataSource: FileCellDataSource(file: DocFile(name: "Some pdf",
                                                                  date: Date(),
                                                                  uid: UUID(),
                                                                  parent: Folder(name: "Some folder",
                                                                                 date: Date(),
                                                                                 isPasswordProtected: false,
                                                                                 uid: UUID(),
                                                                                 files: []))))
    }
}

struct FileListCell: View {
    @StateObject var dataSource: FileCellDataSource
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "newspaper.fill")
                .resizable()
                .foregroundColor(Color(UIColor.systemBlue))
                .frame(maxWidth: 80, maxHeight: 60)
            VStack(alignment: .leading, spacing: 15) {
                Text(dataSource.file.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.label))
                    .padding([.top, .leading, .trailing, .bottom], 5)
                    .offset(x: 0, y: /*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                HStack {
                    Text(dataSource.file.date.toString)
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(Color(UIColor.systemGray))
                    .padding([.leading, .bottom], 5)
                }
            }
        }
    }
}
