import Foundation
import SwiftUI


class AppModel: ObservableObject {
    @Published var showAIView = false
    @Published var lastDetectedPhrase = ""
    @Published var speechDetector: SpeechDetector?
    
    init() {
        self.speechDetector = SpeechDetector(appModel: self)
    }
}

struct AIView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var timerCount = 10
    
    var body: some View {
        
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("AI Detected")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("You said: \"\(appModel.speechDetector?.lastDetectedPhrase ?? "No phrase detected")\"")
                        .font(.title3)
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
                            .onReceive(Timer.publish(every: 1, on: .main, in: .default).autoconnect()) { _ in
                                if self.timerCount > 0 {
                                    self.timerCount -= 1
                                }
                            }
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
                        self.isSafe()
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
        .onAppear {
                    print("AIView appeared with lastDetectedPhrase: \(appModel.lastDetectedPhrase)")
                }
            
        .onDisappear {
            // Ensure the timer is cancelled if the view disappears for any reason
            if self.timerCount > 0 {
                self.timerCount = 0  // Reset timer count to stop the countdown
            }
        }
    }
    
    private func isSafe() {
        appModel.showAIView = false
        appModel.speechDetector?.stopSirenSound()
    }
    
    @ViewBuilder
    private func SOSCompleteView() -> some View {
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
}
