import SwiftUI

struct SettingsTemplateScreen: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Settings Screen")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.purple).opacity(0.2))
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {}, label: { }),
                            trailing: Button(action: {}, label: { }))
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTemplateScreen()
    }
}
