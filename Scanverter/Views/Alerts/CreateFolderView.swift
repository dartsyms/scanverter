import SwiftUI

struct CreateFolderView: View {
    @Binding var showCreateDirectoryModal: Bool
    @Binding var folderName: String
    @Binding var isSecured: Bool
    
    @State var isEditing: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                HStack {
                    Image("folder_icon")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 100, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        self.showCreateDirectoryModal = false
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .foregroundColor(Color(UIColor.lightText))
                            .frame(width: 40, height: 40, alignment: .leading)
                        
                    })
                }.offset(x: 0, y: -100)
                HStack {
                    Text("Folder Name")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.label))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .offset(x: 20, y: 0)
                    Spacer()
                }
                TextField("Enter name", text: $folderName) { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                
                HStack {
                    Text("Secure Lock")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.label))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .offset(x: 20, y: 0)
                    Spacer()
                    Toggle("", isOn: $isSecured)
                        .toggleStyle(SwitchToggleStyle(tint: Color(UIColor.systemBlue)))
                        .offset(x: -20, y: 0)
                }
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        self.showCreateDirectoryModal = false
                    }
                }) {
                    Text("Create Folder")
                }
                .frame(width: geometry.size.width - geometry.size.width/3, height: 20)
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBlue), Color(UIColor.systemBlue)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(6)
                .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
            }
            .padding()
        }
    }
}

struct CreateFolderView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFolderView(showCreateDirectoryModal: .constant(true), folderName: .constant(""), isSecured: .constant(false))
    }
}
