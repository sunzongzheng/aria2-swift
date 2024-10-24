import SwiftUI
import UIKit
import KSPlayer

struct FileItem {
    var path: String
    var name: String
    var icon: String
    var creationDate: Date?
}

struct FilesView: View {
    @AppStorage("backgroundMode") private var backgroundMode: Bool = false
    @State private var showAlert = false
    @State var fileList: [FileItem] = []
    @State public var videoSrc = ""
    @State public var videoTitle = ""
    @State public var videoOptions: KSOptions = KSOptions()
    @State public var showVideoPlayerViewController = false
    let fileManager = FileManager.default
    
    var body: some View {
        VStack {
            if (fileList.count > 0) {
                List {
                    Section(header: Text("使用文件App访问Aria2Server/Downloads目录\n支持更多文件操作功能").textCase(.none)) {
                        ForEach(fileList, id: \.name) { item in
                            Button(action: {
                                print(item)
                                if (item.icon == "video.fill" || item.icon == "music.note") {
                                    self.videoSrc = item.path
                                    self.videoTitle = item.name
                                    self.videoOptions = KSOptions()
                                    self.showVideoPlayerViewController = true
                                } else {
                                    showAlert = true
                                }
                            }) {
                                HStack {
                                    switch item.icon {
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
                                        Text("\(item.creationDate?.formatted() ?? "Unknown")")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.leading, 8)
                                }
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            } else {
                Image("无数据")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("下载目录中没有文件")
                    .padding(.bottom, 100)
                    .padding(.top, 20)
            }
        }
            .onAppear(perform: {
                refreshFileList()
            })
            .sheet(isPresented: $showVideoPlayerViewController) {
                CustomKSVideoPlayerView(videoSrc: $videoSrc, videoTitle: $videoTitle, videoOptions: $videoOptions)
                                .ignoresSafeArea()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text("暂不支持预览此类型文件"),
                    dismissButton: .default(Text("确认")) {
                    }
                )
            }
    }
    
    func refreshFileList() {
        do {
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let downloadsDirectory = documentDirectory.appendingPathComponent("Downloads")
            let fileURLs = try fileManager.contentsOfDirectory(at: downloadsDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            if fileURLs.count == 0 {
                print("目录是空的")
                fileList = []
            } else {
                var newFileList: [FileItem] = []
                for file in fileURLs {
                    let icon = getIcon(for: file.lastPathComponent)
                    let resourceValues = try? file.resourceValues(forKeys: [.creationDateKey])
                    let creationDate = resourceValues?.creationDate
                    newFileList.append(FileItem(path: file.absoluteString, name: file.lastPathComponent, icon: icon, creationDate: creationDate))
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
}

#Preview {
    FilesView()
}

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
            Text("无效的视频 URL")
        }
    }
}
