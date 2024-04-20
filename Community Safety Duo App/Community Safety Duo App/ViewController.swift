import SwiftUI

extension Color {
    static let skyBlue = Color(red: 4/255, green: 207/255, blue: 252/255)
    static let tomatoRed = Color(red: 1, green: 99/255, blue: 71/255)
}

struct ViewController: View {
    @State private var showingSettings = false
    @State private var showingFakeCall = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationView {
                ZStack(alignment: .bottom) {
                    TabView {
                        HomeView()
                            .tabItem {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }
                        SOSView()
                            .tabItem {
                                Image(systemName: "person.circle.fill")
                                Text("SOS")
                            }
                        FriendsView()
                            .tabItem {
                                Image(systemName: "person.2.fill")
                                Text("Contacts")
                            }
                    }
                    .accentColor(.skyBlue)
                    RedCircle()
                    SOSButton()
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        showingFakeCall.toggle()
                    }) {
                        Image(systemName: "phone.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(red: 1, green: 99/255, blue: 71/255))
                            .padding(15)  // Adds padding around the image to increase tap area
                    }
                    .background(Color.clear)  // Ensures the padding also acts as a tappable area
                    .clipShape(Circle())  // Clips the clickable area to a circle around the content
                    .offset(x: 24)
                                    Spacer()
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(red: 4/255, green: 207/255, blue: 252/255))
                            .padding(15)
                    }
                    .background(Color.clear)  // Ensures the padding also acts as a tappable area
                    .clipShape(Circle())  // Clips the clickable area to a circle around the content
                    .offset(x: -10) // Move the button to the left
                }
                Spacer()
            }
            .padding(.top, 10) // Adjusted to move the button downwards
            .padding(.trailing, 20)
        }
        .sheet(isPresented: $showingFakeCall) {
                    FakeCallView()
                }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView()
            }
            .edgesIgnoringSafeArea(.all) // To remove shadow
        }
        
    }
}


struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewController()
    }
}

struct SOSButton: View {
    var body: some View {
        NavigationLink(destination: SOSView()) {
            VStack {
                Spacer()
                Text("SOS")
                    .foregroundColor(Color(UIColor(red: 1, green: 0.388, blue: 0.278, alpha: 1)))
                    .font(.system(size: 20).bold())
                    .padding(30)
                    .background(Color.white)
                    .clipShape(Circle())
                    .padding(.bottom, 0)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RedCircle: View {
    var body: some View {
        Circle()
            .fill(Color(UIColor(red: 1, green: 0.388, blue: 0.278, alpha: 1)))
            .frame(width: 120, height: 120)
            .padding(.bottom, -18)
    }
}

struct SettingsButton: View {
    var body: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.white)
                .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

