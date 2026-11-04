import SwiftUI
import AVFoundation

@main
struct FuryReviveApp: App {
    @StateObject private var progressStore = FuryProgressStore.shared
    @StateObject private var speechService = FurySpeechService.shared
    @StateObject private var audioEngine = FuryAudioEngineService.shared
    @StateObject private var cacheManager = FuryImageCacheManager.shared
    @StateObject private var permissionManager = FuryPermissionManager.shared
    
    @AppStorage("reviveCoins") private var reviveCoins: Int = 0
    @AppStorage("furyUserId") private var furyUserId: String = "HK-CITIZEN"

    init() {
        setupGlobalAudioSession()
        setupAppearance()
        preloadCoreAssets()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(progressStore)
                .environmentObject(speechService)
                .environmentObject(audioEngine)
                .environmentObject(cacheManager)
                .environmentObject(permissionManager)
                .task {
                    // App 啟動時一次過向用戶請求所有權限
                    await permissionManager.requestAllPermissions()
                    ensureUserIdentity()
                }
        }
    }

    private func setupGlobalAudioSession() {
        Task.detached(priority: .userInitiated) {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
                try session.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("⚠️ [FuryRevive App] 音訊 Session 初始化失敗: \(error.localizedDescription)")
            }
        }
    }

    private func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    private func preloadCoreAssets() {
        let exerciseUrls = MouthExerciseData.exercises.compactMap { $0.imageURL }
        let namingUrls = FuryPracticeRepository.namingItems.compactMap { $0.imageURL }
        let allUrls = Array(Set(exerciseUrls + namingUrls))
        FuryImageCacheManager.shared.preloadAll(urls: allUrls)
    }

    private func ensureUserIdentity() {
        if UserDefaults.standard.string(forKey: "furyUserId") == nil {
            let randomId = "HK-FORGER-\(Int.random(in: 1000...9999))"
            UserDefaults.standard.set(randomId, forKey: "furyUserId")
        }
    }
}
