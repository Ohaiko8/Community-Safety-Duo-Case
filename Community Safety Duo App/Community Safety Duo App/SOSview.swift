import SwiftUI
struct SOSView: View {
    @State private var timerCount = 10
    @State private var isSafe = false
    @State private var displayMessage = false
    @State private var selectedMessage: String?
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 1, green: 0.388, blue: 0.278, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Sending SOS signal...")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Text("Notifying your emergency contacts about your SOS situation.")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                
                if timerCount > 0 {
                    Text("\(timerCount)")
                        .font(.system(size: 50))
                        .foregroundColor(.black)
                        .padding(30)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .padding(.top, 20)
                        .frame(width: 120, height: 120) // Fixed size frame
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 120, height: 120)
                        .padding(.top, 20)
                        .overlay(
                            Image(systemName: "bell.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.black)
                        )
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        EmergencyMessageView(message: "I am injured.", selectedMessage: $selectedMessage, displayMessage: $displayMessage, icon: "bandage.fill")
                        EmergencyMessageView(message: "I am being followed.", selectedMessage: $selectedMessage, displayMessage: $displayMessage, icon: "eye.fill")
                        EmergencyMessageView(message: "I was in a car crash.", selectedMessage: $selectedMessage, displayMessage: $displayMessage, icon: "car.fill")
                        EmergencyMessageView(message: "I am trapped or cornered.", selectedMessage: $selectedMessage, displayMessage: $displayMessage, icon: "exclamationmark.triangle.fill")
                        EmergencyMessageView(message: "I am having a panic attack.", selectedMessage: $selectedMessage, displayMessage: $displayMessage, icon: "waveform.path.ecg")
                        EmergencyMessageView(message: "I am being stalked.", selectedMessage: $selectedMessage, displayMessage: $displayMessage, icon: "person.fill")
                    }
                    .padding()
                }
                
                if displayMessage {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(selectedMessage ?? "") // Show the selected message here
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true) // Allow multiline
                        Text("Remain calm and stay in a safe location. Keep your phone nearby for further communication. If you are injured, apply basic first aid if you can. If you feel unsafe avoid isolated areas and try to stay visible to others. Help is on the way, and your emergency contacts have been notified.")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding(.top)
                }
                
                Spacer()
                
                Button(action: {
                    self.isSafe.toggle()
                }) {
                    Text("I am safe!")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
            }
        }
        .onReceive(timer) { _ in
            if self.timerCount > 0 {
                self.timerCount -= 1
            }
        }
        .sheet(isPresented: $isSafe) {
            HomeView()
        }
    }
}

struct EmergencyMessageView: View {
    let message: String
    @Binding var selectedMessage: String?
    @Binding var displayMessage: Bool
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .padding(.trailing, 10)
                Text(message)
                    .foregroundColor(.black)
                    .padding(.trailing, 10)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding(.leading, 20)
        .padding(.trailing, 20) // Extend to fit
        .onTapGesture {
            self.selectedMessage = message
            self.displayMessage = true
        }
    }
}

struct SOSView_Previews: PreviewProvider {
    static var previews: some View {
        SOSView()
    }
}

