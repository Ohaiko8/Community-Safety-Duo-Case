import SwiftUI

struct AIView: View {
    @State private var timerCount = 5
    @State private var isSafe = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 1, green: 0.388, blue: 0.278, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("AI detected")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                Text("''")//add here string from AI detected message
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()

                
                Text("Is everything ok?")
                    .font(.headline)
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
                        .padding(.top, 20)
                        .overlay(
                            Image(systemName: "bell")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.black)
                        )
                }
                
                Text("Sending SOS message..")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Text("Notifying your emergency contacts for your AI-detected situation.")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    self.isSafe.toggle()
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
            }
        }
        .sheet(isPresented: $isSafe) {
            // Code to transition to home screen after confirming safety
            // This part is not implemented yet
            // HomeView()
        }
    }
}

struct AIView_Previews: PreviewProvider {
    static var previews: some View {
        AIView()
    }
}
