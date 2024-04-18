import SwiftUI

struct HomeView: View {
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
            currentMessageIndex = (currentMessageIndex + 1) % safeCompanionMessages.count
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
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
