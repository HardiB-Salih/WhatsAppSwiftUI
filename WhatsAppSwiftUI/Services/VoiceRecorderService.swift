//
//  VoiceRecorderService.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 6/6/24.
//

import AVFoundation
import Combine


/// A service that handles audio recording, providing the ability to start, stop, pause, and resume recordings,
/// and track the elapsed recording time.
///
/// Example usage for ViewModel:
/// ```swift
/// final class SomeViewModel: ObservableObject {
///
///     @Published var isRecordingVoiceMessage = false
///     @Published var elapsedVoiceMessageTime: TimeInterval = 0
///     @Published var isPausedVoiceMessage = false
///     private var subscriptions = Set<AnyCancellable>()
///     let voiceRecorderService = VoiceRecorderService()
///
///     init() {
///         setupVoiceRecorderListener()
///     }
///
///     deinit {
///         subscriptions.forEach { $0.cancel() }
///         subscriptions.removeAll()
///         voiceRecorderService.tearDown()
///     }
///
///     private func setupVoiceRecorderListener() {
///         voiceRecorderService.$isRecording.receive(on: DispatchQueue.main)
///             .sink { [weak self] isRecording in
///                 guard let self = self else { return }
///                 self.isRecordingVoiceMessage = isRecording
///             }.store(in: &subscriptions)
///
///         voiceRecorderService.$elapsedTime.receive(on: DispatchQueue.main)
///             .sink { [weak self] elapsedTime in
///                 guard let self = self else { return }
///                 self.elapsedVoiceMessageTime = elapsedTime
///             }.store(in: &subscriptions)
///
///         voiceRecorderService.$isPaused.receive(on: DispatchQueue.main)
///             .sink { [weak self] isPaused in
///                 guard let self = self else { return }
///                 self.isPausedVoiceMessage = isPaused
///             }.store(in: &subscriptions)
///     }
/// }
/// ```
///
/// Example usage for View:
/// ```swift
/// struct SomeScreen: View {
///     @StateObject private var viewModel = SomeViewModel()
///
///     var body: some View {
///         VStack {
///             // Some layout here
///         }
///         .onDisappear {
///             viewModel.voiceRecorderService.tearDown()
///         }
///     }
/// }
/// ```
///
/// A service that handles audio recording, providing the ability to start, stop, pause, and resume recordings,
/// and track the elapsed recording time.
final class VoiceRecorderService {
    /// The audio recorder instance used for recording.
    private var audioRecorder: AVAudioRecorder?
    
    /// Indicates whether recording is currently in progress. This property is published,
    /// so subscribers can react to changes, but it can only be modified within this class.
    @Published private(set) var isRecording = false
    
    /// The elapsed time since the start of the recording. This property is published,
    /// so subscribers can react to changes, but it can only be modified within this class.
    @Published private(set) var elaspedTime: TimeInterval = 0
    
    /// Indicates whether recording is currently paused. This property is published,
    /// so subscribers can react to changes, but it can only be modified within this class.
    @Published private(set) var isPaused = false
    
    /// The date and time when recording started.
    private var startTime: Date?
    
    /// The total paused time.
    private var pausedTime: TimeInterval = 0
    
    /// A timer used to update the elapsed time during recording.
    private var timer: AnyCancellable?
    
    /// Deinitializes the `VoiceRecorderService` instance, ensuring that recording is stopped
    /// and any resources are cleaned up.
    deinit {
        tearDown()
    }
    
    // MARK: - Recording Control
    
    //MARK: Starts recording audio
    /// Starts recording audio, setting up the audio session and audio recorder.
    /// The audio will be saved to a file in the documents directory.
    func startRecording() {
        ///genarateHapticFeedback(
        genarateHapticFeedback()
        /// setup AudioSession
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
            print("VoiceRecorderService: successfully setup AVAudioSession")
        } catch {
            print("VoiceRecorderService: Failed to setup AVAudioSession")
        }
        
