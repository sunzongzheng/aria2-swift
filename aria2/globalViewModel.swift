import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

class GlobalViewModel: ObservableObject {
    @Published var isServiceRunning: Bool = false
    @Published var downloader = Aria2Downloader()
    let fileManager = FileManager.default
    public let language: String = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String ?? "zh"

    init() {
        writeDefaultConfigFile()
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法获取 Document 目录")
            return
        }
        let downloadsDirectory = documentDirectory.appendingPathComponent("Downloads")
        if !fileManager.fileExists(atPath: downloadsDirectory.path) {
            do {
                try fileManager.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Downloads目录创建成功")
            } catch {
                print("创建Downloads目录失败: \(error.localizedDescription)")
            }
        } else {
            print("Downloads目录已存在")
        }
        let sslMode: Bool = UserDefaults.standard.bool(forKey: "sslMode")
        if (sslMode) {
            downloader.startRPCServer(
                documentDirectory.path,
                crtPath: Bundle.main.path(forResource: "server", ofType: "crt")!,
                keyPath: Bundle.main.path(forResource: "server", ofType: "key")!
            )
        } else {
            downloader.startRPCServer(documentDirectory.path)
        }
    }

    func writeDefaultConfigFile() {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法获取 Document 目录")
            return
        }

        let fileURL = documentDirectory.appendingPathComponent("aria2.conf")

        if fileManager.fileExists(atPath: fileURL.path) {
            print("配置文件已存在")
        } else {
            do {
                let content = """
        ## '#'开头为注释内容, 选项都有相应的注释说明, 根据需要修改 ##
        ## 被注释的选项填写的是默认值, 建议在需要修改时再取消注释  ##
        ## 添加了@和默认启用的选项都是系统需要调用的，请不要随意改动否则可能无法正常运行
        
        ## 文件保存相关 ##
        
        # 文件的保存路径(可使用绝对路径或相对路径), 默认: 当前启动位置
        # 此项 OS X 无法使用 $HOME 及 ~/ 设置路径  建议使用 /users/用户名/downloads
        #@dir=$HOME/downloads
        # 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
        #@disk-cache=32M
        # 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
        # 预分配所需时间: none < falloc ? trunc < prealloc
        # falloc和trunc则需要文件系统和内核支持
        # NTFS建议使用falloc, EXT3/4建议trunc, MAC 下需要注释此项
        # file-allocation=none
        # 断点续传
        #@continue=true
        
        ## 下载连接相关 ##
        
        # 最大同时下载任务数, 运行时可修改, 默认:5
        #@max-concurrent-downloads=10
        # 同一服务器连接数, 添加时可指定, 默认:1
        #@max-connection-per-server=15
        # 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
        # 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
        #@min-split-size=10M
        # 单个任务最大线程数, 添加时可指定, 默认:5
        #@split=15
        # 整体下载速度限制, 运行时可修改, 默认:0
        #@max-overall-download-limit=0
        # 单个任务下载速度限制, 默认:0
        #@max-download-limit=0
        # 整体上传速度限制, 运行时可修改, 默认:0
        #@max-overall-upload-limit=0
        # 单个任务上传速度限制, 默认:0
        #@max-upload-limit=0
        # 禁用IPv6, 默认:false
        disable-ipv6=false
        #运行覆盖已存在文件
        #@allow-overwrite=true
        #自动重命名
        #@auto-file-renaming=true
        
        ## 进度保存相关 ##
        
        # 从会话文件中读取下载任务
        #@input-file=/Users/Shared/aria2.session
        # 在Aria2退出时保存`错误/未完成`的下载任务到会话文件
        #@save-session=/Users/Shared/aria2.session
        # 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
        save-session-interval=30
        
        ## RPC相关设置 ##
        
        # 启用RPC, 默认:false
        enable-rpc=true
        check-certificate=false
        # 允许所有来源, 默认:false
        rpc-allow-origin-all=true
        # 允许非外部访问, 默认:false
        rpc-listen-all=true
        # 事件轮询方式, 取值:[epoll, kqueue, port, poll, select], 不同系统默认值不同
        #event-poll=select
        # RPC监听端口, 端口被占用时可以修改, 默认:6800
        # 使用本客户端请勿修改此项
        rpc-listen-port=6800
        # 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
        #rpc-secret=your_rpc_secret
        
        ## BT/PT下载相关 ##
        
        # 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
        #follow-torrent=true
        # BT监听端口, 当端口被屏蔽时使用, 默认:6881-6999
        listen-port=51413
        # 单个种子最大连接数, 默认:55
        #bt-max-peers=55
        # 打开DHT功能, PT需要禁用, 默认:true
        enable-dht=true
        # 打开IPv6 DHT功能, PT需要禁用
        enable-dht6=true
        # DHT网络监听端口, 默认:6881-6999
        dht-listen-port=6881-6999
        # 本地节点查找, PT需要禁用, 默认:false
        bt-enable-lpd=true
        # 种子交换, PT需要禁用, 默认:true
        #enable-peer-exchange=false
        # 每个种子限速, 对少种的PT很有用, 默认:50K
        #bt-request-peer-speed-limit=50K
        # 客户端伪装, PT需要
        peer-id-prefix=-TR2770-
        user-agent=Transmission/2.77
        # 当种子的分享率达到这个数时, 自动停止做种, 0为一直做种, 默认:1.0
        seed-ratio=0
        # 强制保存会话, 即使任务已经完成, 默认:false
        # 较新的版本开启后会在任务完成后依然保留.aria2文件
        #force-save=false
        # BT校验相关, 默认:true
        #bt-hash-check-seed=true
        # 继续之前的BT任务时, 无需再次校验, 默认:false
        bt-seed-unverified=true
        # 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
        bt-save-metadata=true
        
        # bt-tracker数据来自https://github.com/ngosang/trackerslist/blob/master/trackers_all_udp.txt
        
        bt-tracker=http://93.158.213.92:1337/announce,udp://23.140.248.9:1337/announce,udp://186.10.170.97:1337/announce,udp://185.243.218.213:80/announce,udp://91.216.110.53:451/announce,udp://23.157.120.14:6969/announce,udp://208.83.20.20:6969/announce,udp://34.89.91.10:6969/announce,udp://35.227.59.57:1337/announce,udp://109.201.134.183:80/announce,udp://45.9.60.30:6969/announce,udp://35.227.59.57:6969/announce,udp://34.94.76.146:6969/announce,http://34.94.76.146:80/announce,http://34.89.91.10:80/announce,udp://tracker.opentrackr.org:1337/announce,udp://open.demonii.com:1337/announce,udp://open.tracker.cl:1337/announce,udp://open.stealth.si:80/announce,udp://tracker.torrent.eu.org:451/announce,udp://tracker-udp.gbitt.info:80/announce,udp://explodie.org:6969/announce,udp://tracker.dump.cl:6969/announce,udp://tracker.bittor.pw:1337/announce,udp://opentracker.io:6969/announce,udp://open.free-tracker.ga:6969/announce,udp://leet-tracker.moe:1337/announce,udp://isk.richardsw.club:6969/announce,udp://exodus.desync.com:6969/announce,https://tracker.tamersunion.org:443/announce,http://tracker1.bt.moack.co.kr:80/announce,http://tracker.ipv6tracker.org:80/announce,http://tr.kxmp.cf:80/announce,udp://tracker.tiny-vps.com:6969/announce,udp://tracker.theoks.net:6969/announce

        """
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
                print("配置文件写入成功: \(fileURL.path)")
            } catch {
                print("配置文件写入失败: \(error.localizedDescription)")
            }
        }
    }
}
