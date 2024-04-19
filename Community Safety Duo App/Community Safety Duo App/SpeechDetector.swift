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
    @Published var lastDetectedPhrase = ""
    
    init() {
        setupAudioSession()
    }
    
    func requestMicrophonePermission() {
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Permission granted")
                        self?.startPeriodicRecognition()
                    } else {
                        print("Permission denied")
                    }
                }
            }
        }
    
    private func setupAudioSession() {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
                try audioSession.setActive(true)
                NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: nil)
                requestMicrophonePermission()
            } catch {
                print("Audio Session setup failed: \(error)")
            }
        }
    
    // Handle audio session interruptions
    @objc private func handleAudioSessionInterruption(notification: Notification) {
            guard let info = notification.userInfo,
                  let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }

            if type == .began {
                print("Audio session interruption began.")
            } else if type == .ended {
                if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt,
                   AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                    // Restart the audio session after the interruption ends
                    setupAudioSession()
                    startPeriodicRecognition()
                }
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
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
                self.cleanupAudioSession()  // Clean up immediately on error
                return
            }

            if let result = result, self.checkForDangerousWords(in: result.bestTranscription.formattedString.lowercased()) {
                DispatchQueue.main.async {
                    self.dangerDetected = true
                    self.lastDetectedPhrase = result.bestTranscription.formattedString  // Store the detected phrase
                    self.playSirenSound()
                    self.recognitionRequest?.endAudio()  // Properly end audio processing
                }
                return  // Early return to avoid further processing
            }

            // Check if the recognition result is final
            if result?.isFinal ?? false {
                self.cleanupAudioSession()  // Clean up after the task completes
            }
        }
    }


    
    
    
    private func checkForDangerousWords(in transcript: String) -> Bool {
        let dangerousWords = [
            "help", "sos", "emergency", "stop", "don't hurt me", "I don't want to die", "leave me alone", "I'm scared",
            "I'm hurt", "I can't breathe", "heart attack", "it hurts", "I feel sick",
            "robbery", "thief", "gun", "knife", "attack",
            "fire", "accident", "explosion", "earthquake", "flood",
            "kidnap", "they took me", "I'm being followed", "I can't leave"
        ]
        return dangerousWords.contains(where: transcript.contains)
    }
    
    private func cleanupAudioSession() {
        audioPlayer?.stop()
        recognitionTask = nil
        lastDetectedPhrase = ""
        dangerDetected = false
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
            audioPlayer?.numberOfLoops = -1  // Loop indefinitely
            audioPlayer?.play()
            isSirenPlaying.send(true)  // Notify UI that siren is playing
        } catch {
            print("Could not load or play the siren sound file: \(error)")
        }
    }

    
    func stopSirenSound() {
            cleanupAudioSession()
            startPeriodicRecognition()
    }
    
}

