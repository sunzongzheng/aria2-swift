// Aria2Downloader.m
#import "Aria2Downloader.h"
#include "aria2.h"

@implementation Aria2Downloader

- (instancetype)init {
    self = [super init];
    if (self) {
        aria2::libraryInit();
    }
    return self;
}

- (void)dealloc {
    aria2::libraryDeinit();
}

- (void)startRPCServer:(NSString *)downloadDirectory {
    aria2::SessionConfig config;
    config.keepRunning = true;

    std::string downloadDirectoryString = std::string([downloadDirectory UTF8String]);
    
    aria2::KeyVals options;
    options.push_back(std::make_pair("dir", downloadDirectoryString + "/Downloads"));
    options.push_back(std::make_pair("conf-path", downloadDirectoryString + "/aria2.conf"));

    aria2::Session* session = aria2::sessionNew(options, config);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (aria2::run(session, aria2::RUN_DEFAULT) == 1) {
            // 持续运行
        }
    });
}

- (void)startRPCServer:(NSString *)downloadDirectory crtPath:(NSString *)crtPath keyPath:(NSString *)keyPath {
    aria2::SessionConfig config;
    config.keepRunning = true;

    std::string downloadDirectoryString = std::string([downloadDirectory UTF8String]);
    std::string crtPathString = std::string([crtPath UTF8String]);
    std::string keyPathString = std::string([keyPath UTF8String]);
    
    aria2::KeyVals options;
    options.push_back(std::make_pair("dir", downloadDirectoryString + "/Downloads"));
    options.push_back(std::make_pair("conf-path", downloadDirectoryString + "/aria2.conf"));
    options.push_back(std::make_pair("rpc-certificate", crtPathString));
    options.push_back(std::make_pair("rpc-private-key", keyPathString));
    options.push_back(std::make_pair("rpc-secure", "true"));

    aria2::Session* session = aria2::sessionNew(options, config);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (aria2::run(session, aria2::RUN_DEFAULT) == 1) {
            // 持续运行
        }
    });
}
@end
