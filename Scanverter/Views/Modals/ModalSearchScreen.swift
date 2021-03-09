import SwiftUI

struct ModalSearchScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataSource: SearchDataSource = .init()
    
    @State private var searchText : String = ""
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    SearchBar(text: $searchText, placeholder: "Search files")
                        .padding(EdgeInsets(top: 40, leading: 10, bottom: 20, trailing: 0))
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .leading)
                            .foregroundColor(.gray)
                    })
                    .padding(EdgeInsets(top: 40, leading: 0, bottom: 20, trailing: 20))
                }
                
                List {
                    ForEach(dataSource.files.filter {
                        self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                    }, id: \.self) { item in
                        Text(item.name)
                    }
                }.navigationBarTitle(Text("File Search"))
            }
            .onAppear { dataSource.loadAll() }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ModalSearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        ModalSearchScreen()
            .previewDevice("iPhone 11 Pro")
    }
}

