import SwiftUI

struct EditorTabBar_Previews: PreviewProvider {
    static var previews: some View {
        EditorTabBar(dataSource: EditTabBarDataSource(tools: Constants.editTools))
            .preferredColorScheme(.dark)
    }
}

struct EditorTabBar: View {
    @StateObject var dataSource: EditTabBarDataSource
    
    
    var body: some View {
            HStack(spacing: 40) {
                ForEach(dataSource.editTools) { tool in
                    VStack {
                        EditToolCell(dataSource: EditToolCellDataSource(tool: tool))
                        .padding(.top, 6)
                        .padding(.bottom, 6)
                    }
                }
        }
        .frame(minHeight: 70)
    }
}


