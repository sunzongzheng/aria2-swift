// Aria2Downloader.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Aria2Downloader : NSObject

- (instancetype)init;
- (void)startRPCServer:(NSString *)downloadDirectory;

@end

NS_ASSUME_NONNULL_END
