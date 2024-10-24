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
                    Label("首页", systemImage: "house")
                }
            
            NavigationView {
                FilesView()
                    .navigationTitle("文件")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarColor(backgroundColor: UIColor.rgb(59, 112, 184), textColor: .white)
            }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("文件", systemImage: "folder")
                }
            
            NavigationView {
                SettingView()
                    .navigationTitle("设置")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarColor(backgroundColor: UIColor.rgb(59, 112, 184), textColor: .white)
            }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("设置", systemImage: "gear")
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
