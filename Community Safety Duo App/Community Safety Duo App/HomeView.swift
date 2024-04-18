import SwiftUI

struct HomeView: View {
    
    @StateObject private var speechDetector = SpeechDetector() // Speech detection
        @State private var showAIView = false // Controls visibility of AIView
    
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
                .offset(x: 0, y: -120)
            }
            .padding(.top, -50)
        }
        .padding()
        
        .onAppear {
                        speechDetector.startPeriodicRecognition()
                    }
                    .onChange(of: speechDetector.dangerDetected) { detected in
                        showAIView = detected
                    }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct AIView: View {
    @Binding var isShowing: Bool
    @State private var timerCount = 5
    @State private var isSafe = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("AI Detected")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()

                Text("Is everything ok?")
                    .font(.title)
                    .fontWeight(.bold)
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
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "bell.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.red)
                        )
                    Text("Sending SOS message...")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    Text("Notifying your emergency contacts for your AI-detected situation.")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    self.isSafe = true
                    self.timer.upstream.connect().cancel() // Stop the timer immediately
                    self.isShowing = false // Dismiss the view and cancel the alert
                }) {
                    Text("I am safe")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.top, 20)
                }
                .padding()
                
                Spacer()
            }
        }
        .onReceive(timer) { _ in
            if self.timerCount > 0 {
                self.timerCount -= 1
            } else {
                self.timer.upstream.connect().cancel() // Ensure to stop the timer to prevent further decrements
                // Auto-trigger safety protocols here if necessary
                self.isShowing = false // Optionally close the view after actions are taken
            }
        }
        .onChange(of: isSafe) { newValue in
            if newValue {
                // Handle additional actions if the user confirms they are safe
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


@main
struct YourAppNameApp: App {
    var body: some Scene {
        WindowGroup {
            ViewController()
        }
    }
}
