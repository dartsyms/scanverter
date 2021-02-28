import Combine

final class EditTabBarDataSource: ObservableObject {
    @Published private(set) var editTools: [EditTool]
    
    init(tools: [EditTool]) {
        self.editTools = tools
    }
}
