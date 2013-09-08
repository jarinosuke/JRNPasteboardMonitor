//
//  JRNPasteboardMonitor.m
//  DemoApp
//
//  Created by jarinosuke on 9/8/13.
//  Copyright (c) 2013 jarinosuke. All rights reserved.
//

#import "JRNPasteboardMonitor.h"

static JRNPasteboardMonitor *defaultMonitor;

NSInteger const JRNPasteboardMonitorBackgroundTaskExpireDuration = 600; //10 minutes

@interface JRNPasteboardMonitor()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation JRNPasteboardMonitor

+ (JRNPasteboardMonitor *)defaultMonitor
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultMonitor = [[JRNPasteboardMonitor alloc] init];
        defaultMonitor.backgroundTask = UIBackgroundTaskInvalid;
    });
    return defaultMonitor;
}

- (void)startMonitoring
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePasteboard:)
                                                 name:UIPasteboardChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)startMonitoringWithChangeHandler:(JRNPasteboardChangeHandler)changeHandler
{
    self.changeHandler = changeHandler;
    
    [self startMonitoring];
}

- (void)stopMonitoring
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self stopMonitoring];
}

#pragma mark -
#pragma mark - Private

- (void)beginBackgroundTask
{
    //create background task identifier
    
    if ( [[UIApplication sharedApplication] respondsToSelector:@selector(beginBackgroundTaskWithName:expirationHandler:)] ) {
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSStringFromClass([self class]) expirationHandler:^{
            [self stopBackgroundTask];
        }];
    } else {
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self stopBackgroundTask];
        }];
    }
    
    
    if ( self.backgroundTask == UIBackgroundTaskInvalid ) {
        return;
    }
    
    //processing task
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *pastboardContents = [[UIPasteboard generalPasteboard] string];
        
        //detect change of pasteboard in loop
        for (NSInteger i = 0; i < JRNPasteboardMonitorBackgroundTaskExpireDuration; i++) {
            if ( ![pastboardContents isEqualToString:[[UIPasteboard generalPasteboard] string]] ) {
                pastboardContents = [[UIPasteboard generalPasteboard] string];
                
                if ( self.changeHandler ) {
                    self.changeHandler([[UIPasteboard generalPasteboard] string]);
                }
            }
            
            //wait 1 second
            [NSThread sleepForTimeInterval:1];
        }
        
        [self stopBackgroundTask];
    });
}

- (void)stopBackgroundTask
{
    //end the task
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
}

#pragma mark -
#pragma mark - Notification

- (void)didChangePasteboard:(NSNotification *)notification
{
    if ( self.changeHandler ) {
        self.changeHandler([[UIPasteboard generalPasteboard] string]);
    }
}

- (void)willEnterForeground:(NSNotification *)notification
{
    [self stopBackgroundTask];
}

- (void)didEnterBackground:(NSNotification *)notification
{
    [self beginBackgroundTask];
}


@end
