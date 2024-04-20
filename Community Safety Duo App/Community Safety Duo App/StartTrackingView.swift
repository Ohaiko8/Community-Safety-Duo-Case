import SwiftUI

struct StartTrackingView: View {
    enum ShareDuration: String, CaseIterable, Identifiable {
        case untilTurnedOff = "Until Turned Off"
        case untilDestination = "Until I Reach My Destination"
        case tenMinutes = "10 Minutes"
        case thirtyMinutes = "30 Minutes"
        case oneHour = "1 Hour"
        case twoHours = "2 Hours"
        case fiveHours = "5 Hours"
        
        var id: String { self.rawValue }
    }
    
    @State private var selectedDuration = ShareDuration.untilTurnedOff
    @State private var destination = ""
    @State private var selectedContacts: [String] = []
    @State private var triggerSOS = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Start Tracking Your Trip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                // Share location for
                HStack {
                    Text("Share for:")
                    Spacer()
                    Menu(selectedDuration.rawValue) {
                        ForEach(ShareDuration.allCases) { duration in
                            Button(action: {
                                selectedDuration = duration
                            }) {
                                Text(duration.rawValue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .foregroundColor(.skyBlue)
                }
                .padding(.horizontal)
                
                // Destination
                HStack {
                    Text("Destination:")
                    TextField("Enter destination (optional)", text: $destination)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                .padding(.horizontal)
                
                // Choose contacts to share location
                HStack {
                    Text("Choose contacts to share location with:")
                    Spacer()
                    Button(action: {
                        // implement Contact Picker
                    }) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Trigger SOS if I don't reach my destination
                Toggle(isOn: $triggerSOS) {
                    Text("Trigger SOS if I don't reach my destination")
                }
                .padding(.horizontal)
                .foregroundColor(.skyBlue)
                Spacer()
                
                // Continue Button
                HStack {
                    Spacer()
                    Button(action: {
                        // go to map
                    }) {
                        HStack {
                            Text("Continue")
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.skyBlue)
                        .cornerRadius(8)
                    }
                    .padding()
                }
                
                HStack {
                    Spacer()
                    Image("companion2")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .padding(.trailing, 40) 
                }
            }
            .padding()
        }
    }
}

struct StartTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        StartTrackingView()
    }
}


