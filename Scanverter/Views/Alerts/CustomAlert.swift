import SwiftUI

struct CustomAlert: View {
    @Binding var showingAlert: Bool
    @Binding var title: String
    @Binding var message: String
    
    var body: some View {
        alert(isPresented: $showingAlert, content: {
            Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        })
    }
}
