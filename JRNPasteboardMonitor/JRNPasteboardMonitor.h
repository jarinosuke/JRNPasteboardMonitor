//
//  JRNPasteboardMonitor.h
//  DemoApp
//
//  Created by jarinosuke on 9/8/13.
//  Copyright (c) 2013 jarinosuke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JRNPasteboardChangeHandler)(NSString *string);
typedef void (^JRNPastebooardMonitoringExpireHandler)(void);
extern NSInteger const JRNPasteboardMonitorBackgroundTaskExpireDurationPriorIOS7;
extern NSInteger const JRNPasteboardMonitorBackgroundTaskExpireDurationLaterIOS7;

@interface JRNPasteboardMonitor : NSObject
@property (nonatomic, copy) JRNPasteboardChangeHandler changeHandler;
@property (nonatomic, copy) JRNPastebooardMonitoringExpireHandler expireHandler;

+ (instancetype)defaultMonitor;
- (void)startMonitoring;
- (void)startMonitoringWithChangeHandler:(JRNPasteboardChangeHandler)changeHandler;
- (void)stopMonitoring;
@end
