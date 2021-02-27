import SwiftUI

struct CreateFolderView: View {
    @Binding var showCreateDirectoryModal: Bool
    @Binding var folderName: String
    
    @State var isEditing: Bool = false
    @State var isSecured: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                Image(systemName: "folder.fill")
                    .resizable()
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                HStack {
                    Spacer()
                    Button(action: {
                        self.showCreateDirectoryModal = false
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .leading)
                        
                    })
                }.offset(x: -40, y: -10)
                HStack {
                    Text("Folder Name")
                        .font(.headline)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .offset(x: 40, y: 0)
                    Spacer()
                }
                TextField("Enter name", text: $folderName) { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
                
                HStack {
                    Text("Secure Lock")
                        .font(.headline)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .offset(x: 40, y: 0)
                    Spacer()
                    Toggle("", isOn: $isSecured)
                        .offset(x: -40, y: 0)
                }
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        self.showCreateDirectoryModal = false
                    }
                }) {
                    Text("Create Folder")
                }
                .frame(width: geometry.size.width - geometry.size.width/4, height: 20)
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(6)
                
                .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
            }
        }
    }
}

struct CreateFolderView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFolderView(showCreateDirectoryModal: .constant(true), folderName: .constant(""))
    }
}
