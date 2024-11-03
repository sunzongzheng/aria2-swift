import SwiftUI

@main
struct aria2App: App {
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}

struct TabBarView: View {
    @StateObject var globalViewModel = GlobalViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    .navigationTitle("Aria2")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarColor(backgroundColor: UIColor.rgb(59, 112, 184), textColor: .white)
            }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("HomePage", systemImage: "house")
                }
            
            NavigationView {
                FilesView()
                    .navigationTitle("Files")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarColor(backgroundColor: UIColor.rgb(59, 112, 184), textColor: .white)
            }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Files", systemImage: "folder")
                }
            
            NavigationView {
                SettingView()
                    .navigationTitle("Setting")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarColor(backgroundColor: UIColor.rgb(59, 112, 184), textColor: .white)
            }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Setting", systemImage: "gear")
                }
        }
        .onAppear {
            HCKeepBGRunManager.shared.setupAudioSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            let backgroundMode: Bool = UserDefaults.standard.bool(forKey: "backgroundMode")
            if (backgroundMode) {
                HCKeepBGRunManager.shared.startBGRun()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            HCKeepBGRunManager.shared.stopBGRun()
        }
    }
}
