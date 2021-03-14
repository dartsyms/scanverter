import SwiftUI

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(selection: .constant(0), content: { Text("Some text") })
    }
}

struct PageView<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
    @Binding var selection: SelectionValue
    private let indexDisplayMode: PageTabViewStyle.IndexDisplayMode
    private let indexBackgroundDisplayMode: PageIndexViewStyle.BackgroundDisplayMode
    private let content: () -> Content

    init(selection: Binding<SelectionValue>,
         indexDisplayMode: PageTabViewStyle.IndexDisplayMode = .automatic,
         indexBackgroundDisplayMode: PageIndexViewStyle.BackgroundDisplayMode = .automatic,
         @ViewBuilder content: @escaping () -> Content) {
        
        self._selection = selection
        self.indexDisplayMode = indexDisplayMode
        self.indexBackgroundDisplayMode = indexBackgroundDisplayMode
        self.content = content
    }

    var body: some View {
        TabView(selection: $selection) { content() }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: indexDisplayMode))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: indexBackgroundDisplayMode))
    }
}

extension PageView where SelectionValue == Int {
    init(selection: Binding<Int>, indexDisplayMode: PageTabViewStyle.IndexDisplayMode = .automatic,
         indexBackgroundDisplayMode: PageIndexViewStyle.BackgroundDisplayMode = .automatic,
         @ViewBuilder content: @escaping () -> Content) {
        
        self._selection = selection
        self.indexDisplayMode = indexDisplayMode
        self.indexBackgroundDisplayMode = indexBackgroundDisplayMode
        self.content = content
    }
}
