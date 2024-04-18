import SwiftUI

extension Color {
    static let skyBlue = Color(red: 4/255, green: 207/255, blue: 252/255)
    static let tomatoRed = Color(red: 1, green: 99/255, blue: 71/255)
}

struct ViewController: View {
    var body: some View {
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
                    .padding(30)                     .background(Color.white)  .clipShape(Circle())
                    .padding(.bottom, -16)  }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RedCircle: View {
    var body: some View {
        Circle()
            .fill(Color(UIColor(red: 1, green: 0.388, blue: 0.278, alpha: 1)))
            .frame(width: 120, height: 120)
            .padding(.bottom, -34) 
    }
}
