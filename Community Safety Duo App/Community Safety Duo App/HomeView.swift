import SwiftUI

struct HomeView: View {
    @State private var showStartTrackingView = false // Controls visibility
    let safeCompanionMessages = [
        "Remember, you can always press the SOS button if you're in trouble.",
        "Did you know you can activate Auto SOS by allowing AI access to your microphone in Settings?",
        "You can escape an uncomfortable situation with a fake call.",
        "Don't worry, I've got your back. Let's stay safe together!",
        "You're not alone. I'm here to support you through any situation.",
        "Taking precautions is smart. I'm proud of you for using Compi!",
        "If you ever feel unsafe, just know that help is just a tap away."
    ]
    
    @State private var currentMessageIndex = 0
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    RadialGradient(gradient: Gradient(colors: [Color.skyBlue.opacity(0.3), Color.clear]), center: .center, startRadius: 0, endRadius: 150)
                    
                    CompanionView()
                        .padding()
                        .offset(x: -10, y: 50)
                    
                    VStack {
                        BubbleView(content: safeCompanionMessages[currentMessageIndex])
                    }
                    .offset(x: 0, y: -140)
                }
                
                Button(action: {
                    showStartTrackingView = true
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                        Text("Start Live Tracking")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.skyBlue)
                    .cornerRadius(10)
                }
                .padding(.top, -150)
            }
            .padding()
            
            .onAppear {
                //addUser()
            }
            .sheet(isPresented: $showStartTrackingView) {
                StartTrackingView()
            }
        }
    }
}

func addUser() {
    let imageName = "p4" // Assuming you store the filename in the assets
    let trustedIds = [3]
    let name = "Rebecca"
    let phone = "+444444444"
    
    // This function now passes the image name directly instead of converting it to data
    NetworkManager.shared.addUser(name: name, phone: phone, trusted_ids: trustedIds, profile_picture: imageName) { result in
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                print("User \(user.name) added successfully!")
            }
        case .failure(let error):
            DispatchQueue.main.async {
                print("Failed to add user: \(error.localizedDescription)")
            }
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}





struct TimerView: View {
    @Binding var timerCount: Int
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var body: some View {
        Text("\(timerCount)")
            .onReceive(timer) { _ in
                if self.timerCount > 0 {
                    self.timerCount -= 1
                }
            }
    }
}


struct CompanionView: View {
    var body: some View {
        Image("companion")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 220, height: 220)
    }
}

struct BubbleView: View {
    var content: String
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundColor(.white)
            .shadow(radius: 2) // Add shadow to the bubble
            .overlay(
                Text(content) // Display message
                    .padding()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            )
            .frame(width: 280, height: 100) // Adjust the size of the bubble
    }
}

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ZStack {
            ViewController().environmentObject(appModel)  // Use ViewController as the main view

            if appModel.showAIView {
                AIView()  // Ensure AIView gets the AppModel
                    .environmentObject(appModel)
                    .zIndex(1)  // Make sure it covers other content
            }
        }
    }
}



@main
struct YourApp: App {
    @StateObject private var appModel = AppModel()  // Initialize AppModel

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)  // Pass AppModel to ContentView
        }
    }
}
