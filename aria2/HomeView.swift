import SwiftUI
import WebKit

struct HomeView: View {
    var body: some View {
        VStack {
            WebView(htmlName: "index")
                .frame(minWidth: 100, minHeight: 100)

        }
        .onAppear(perform: {
            var _: LocalNetworkPermissionChecker = LocalNetworkPermissionChecker(host: "255.255.255.255", port: 4567,
            granted: {
                // Perform some action here...
            },
            failure: { error in
                if let error = error {
                    print("Failed with error: \(error.localizedDescription)")
                }
            })
        })
    }
}

struct WebView: UIViewRepresentable {
    var htmlName: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 加载本地HTML文件
        if let filePath = Bundle.main.url(forResource: htmlName, withExtension: "html") {
            let request = URLRequest(url: filePath)
            uiView.load(request)
        }
    }
}

#Preview {
    HomeView()
}
