// Copyright 2024 Bootpay
// Auto WarmUp header for Swift interop

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BootpayAutoWarmUp : NSObject

/// Returns the shared WKProcessPool used for all WebView instances
+ (WKProcessPool *)sharedProcessPool;

/// Releases the pre-warmed WebView to free memory
+ (void)releaseWarmUp;

/// Returns whether warmup has been performed
+ (BOOL)isWarmedUp;

@end

NS_ASSUME_NONNULL_END
