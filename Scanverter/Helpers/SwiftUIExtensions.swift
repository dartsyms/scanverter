import SwiftUI

extension View {
    func navigatePush(whenTrue toggle: Binding<Bool>) -> some View {
        NavigationLink(destination: self, isActive: toggle) { EmptyView() }
    }

    func navigatePush<H: Hashable>(when binding: Binding<H>, matches: H) -> some View {
        NavigationLink(destination: self, tag: matches, selection: Binding<H?>(binding)) { EmptyView() }
    }

    func navigatePush<H: Hashable>(when binding: Binding<H?>, matches: H) -> some View {
        NavigationLink(destination: self, tag: matches, selection: binding) { EmptyView() }
    }
}

extension Binding {
    func didSet(execute: @escaping (Value) -> Void) -> Binding {
        return Binding(
            get: { return self.wrappedValue },
            set: { self.wrappedValue = $0; execute($0) }
        )
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}
