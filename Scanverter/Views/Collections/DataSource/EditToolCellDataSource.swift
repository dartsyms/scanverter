import Combine

final class EditToolCellDataSource: ObservableObject {
    @Published private(set) var editTool: EditTool
    
    init(tool: EditTool) {
        self.editTool = tool
    }
}
