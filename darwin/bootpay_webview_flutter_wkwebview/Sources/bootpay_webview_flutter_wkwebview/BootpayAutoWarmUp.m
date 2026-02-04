// Copyright 2024 Bootpay
// Auto WarmUp loader - DEPRECATED: warmUp is now handled by BootpayWarmUpManager.swift
// This file is kept for backward compatibility but +load is disabled to prevent duplicate warmUp

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface BootpayAutoWarmUp : NSObject
+ (WKProcessPool *)sharedProcessPool;
+ (void)releaseWarmUp;
+ (BOOL)isWarmedUp;
@end

@implementation BootpayAutoWarmUp

// +load is DISABLED to prevent duplicate warmUp
// WarmUp is now handled by BootpayWarmUpManager.swift in BTWebViewFlutterPlugin.init()
// Keeping this commented for reference:
// + (void)load { ... }

+ (WKProcessPool *)sharedProcessPool {
    // Delegate to Swift BootpayWarmUpManager for unified ProcessPool
    // This requires bridging header or @objc exposure from Swift side
    NSLog(@"[Bootpay] BootpayAutoWarmUp.sharedProcessPool called - use BootpayWarmUpManager.shared.sharedProcessPool instead");
    return nil;
}

+ (void)releaseWarmUp {
    NSLog(@"[Bootpay] BootpayAutoWarmUp.releaseWarmUp called - use BootpayWarmUpManager.shared.releaseWarmUp() instead");
}

+ (BOOL)isWarmedUp {
    NSLog(@"[Bootpay] BootpayAutoWarmUp.isWarmedUp called - use BootpayWarmUpManager.shared.isWarmedUp instead");
    return NO;
}

@end
