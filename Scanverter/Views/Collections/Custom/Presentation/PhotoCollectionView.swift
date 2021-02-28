import SwiftUI

struct PhotoCollectionView: View {
    @StateObject var dataSource: PhotoCollectionDataSource
    
    typealias DocRow = CollectionRow<Int, ScannedDoc>
    typealias ToolRow = CollectionRow<Int, EditTool>
    
    @State var docRows: [DocRow] = .init()
    @State var toolsRow: [ToolRow] = .init()
    
    private func composeElements() {
//        let result = dataSource.scannedDocs.chunked(into: 5)
        let result = mockedDocs.chunked(into: 5)
        var section = 0
        result.forEach {
            docRows.append(DocRow(section: section, items: $0))
            section += 1
        }
    }
    
    private func composeTools() {
        toolsRow.append(ToolRow(section: 0, items: dataSource.tools))
    }
    
    private var mockedDocs: [ScannedDoc] {
        var docs: [ScannedDoc] = .init()
        let names = ["imageWithText", "slideWithText"]
        for _ in 0..<2 {
            names.forEach {
                docs.append(ScannedDoc(image: UIImage(named: $0)!.cgImage!, date: Date()))
            }
        }
        return docs
    }
    
    var body: some View {
        VStack {
            CollectionView(rows: docRows) { sectionIndex, layoutEnvironment in
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                            heightDimension: .absolute(40)),
                                                                         elementKind: UICollectionView.elementKindSectionHeader,
                                                                         alignment: .topLeading)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [header]
                return section
            } cell: { indexPath, item in
                EditImageCell(dataSource: EditCellDataSource(scannedDoc: item))
            } supplementaryView: { kind, indexPath in
                Text("Section \(indexPath.section)")
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 90)
            .ignoresSafeArea(.all)
            .onAppear(perform: composeElements)
            
            Spacer()
            
            CollectionView(rows: toolsRow) { sectionIndex, layoutEnvironment in
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.orthogonalScrollingBehavior = .none
                return section
            } cell: { indexPath, item in
                EditToolCell(dataSource: EditToolCellDataSource(tool: item))
            } supplementaryView: { kind, indexPath in
                Text("Section \(indexPath.section)")
            }
            .frame(maxWidth: .infinity, maxHeight: 90)
            .ignoresSafeArea(.all)
            .onAppear(perform: composeTools)
        }
    }
}

//struct PhotoCollectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoCollectionView()
//    }
//}
