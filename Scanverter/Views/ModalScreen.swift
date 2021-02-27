import SwiftUI

struct ModalScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Modal Screen")
                    Spacer()
                }
                Spacer()
            }
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .leading)
                        .foregroundColor(.gray)
                    
                })
            }.offset(x: -20, y: -350)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.red).opacity(0.2))
        .edgesIgnoringSafeArea(.all)
    }
}

struct ModalScreen_Previews: PreviewProvider {
    static var previews: some View {
        ModalScreen()
    }
}
