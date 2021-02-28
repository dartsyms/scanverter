import SwiftUI

struct EditImageCell_Previews: PreviewProvider {
    static var previews: some View {
        EditImageCell(dataSource: EditCellDataSource(scannedDoc: ScannedDoc(image: UIImage(named: "slideWithText")!.cgImage!, date: Date())))
    }
}

struct EditImageCell: View {
    @StateObject var dataSource: EditCellDataSource
    
    var body: some View {
        VStack(alignment: .center) {
            Image(uiImage: UIImage(cgImage: dataSource.scannedDoc.image))
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
        }
    }
}
