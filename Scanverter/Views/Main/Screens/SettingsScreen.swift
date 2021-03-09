import SwiftUI

struct SettingsScreen : View {
    @ObservedObject var settings = SettingsDataSource()
    
    var body: some View {
            Form {
                Section {
                    SignInView()
                }
                Section {
                    BluetoothView(bluetooth: settings)
                    WiFiView(wifi: settings)
                }
                ForEach(Option.options,id: \.id) { settingOption in
                    OptionRow(option: settingOption)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(.purple).opacity(0.2))
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {}, label: { }),
                                trailing: Button(action: {}, label: { }))
    }
}
