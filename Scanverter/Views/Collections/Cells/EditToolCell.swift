import SwiftUI

struct EditToolCell_Previews: PreviewProvider {
    static var previews: some View {
        let tools = [
            EditTool.init(.add, image: UIImage(named: "addPageButton")!),
            EditTool.init(.crop, image: UIImage(named: "cropButton")!),
            EditTool.init(.delete, image: UIImage(named: "deletePageButton")!),
            EditTool.init(.ocr, image: UIImage(named: "ocrButton")!)
        ]
        EditToolCell(dataSource: EditToolCellDataSource(tool: EditTool(tools.last!.type, image: tools.last!.image)))
    }
}

struct EditToolCell: View {
    @StateObject var dataSource: EditToolCellDataSource
    
    var body: some View {
        VStack(alignment: .center) {
            Image(uiImage: dataSource.editTool.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 60, maxHeight: 60)
            Text(dataSource.editTool.type.tool)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(UIColor.themeIndigoDark()))
                .offset(x: 0, y: -10)
        }
    }
}
