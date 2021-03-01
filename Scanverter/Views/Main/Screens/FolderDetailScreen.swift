import SwiftUI

struct FolderDetailScreen: View {
    @EnvironmentObject var navStack: NavigationStack
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Text("Folder Content goes here")
                        .font(.system(size: 20))
                        .bold()
                    
                    Button(action: {
                        self.navStack.pop()
                    }, label: {
                        Text("Back to folders")
                    })
                }
                Spacer()
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.green).opacity(0.2))
        .navigationBarTitle("Folder Detail Screen", displayMode: .inline)
        .navigationBarItems(leading: backButton,
                            trailing: trailingGroup)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var backButton: some View {
        Button(action: { self.navStack.pop() }, label: {
            HStack {
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color(UIColor.label))
                Text("Back")
                    .font(.callout)
                    .foregroundColor(Color(UIColor.label))
            }
        })
    }
    
    private var trailingGroup: some View {
        Button(action: {}, label: { })
    }
}

struct FolderDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailScreen()
    }
}
