import SwiftUI

struct SettingsView: View {
    // Toggle switches
    @State private var autoSOSMicrophoneAccess = false
    @State private var sendSMSEmergencyContacts = false
    @State private var locationSharing = false
    @State private var panicButtonAlertModeIndex = 0
    private let panicButtonAlertModes = ["Sound", "Vibrations", "Sound and Vibrations"]
    @State private var emergencySMSContent = "I need help!"

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                        .padding(.top, 30)
                        .padding(.horizontal)
                }
            }
            
            SettingsRow(title: "AI AutoSOS",
                        explanation: "Allow AI to listen and send SOS",
                        isToggled: $autoSOSMicrophoneAccess)

            SettingsRow(title: "Location Sharing ",
                        explanation: "Share your location when SOS is activated",
                        isToggled: $locationSharing)

            SettingsRow(title: "Send SOS message",
                        explanation: "Automatically notify your emergency contacts via SMS",
                        isToggled: $sendSMSEmergencyContacts)

            SettingsDropdownRow(title: "SOS Alert Preference",
                                explanation: "Choose your preferred method of receiving alerts when the panic button is pressed.",
                                selectedIndex: $panicButtonAlertModeIndex,
                                options: panicButtonAlertModes)

            Text("Customize your SOS message")
                .font(.headline)
                .padding(.leading)
                .foregroundColor(.primary)
            Text("Edit the content of the emergency SOS message sent to your emergency contacts.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.leading)

            TextField("Enter emergency SMS content", text: $emergencySMSContent)
                .padding(10)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxHeight: 100)

            Spacer()

            Button(action: {
                // Action to save settings
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.skyBlue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 10)
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct SettingsRow: View {
    var title: String
    var explanation: String
    @Binding var isToggled: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .padding(.leading)
                    .foregroundColor(.primary)
                Text(explanation)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            Spacer()
            Toggle("", isOn: $isToggled)
                .padding(.trailing)
                .onTapGesture {
                }
                .toggleStyle(SwitchToggleStyle(tint: .skyBlue))
        }
    }
}

struct SettingsDropdownRow: View {
    var title: String
    var explanation: String
    @Binding var selectedIndex: Int
    var options: [String]

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .padding(.leading)
                    .foregroundColor(.primary)
                Text(explanation)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            Spacer()
            Picker("", selection: $selectedIndex) {
                ForEach(0..<options.count) { index in
                    Text(options[index]).tag(index)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.trailing)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
