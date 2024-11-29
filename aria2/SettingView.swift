import SwiftUI
import UIKit

struct SettingView: View {
    @AppStorage("backgroundMode") private var backgroundMode: Bool = false
    @AppStorage("sslMode") private var sslMode: Bool = false
    @State private var showAboutAlert = false
    @State private var showSSLAlert: Bool = false
    @State private var sslAlertChangeLock: Bool = false
    
    var body: some View {
        Form {
            Section (header: Text("Common").textCase(.none)) {
                Toggle("BackgroundRun", isOn: $backgroundMode)
                HStack {
                    Text("SSL")
                    Spacer()
                    Toggle("SSL", isOn: $sslMode)
                        .labelsHidden()
                        .onChange(of: sslMode) { _ in
                            if (sslAlertChangeLock) {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                UserDefaults.standard.synchronize()
                                showSSLAlert = true
                            })
                        }
                        .alert(isPresented: $showSSLAlert) {
                            Alert(
                                title: Text(sslMode ? "ConfirmSSLTurnOnTitle" : "ConfirmSSLTurnOffTitle"),
                                message: Text(sslMode ? "ConfirmSSLTurnOnText" : "ConfirmSSLTurnOffText"),
                                primaryButton: .default(Text("Confirm")) {
                                    exit(0)
                                },
                                secondaryButton: .cancel(Text("Cancel")) {
                                    sslMode = !sslMode
                                    sslAlertChangeLock = true
                                    showSSLAlert = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                        sslAlertChangeLock = false
                                    })
                                }
                            )
                        }
                }
                if sslMode {
                    Button(action: {
                        openLink(urlString: "https://aria2-server-ca.gendago.cc")
                    }) {
                        HStack {
                            Text("InstallRootCertificate")
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.body)
                        }
                    }
                }
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
                    self.showAboutAlert = true
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
                .alert(isPresented: $showAboutAlert) {
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
