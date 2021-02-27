import SwiftUI

struct FoldersScreen: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Folders Screen")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            HStack {
                NavigationLink(destination: DetailScreen()) { Text("Show detail") }
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.yellow).opacity(0.2))
        .navigationBarTitle("Folders", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {}, label: { Image(systemName: "filemenu.and.cursorarrow").foregroundColor(.primary) }),
                            trailing: Button(action: {}, label: { Image(systemName: "pencil.circle").foregroundColor(.primary) }))
    }
}

struct FoldersScreen_Previews: PreviewProvider {
    static var previews: some View {
        FoldersScreen()
    }
}
