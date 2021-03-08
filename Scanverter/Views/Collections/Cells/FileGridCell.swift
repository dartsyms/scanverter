import SwiftUI

struct FileGridCell_Previews: PreviewProvider {
    static var previews: some View {
        FileGridCell(dataSource: FileCellDataSource(file: DocFile(name: "Some pdf",
                                                                  date: Date(),
                                                                  uid: UUID(),
                                                                  parent: Folder(name: "Some folder",
                                                                                 date: Date(),
                                                                                 isPasswordProtected: false,
                                                                                 uid: UUID(),
                                                                                 files: []))))
    }
}

struct FileGridCell: View {
    @StateObject var dataSource: FileCellDataSource
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "newspaper.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(UIColor.systemBlue))
                .frame(maxWidth: 80, maxHeight: 60)
            Text(dataSource.file.name.split(separator: ".").dropLast().joined())
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(Color(UIColor.label))
                .padding([.leading, .trailing], 5)
            VStack(alignment: .center) {
                Text(dataSource.file.date.toString)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color(UIColor.systemGray))
                    .padding([.bottom], 5)
            }
        }
    }
}
