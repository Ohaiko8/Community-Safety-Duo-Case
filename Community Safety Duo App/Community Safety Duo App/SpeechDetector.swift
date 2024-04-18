import AVFoundation
import Speech
import Combine

class SpeechDetector: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioPlayer: AVAudioPlayer?
    
    // Published property to notify the UI
    var isSirenPlaying = CurrentValueSubject<Bool, Never>(false)
    @Published var dangerDetected = false
    
    init() {
        requestMicrophonePermission()  // Request permission on initialization
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
            NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: audioSession)
        } catch {
            print("Audio Session setup failed: \(error)")
        }
    }
    
    func requestMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Permission granted")
                        self.setupAudioSession()
                    } else {
                        print("Permission denied")
                    }
                }
            }
        case .denied:
            print("Microphone access previously denied")
        case .granted:
            print("Microphone permission already granted")
            setupAudioSession()
        @unknown default:
            fatalError("Unknown microphone permission state")
        }
    }
    
    func startPeriodicRecognition() {
        let timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    @objc private func startRecording() {
        // Ensure the audio engine is not running and remove any previous tap
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [unowned self] (buffer, when) in
            recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start because of an error: \(error)")
            return
        }
        
        setupRecognitionTask()
    }

    private func setupRecognitionTask() {
        print("recognition started")
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
                    guard let self = self else { return }
                    
                    if let result = result {
                        let words = result.bestTranscription.formattedString.lowercased()
                        if self.checkForDangerousWords(in: words) {
                            DispatchQueue.main.async {
                                self.dangerDetected = true  // Trigger UI update
                                self.playSirenSound()
                            }
                        }
                    }
                    
                    if error != nil || result!.isFinal {
                        self.cleanupAudioSession()
                    }
                }
    }
    
    private func checkForDangerousWords(in transcript: String) -> Bool {
        let dangerousWords = [
            "help", "help", "sos", "emergency", "stop", "don't hurt me", "I don't want to die", "leave me alone", "I'm scared",
            "I'm hurt", "I can't breathe", "heart attack", "it hurts", "I feel sick",
            "robbery", "thief", "gun", "knife", "attack",
            "fire", "accident", "explosion", "earthquake", "flood",
            "kidnap", "they took me", "I'm being followed", "I can't leave"
        ]
        return dangerousWords.contains(where: transcript.contains)
    }
    
    private func cleanupAudioSession() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        isSirenPlaying.send(false)  // Notify UI that siren stopped
    }
    
    func playSirenSound() {
        guard let url = Bundle.main.url(forResource: "siren", withExtension: "mp3") else {
            print("Siren sound file not found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isSirenPlaying.send(true)  // Notify UI that siren is playing
        } catch {
            print("Could not load or play the siren sound file: \(error)")
        }
    }
    
    func stopSirenSound() {
            audioPlayer?.stop()
            isSirenPlaying.send(false)  // Notify that siren has stopped
        }
    
    // Handle audio session interruptions
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            // Audio session was interrupted
            print("Audio session interruption began.")
        } else if type == .ended {
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Restart any tasks that were paused or not yet started while interrupted
                try? AVAudioSession.sharedInstance().setActive(true)
                startRecording()  // Resume recording
            }
        }
    }
}

