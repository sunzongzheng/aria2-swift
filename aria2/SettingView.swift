import SwiftUI
import UIKit

struct SettingView: View {
    @AppStorage("backgroundMode") private var backgroundMode: Bool = false
    @State private var showAlert = false
    
    var body: some View {
        Form {
            Section (header: Text("通用")) {
                Toggle("后台运行", isOn: $backgroundMode)
            }
            Section (header: Text("版本信息")) {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                HStack {
                    Text("App版本").font(.body)
                    Spacer()
                    Text("\(version)")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
                HStack {
                    Text("Aria2版本").font(.body)
                    Spacer()
                    Text("1.37.0")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
            }
            Section (header: Text("关于")) {
                Button(action: {
                    self.showAlert = true
                }) {
                    HStack {
                        Text("关于")
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray) // 设置图标颜色
                            .font(.body)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("关于"),
                        message: Text("本应用遵循GPL开源协议\nhttps://github.com/sunzongzheng/aria2-swift\nhttps://github.com/sunzongzheng/aria2-ios\nhttps://github.com/sunzongzheng/AriaNg"),
                        dismissButton: .default(Text("确定"))
                    )
                }
                
                Button(action: {
                    openLink(urlString: "https://t.me/+dL5I7mZsPFFjNmVl")
                }) {
                    HStack {
                        Text("加入交流群")
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
