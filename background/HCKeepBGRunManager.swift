import Foundation
import AVFoundation

class HCKeepBGRunManager: NSObject {

    var playerBack: AVAudioPlayer?

    static let shared = HCKeepBGRunManager()

    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, options: .mixWithOthers) // 设置后台播放
            try audioSession.setActive(true)
        } catch {
            print("Error setting audio session category or activating it: \(error)")
        }
        
        let filePath = Bundle.main.path(forResource: "jm", ofType: "mp3") ?? ""
        let fileURL = URL(fileURLWithPath: filePath)
        
        do {
            playerBack = try AVAudioPlayer(contentsOf: fileURL)
            playerBack?.prepareToPlay()
            playerBack?.volume = 1.0
            playerBack?.numberOfLoops = -1  // 无限循环播放
        } catch {
            print("AVAudioPlayer init failed: \(error)")
        }
    }

    func startBGRun() {
        playerBack?.play()
    }

    func stopBGRun() {
        playerBack?.stop()
    }
}
