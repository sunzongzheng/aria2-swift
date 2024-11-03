import SwiftUI
import UIKit

struct SettingView: View {
    @AppStorage("backgroundMode") private var backgroundMode: Bool = false
    @State private var showAlert = false
    
    var body: some View {
        Form {
            Section (header: Text("Common").textCase(.none)) {
                Toggle("BackgroundRun", isOn: $backgroundMode)
            }
            Section (header: Text("Verion").textCase(.none)) {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                HStack {
                    Text("App Version").font(.body)
                    Spacer()
                    Text("\(version)")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
                HStack {
                    Text("Aria2 Version").font(.body)
                    Spacer()
                    Text("1.37.0")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
            }
            Section (header: Text("About").textCase(.none)) {
                Button(action: {
                    self.showAlert = true
                }) {
                    HStack {
                        Text("About")
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray) // 设置图标颜色
                            .font(.body)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("About"),
                        message: Text("\(Bundle.main.localizedString(forKey: "License", value: nil, table: "Localizable"))\nhttps://github.com/sunzongzheng/aria2-swift\nhttps://github.com/sunzongzheng/aria2-ios\nhttps://github.com/sunzongzheng/AriaNg"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Button(action: {
                    openLink(urlString: "https://t.me/+dL5I7mZsPFFjNmVl")
                }) {
                    HStack {
                        Text("JoinDiscussion")
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray) // 设置图标颜色
                            .font(.body)
                    }
                }
            }
        }
    }
    
    func openLink(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: {
                success in
                if success {
                    print("The URL was delivered successfully.")
                } else {
                    print("The URL failed to open.")
                }
            })
        } else {
            print("Can't open URL on this device.")
        }
    }
}

#Preview {
    SettingView()
}
