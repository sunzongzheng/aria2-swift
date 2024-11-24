import SwiftUI
import UIKit
import KSPlayer

struct FileItem {
    var path: String
    var name: String
    var isDirectory: Bool
    var icon: String
    var creationDate: Date?
}

func getRootPath() -> String {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Downloads").path
    var resolvedPath = [CChar](repeating: 0, count: Int(PATH_MAX))
    if realpath(path, &resolvedPath) != nil {
        return String(cString: resolvedPath)
    }
    return path
}

struct FilesView: View {
    @AppStorage("backgroundMode") private var backgroundMode: Bool = false
    @State private var showAlert = false
    @State var fileList: [FileItem] = []
    @State public var videoSrc = ""
    @State public var videoTitle = ""
    @State public var videoOptions: KSOptions = KSOptions()
    @State public var showVideoPlayerViewController = false
    @State private var showShareSheet = false
    @State private var showActionSheet = false
    @State private var fileToSharePath: String = ""
    @State private var currentDirectory: String = getRootPath()
    @State private var actionSheetItem: FileItem? = nil
    let rootDirectory = getRootPath()
    let fileManager = FileManager.default
    
    var body: some View {
        VStack {
            if (fileList.count > 0) {
                List {
                    Section(header: Text("FilesViewTips").textCase(.none)) {
                        ForEach(fileList, id: \.name) { item in
                            HStack {
                                switch item.icon {
                                case "folder.fill":
                                    Image(systemName: item.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(red: 255/255, green: 202/255, blue: 41/255))
                                        .frame(width: 36, height: 36)
                                case "video.fill":
                                    Image(systemName: item.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(red: 25/255, green: 144/255, blue: 1))
                                        .frame(width: 36, height: 36)
                                case "music.note":
                                    Image(systemName: item.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(red: 25/255, green: 144/255, blue: 1))
                                        .frame(width: 36, height: 36)
                                default:
                                    Image(systemName: item.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                        .frame(width: 36, height: 36)
                                }
                                VStack {
                                    Text(item.name)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(formatterDate(date: item.creationDate ?? Date()))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.leading, 8)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .conditionalSwipeActions(
                                    swipeActions: {
                                        if #available(iOS 15.0, *) {
                                            Button(role: .destructive) {
                                                self.removeFile(sourceUrl: item.path)
                                                self.refreshFileList()
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button(action: {
                                                DispatchQueue.main.async {
                                                    self.fileToSharePath = item.path
                                                    self.showShareSheet = true
                                                }
                                            }) {
                                                Label("Share", systemImage: "square.and.arrow.up")
                                            }
                                        }
                                    },
                                    longPressActions: {
                                        actionSheetItem = item
                                        showActionSheet = true
                                    }
                                )
                            }
                                .onTapGesture {
                                    if item.isDirectory {
                                        refreshFileList(directoryPath: item.path)
                                    } else if (item.icon == "video.fill" || item.icon == "music.note") {
                                        self.videoSrc = item.path
                                        self.videoTitle = item.name
                                        self.videoOptions = KSOptions()
                                        self.showVideoPlayerViewController = true
                                    } else {
                                        self.showAlert = true
                                    }
                                }
                        }
                    }
                }
            } else {
                Image("无数据")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("NoFile")
                    .padding(.bottom, 100)
                    .padding(.top, 20)
            }
        }
            .toolbar {
                // 在导航栏左侧添加返回按钮
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentDirectory != rootDirectory {
                        Button(action: {
                            refreshFileList(directoryPath: (currentDirectory as NSString).deletingLastPathComponent)
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onAppear {
                refreshFileList()
            }
            .sheet(isPresented: $showVideoPlayerViewController) {
                if #available(iOS 16.0, *){
                    CustomKSVideoPlayerView(videoSrc: $videoSrc, videoTitle: $videoTitle, videoOptions: $videoOptions)
                                    .ignoresSafeArea()
                } else{
                    Text("NotSupportFileType")
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Tips"),
                    message: Text("NotSupportFileType"),
                    dismissButton: .default(Text("OK")) {
                    }
                )
            }
            // 分享
            .sheet(isPresented: $showShareSheet) {
                ActivityViewController(path: $fileToSharePath)
            }
            // 长按操作
            .actionSheet(isPresented: $showActionSheet) {
                var buttons: [ActionSheet.Button] = []
                if let actionSheetItem = actionSheetItem {
                    buttons.append(.default(Text("Share")) {
                        self.fileToSharePath = actionSheetItem.path
                        self.showShareSheet = true
                    })
                    buttons.append(.destructive(Text("Delete")) {
                        self.removeFile(sourceUrl: actionSheetItem.path)
                        self.refreshFileList()
                    })
                }
                // 添加取消按钮
                buttons.append(.cancel())
                return ActionSheet(
                    title: Text("FileOperations"),
                    buttons: buttons
                )
            }
    }
    
    func refreshFileList(directoryPath: String? = nil) {
        do {
            currentDirectory = directoryPath ?? currentDirectory
            let fileURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: currentDirectory), includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            if fileURLs.count == 0 {
                print("目录是空的")
                fileList = []
            } else {
                var newFileList: [FileItem] = []
                for file in fileURLs {
                    let resourceValues = try? file.resourceValues(forKeys: [.creationDateKey, .isDirectoryKey])
                    let creationDate = resourceValues?.creationDate
                    let isDirectory = resourceValues?.isDirectory ?? false
                    let icon = isDirectory ? "folder.fill" : getIcon(for: file.lastPathComponent)
                    newFileList.append(FileItem(path: file.path, name: file.lastPathComponent, isDirectory: isDirectory, icon: icon, creationDate: creationDate))
                }
                fileList = newFileList.sorted { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) }
            }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            fileList = []
        }
    }
    
    func getIcon(for file: String) -> String {
        let fileExtension = file.split(separator: ".").last?.lowercased() ?? ""
        switch fileExtension {
        case "mp3", "wav", "flac", "ape":
            return "music.note"
        case "mp4", "flv", "m3u8", "mkv", "avi", "mov", "wmv", "rm", "rmvb", "3gp", "m4v", "dat", "vob", "mpeg", "dv", "mod":
            return "video.fill"
        default:
            return "doc.fill"
        }
    }
    
    func formatterDate(date: Date) -> String{
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: date)
    }
    
    func removeFile(sourceUrl:String) {
        do {
            try fileManager.removeItem(atPath: sourceUrl)
            print("Success to remove file.")
        } catch{
            print("Failed to remove file.")
        }
    }
}

#Preview {
    FilesView()
}

