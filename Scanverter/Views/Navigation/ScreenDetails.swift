import SwiftUI

struct DetailScreen: View {
    @EnvironmentObject var navStack: NavigationStack
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Text("Detail Screen")
                        .font(.system(size: 20))
                        .bold()
                    
                    Button(action: {
                        self.navStack.pop()
                    }, label: {
                        Text("Back to camera")
                    })
                }
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
