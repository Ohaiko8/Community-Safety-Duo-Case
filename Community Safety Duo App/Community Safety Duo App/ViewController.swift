import SwiftUI

extension Color {
    static let skyBlue = Color(red: 4/255, green: 207/255, blue: 252/255)
    static let tomatoRed = Color(red: 1, green: 99/255, blue: 71/255)
}

struct ViewController: View {
    @State private var showingSettings = false
    
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
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(red: 4/255, green: 207/255, blue: 252/255))
                    }
                    .offset(x: -10) // Move the button to the left
                }
                Spacer()
            }
            .padding(.top, 10) // Adjusted to move the button downwards
            .padding(.trailing, 20)
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

