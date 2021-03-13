import SwiftUI

struct CreateFolderView: View {
    @Binding var showCreateDirectoryModal: Bool
    @Binding var folderName: String
    @Binding var isSecured: Bool
    
    @State private var canUseSecureLock: Bool = false
    @State var isEditing: Bool = false
    
    @State var showAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    
    private var onDismiss: (() -> Void)? = nil
    
    init(showCreateDirectoryModal: Binding<Bool>,
         folderName: Binding<String>,
         isSecured: Binding<Bool>,
         onDismiss: @escaping () -> Void) {
        self._showCreateDirectoryModal = showCreateDirectoryModal
        self._folderName = folderName
        self._isSecured = isSecured
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(UIColor.systemBackground))
                .frame(width: 360, height: 320)
                .zIndex(0)
            Circle()
                .trim(from: 0.5, to: 1)
                .fill(Color(UIColor.systemBackground))
                .frame(width: 140, height: 140)
                .overlay(Circle()
                            .stroke(Color(UIColor.label), lineWidth: 3))
                .offset(y: -160)
                .zIndex(1)
            Image("folder_icon")
                .resizable()
                .foregroundColor(.blue)
                .frame(width: 100, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .offset(y: -160)
                .zIndex(2)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.showCreateDirectoryModal = false
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .foregroundColor(Color(UIColor.systemGray))
                            .frame(width: 40, height: 40, alignment: .leading)
                        
                    })
                }.offset(x: -40, y: -10)
                HStack {
                    Text("Folder Name")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.label))
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
                .padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 40))
                
                HStack {
                    Text("Secure Lock")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.label))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .offset(x: 40, y: 0)
                    Spacer()
                    Toggle("", isOn: $isSecured.didSet(execute: { state in
                        checkIfCanBeLocked()
                    }))
                    .toggleStyle(SwitchToggleStyle(tint: Color(UIColor.systemBlue)))
                    .offset(x: -40, y: 0)
                }
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        self.showCreateDirectoryModal = false
                        onDismiss?()
                    }
                }) {
                    Text("Create Folder")
                }
                .frame(width: 290, height: 20)
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBlue), Color(UIColor.systemBlue)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(6)
                .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
            }
        }
        .padding(.top, 60)
    }
    
    private func checkIfCanBeLocked() {
        if !canUseSecureLock {
            let bioAuthentication = BiometricAuthentication()
            bioAuthentication.authenticateUser { (errorMessage) in
                if errorMessage != nil {
                    canUseSecureLock = false
                    isSecured = false
                    alertTitle = "Unable To Authenticate 😬"
                    alertMessage = errorMessage!
                    showAlert = true
                } else {
                    canUseSecureLock = true
                    isSecured = true
                    alertTitle = "Secure Access Enabled 😃"
                    alertMessage = "To access this folder you will be required to use face id"
                    showAlert = true
                }
            }
        }
    }
}

struct CreateFolderView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFolderView(showCreateDirectoryModal: .constant(true),
                         folderName: .constant(""),
                         isSecured: .constant(false),
                         onDismiss: {})
            .preferredColorScheme(.light)
        
        CreateFolderView(showCreateDirectoryModal: .constant(true),
                         folderName: .constant(""),
                         isSecured: .constant(false),
                         onDismiss: {})
            .preferredColorScheme(.dark)
    }
}
