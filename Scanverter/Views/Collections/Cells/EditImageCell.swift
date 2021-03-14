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
                .aspectRatio(contentMode: .fit)
                .padding()

            Text(dataSource.scannedDoc.date.toString)
                .foregroundColor(Color(UIColor.systemGray))
                .font(.headline)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 80)
    }
}