        /// whaere do wanna store the voice message? URL
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = Date().toString(format: "dd-MM-YY 'at' HH:mm:ss") + ".m4a"
        let audioFileURL = documentPath.appendingPathComponent(audioFileName)
        //        let audioFileURL = documentPath.appending(path: audioFileName)
        
        
        let settings : [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
       
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
            startTime = Date()
            startTimer()
            print("VoiceRecorderService: successfully setup AVAudioRecorder")
        } catch {
            print("VoiceRecorderService: Failed to setup AVAudioRecorder")
        }
    }
    
    //MARK: Pauses recording audio
    /// Pauses recording audio.
    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        audioRecorder?.pause()
        isPaused = true
        timer?.cancel()
        pausedTime = Date().timeIntervalSince(startTime ?? Date()) - elaspedTime
        print("VoiceRecorderService: recording paused")
    }
    
    //MARK: Resumes recording audio
    /// Resumes recording audio.
    func resumeRecording() {
        guard isRecording, isPaused else { return }
        audioRecorder?.record()
        isPaused = false
        startTime = Date()
        startTimer()
        print("VoiceRecorderService: recording resumed")
    }
    
    
    
    //MARK: Stops recording audio
    /// Stops recording audio, finalizing the audio file and cleaning up the audio session.
    /// - Parameter completion: A completion handler that provides the URL of the recorded audio file
    ///   and the duration of the recording.
    func stopRecording(completion: ((_ audioURL: URL?, _ audioDuration: TimeInterval)-> Void)? = nil) {
        ///genarateHapticFeedback
        genarateHapticFeedback()
        
        guard isRecording else { return }
        let audioDuration = elaspedTime
        audioRecorder?.stop()
        isRecording = false
        timer?.cancel()
        elaspedTime = 0
        
        let audioSession = AVAudioSession.sharedInstance()
        
       
        
        do {
            try audioSession.setActive(true)
            guard let audioURL = audioRecorder?.url else { return }
            completion?(audioURL, audioDuration)
            print("VoiceRecorderService: successfully teardown AVAudioSession")
        } catch {
            print("VoiceRecorderService: Failed to teardown AVAudioSession")
        }
    }
    
    
    /// Cleans up the `VoiceRecorderService`, stopping any ongoing recording and removing
    /// any recorded audio files.
    func tearDown() {
        if isRecording { stopRecording() }
        timer?.cancel()
        let fileManager = FileManager.default
        let folder = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderContent = try! fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        deleteRecordings(folderContent)
        print("VoiceRecorderService: Was successfully teared down")
    }
    
    // MARK: - Helper Methods
    
    /// Deletes the audio files at the specified URLs.
    /// - Parameter urls: An array of URLs to the audio files to delete.
    private func deleteRecordings(_ urls: [URL]) {
        for url in urls {
            deleteRecordings(at: url)
        }
    }
    
    /// Deletes the audio file at the specified URL.
    /// - Parameter fileUrl: The URL of the audio file to delete.
    func deleteRecordings(at fileUrl : URL) {
        do {
            try FileManager.default.removeItem(at: fileUrl)
            print("VoiceRecorderService: Audio file was deleted at \(fileUrl)")
            
        }catch {
            print("VoiceRecorderService: Failed to delete file")
        }
    }
    
    
    /// Starts the timer to update the elapsed time during recording.
    private func startTimer(){
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [ weak self ] _ in
                guard let self = self, !self.isPaused else { return }
                self.elaspedTime = Date().timeIntervalSince(self.startTime ?? Date()) + self.pausedTime
                 print("VoiceRecorderService: elaspedTime is \(self.elaspedTime)")
                
            }
    }
    
    
    
    
    
    
    private func genarateHapticFeedback() {
        let systemSoundID: SystemSoundID = 1118
        AudioServicesPlaySystemSound(systemSoundID)
        Haptic.impact(.medium)
    }
    
    
}
