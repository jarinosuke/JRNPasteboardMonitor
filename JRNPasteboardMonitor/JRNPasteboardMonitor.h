//
//  JRNPasteboardMonitor.h
//  DemoApp
//
//  Created by jarinosuke on 9/8/13.
//  Copyright (c) 2013 jarinosuke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JRNPasteboardChangeHandler)(NSString *string);
extern NSInteger const JRNPasteboardMonitorBackgroundTaskExpireDuration;

@interface JRNPasteboardMonitor : NSObject
@property (nonatomic, assign) JRNPasteboardChangeHandler changeHandler;
+ (JRNPasteboardMonitor *)defaultMonitor;
- (void)startMonitoring;
- (void)startMonitoringWithChangeHandler:(JRNPasteboardChangeHandler)changeHandler;
- (void)stopMonitoring;
@end
