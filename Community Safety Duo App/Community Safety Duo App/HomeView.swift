import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color.skyBlue.opacity(0.3), Color.clear]), center: .center, startRadius: 0, endRadius: 150)
                
                Image("companion")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding()
                    .offset(x: -10)
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .padding()
                    .alignmentGuide(.top) { dimension in
                        dimension[VerticalAlignment.top]
                    }
                    .alignmentGuide(.leading) { dimension in
                        dimension[HorizontalAlignment.leading]
                    }
            }
            
            HStack {
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
                }
                
                Button(action: {
                }) {
                }
            }
            .padding(.horizontal)
        }
        .padding()
        
        Spacer()
        
        Text("Emergency Information")
            .font(.headline)
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
