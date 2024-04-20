import SwiftUI
import AVFoundation

struct FakeCallView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Spacer()

            // Caller ID or Contact image
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.gray)
                .padding(.top, 50)

            Text("Mom")
                .font(.title)
                .foregroundColor(.black)
                .padding(.top, 10)

            Text("Mobile")
                .foregroundColor(.secondary)

            Spacer()

            // Accept and Decline Buttons
            HStack {
                Button(action: {
                    self.declineCall()
                }) {
                    Image(systemName: "phone.down.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.red)
                        .clipShape(Circle())
                }

                Spacer()

                Button(action: {
                    self.acceptCall()
                }) {
                    Image(systemName: "phone.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            self.playRingtone()
        }
        .onDisappear {
            self.stopRingtone()
        }
    }

    func playRingtone() {
        guard let url = Bundle.main.url(forResource: "Ringtone", withExtension: "mp3") else {
            print("Ringtone file not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Could not load or play the ringtone file: \(error)")
        }
    }

    func stopRingtone() {
        audioPlayer?.stop()
    }

    func declineCall() {
        stopRingtone()
        presentationMode.wrappedValue.dismiss()
    }

    func acceptCall() {
        stopRingtone()
        presentationMode.wrappedValue.dismiss()
    }
}

struct FakeCallView_Previews: PreviewProvider {
    static var previews: some View {
        FakeCallView()
    }
}
