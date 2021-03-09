import SwiftUI

struct SignInView : View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .foregroundColor(Color(UIColor.label))
                .cornerRadius(20)
                .frame(width: 60, height: 60)
                .clipped()
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Text("Sign in to your iPhone")
                    .foregroundColor(Color(UIColor.label))
                    .font(.system(size: 18))
                    .lineLimit(nil)
                Text("Set up iCloud, the App Store, and more.")
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
                    .lineLimit(nil)
            }
        }
    }
}

struct WiFiView : View {
    @ObservedObject var wifi: SettingsDataSource
    
    var body: some View {
        Group() {
            Picker(selection: $wifi.type, label: WifiContainer()) {
                ForEach(0 ..< wifi.types.count) {
                    Text(self.wifi.types[$0]).tag($0).font(.system(size: 20))
                }
            }
            if wifi.type == 1 {
                HStack {
                    Text("Waiting for the network coming up...")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                        .font(.system(.subheadline))
                    ActivityIndicator(style: .medium)
                }
            }
        }
    }
}

struct WifiContainer: View {
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .foregroundColor(Color(UIColor.label))
                .cornerRadius(12)
                .frame(width: 25, height: 25)
                .clipped()
                .aspectRatio(contentMode: .fit)
            Text("WiFi")
                .foregroundColor(Color(UIColor.label))
                .font(.system(size: 18))
        }
    }
}

struct BluetoothView: View {
    @ObservedObject var bluetooth: SettingsDataSource

    var body: some View {
        return NavigationLink(destination: ToggleBluetoothView(bluetooth: bluetooth)) {
            HStack() {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .foregroundColor(Color(UIColor.label))
                    .cornerRadius(12)
                    .frame(width: 25, height: 25)
                    .clipped()
                    .aspectRatio(contentMode: .fit)
                Text("Bluetooth")
                    .foregroundColor(Color(UIColor.label))
                    .font(.system(size: 18))
                    .frame(width: 150,height: 40, alignment: .leading)
                Spacer()
                Text(bluetooth.isBluetoothOn ? "On" : "Off")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
                    .font(.subheadline)
                    .frame(width: 120, height: 40, alignment: .trailing)
            }
        }
    }
}

struct ToggleBluetoothView: View {
   @ObservedObject var bluetooth: SettingsDataSource
    
    var body: some View {
        Form {
            Section(header: Text("Enable to connect nearby devices")) {
                Toggle(isOn: $bluetooth.isBluetoothOn) {
                    Text("Bluetooth")
                }
            
                if bluetooth.isBluetoothOn {
                    HStack {
                    Text("Searching for nearby devices...")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
                    .font(.system(.subheadline))
                    ActivityIndicator(style: .medium)
                    }
                }
            }
        }
    }
}

struct OptionRow: View {
    let option: Option
    var body: some View {
        Group() {
            if option.isAddSection {
                Section {
                    OptionSettingsView(option: option)
                }
            } else {
                OptionSettingsView(option: option)
            }
        }
    }
}

struct OptionSettingsView : View {
    let option: Option
    
    var body: some View {
        return NavigationLink(destination: OptionInnerDetail(option: option)) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .foregroundColor(Color(UIColor.label))
                    .cornerRadius(12)
                    .frame(width: 25, height: 25)
                    .clipped()
                    .aspectRatio(contentMode: .fit)
                Text(option.title)
                    .foregroundColor(Color(UIColor.label))
                    .font(.system(size: 18))
            }
        }
    }
}

struct OptionInnerDetail: View {
    let option: Option
    var body: some View {
        Form {
            ForEach(option.values,id: \.title) { valuesOption in
                OptionInnerView(value: valuesOption)
            }
        }
        .navigationBarTitle(Text(option.title), displayMode: .inline)
    }
}

struct OptionInnerView: View {
    let value: InnerOptionValues
    var body: some View {
        Group() {
            if value.isAddSection && !value.isUseToggle {
                Section(header: Text(value.headerTitle)) {
                    InnerView(value: value)
                }
            } else if !value.isAddSection && value.isUseToggle {
                ToggleView(value: value)
            } else if value.isAddSection && value.isUseToggle {
                Section(header: Text(value.headerTitle)) {
                    ToggleView(value: value)
                }
            } else {
                InnerView(value: value)
            }
        }
    }
}

struct ToggleView: View {
    let value: InnerOptionValues
    @ObservedObject var toggle = SettingsDataSource()
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .foregroundColor(Color(UIColor.label))
                .cornerRadius(12)
                .frame(width: 25, height: 25)
                .clipped()
                .aspectRatio(contentMode: .fit)
            
            Toggle(isOn: $toggle.isToggleOn) {
                Text(value.title)
                    .foregroundColor(Color(UIColor.label))
                    .font(.system(size: 18))
            }
        }
    }
}

struct InnerView: View {
    let value: InnerOptionValues
    
    var body: some View {
        return NavigationLink(destination: EndView(value: value)) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .foregroundColor(Color(UIColor.label))
                    .cornerRadius(12)
                    .frame(width: 25, height: 25)
                    .clipped()
                    .aspectRatio(contentMode: .fit)
                Text(value.title)
                    .foregroundColor(Color(UIColor.label))
                    .font(.system(size: 18))
            }
        }
    }
}

struct EndView: View {
    let value: InnerOptionValues
    
    var body: some View {
        return NavigationLink(destination: EndView(value: value)) {
            
            Text("Not Implemented Yet")
                .font(.system(size: 25))
                .foregroundColor(Color(UIColor.label))
        } .navigationBarTitle(Text(value.title), displayMode: .inline)
    }
}
