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

    aria2::KeyVals options;
    options.push_back(std::make_pair("dir", std::string([downloadDirectory UTF8String]) + "/Downloads"));
    options.push_back(std::make_pair("conf-path", std::string([downloadDirectory UTF8String]) + "/aria2.conf"));

    aria2::Session* session = aria2::sessionNew(options, config);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (aria2::run(session, aria2::RUN_DEFAULT) == 1) {
            // 持续运行
        }
    });
}

@end