@available(iOS 16.0, *)
struct CustomKSVideoPlayerView: View {
    @Binding var videoSrc: String
    @Binding var videoOptions: KSOptions
    @Binding var videoTitle: String

    init(videoSrc: Binding<String>, videoTitle: Binding<String>, videoOptions: Binding<KSOptions>) {
        _videoSrc = videoSrc
        _videoTitle = videoTitle
        _videoOptions = videoOptions

        KSOptions.canBackgroundPlay = true
        KSOptions.logLevel = .debug
        KSOptions.secondPlayerType = KSMEPlayer.self
        KSOptions.isAutoPlay = true
    }

    var body: some View {
        if let url = URL(string: videoSrc) {
            KSVideoPlayerView(url: url, options: videoOptions, title: videoTitle)
                .onAppear {
                    print("播放源: \(videoSrc)")
                }
        } else {
            Text("UnavailableVideoUrl")
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var path: String
    
    // 创建 UIActivityViewController
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [URL(fileURLWithPath: path)], applicationActivities: nil)
        
        // 在 iPad 上，UIActivityViewController 会自动判断显示方式
        // 设置 popoverController.sourceView 是为了指定在 iPad 上弹出分享界面的源视图
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = context.coordinator.sourceView
            popoverController.sourceRect = CGRect(x: context.coordinator.sourceView.bounds.midX,
                                                  y: context.coordinator.sourceView.bounds.midY,
                                                  width: 0,
                                                  height: 0)
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新视图，UIActivityViewController 的内容已经在初始化时设置
    }
    
    // 负责在 UIKit 和 SwiftUI 之间协调
    class Coordinator: NSObject {
        var parent: ActivityViewController
        var sourceView: UIView
        
        init(parent: ActivityViewController, sourceView: UIView) {
            self.parent = parent
            self.sourceView = sourceView
        }
    }
    
    func makeCoordinator() -> Coordinator {
        // 获取根视图（作为 sourceView）
        let sourceView = UIApplication.shared.windows.first?.rootViewController?.view ?? UIView()
        return Coordinator(parent: self, sourceView: sourceView)
    }
}
