import SwiftUI

struct DetailScreen: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Detail Screen")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.green).opacity(0.2))
        .navigationBarTitle("Detail Screen", displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct DetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailScreen()
    }
}
