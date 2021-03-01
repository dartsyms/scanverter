import SwiftUI

struct EditorTabBar: View {
    @StateObject var dataSource: EditTabBarDataSource
    @StateObject var photoDataSource: PhotoCollectionDataSource
    
    var body: some View {
            HStack(spacing: 40) {
                ForEach(dataSource.editTools) { tool in
                    VStack {
                        EditToolCell(dataSource: EditToolCellDataSource(tool: tool), photoDataSource: photoDataSource)
                        .padding(.top, 6)
                        .padding(.bottom, 6)
                    }
                }
        }
        .frame(minHeight: 70)
    }
}

struct EditorTabBar_Previews: PreviewProvider {
    static var previews: some View {
        EditorTabBar(dataSource: EditTabBarDataSource(tools: Constants.editTools),
                     photoDataSource: PhotoCollectionDataSource(scannedDocs: Constants.mockedDocs))
            .preferredColorScheme(.dark)
    }
}
