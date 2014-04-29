//
//  JRNPasteboardMonitor.m
//  DemoApp
//
//  Created by jarinosuke on 9/8/13.
//  Copyright (c) 2013 jarinosuke. All rights reserved.
//

#import "JRNPasteboardMonitor.h"

static JRNPasteboardMonitor *defaultMonitor;

NSInteger const JRNPasteboardMonitorBackgroundTaskExpireDurationPriorIOS7 = 600; //10 minutes
NSInteger const JRNPasteboardMonitorBackgroundTaskExpireDurationLaterIOS7 = 180; // 3 minutes
@interface JRNPasteboardMonitor()
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) NSOperationQueue *backgroundOperationQueue;
@end

@implementation JRNPasteboardMonitor

+ (JRNPasteboardMonitor *)defaultMonitor
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultMonitor = [JRNPasteboardMonitor new];
        defaultMonitor.backgroundTask = UIBackgroundTaskInvalid;
    });
    return defaultMonitor;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundOperationQueue = [NSOperationQueue new];
    }
    return self;
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
    [self.backgroundOperationQueue cancelAllOperations];
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
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginBackgroundTaskWithName:expirationHandler:)]) {
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSStringFromClass([self class]) expirationHandler:^{
            [self stopBackgroundTask];
        }];
    } else {
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self stopBackgroundTask];
        }];
    }
    
    
    if (self.backgroundTask == UIBackgroundTaskInvalid) {
        return;
    }

    // avoid watching task double runnning
    [self.backgroundOperationQueue cancelAllOperations];

    // processing task
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
        NSString *pastboardContents = [[UIPasteboard generalPasteboard] string];

        //detect change of pasteboard in loop
        NSInteger expireDuration = [self expireDuration];
        for (NSInteger i = 0; i < expireDuration; i++) {
            if (weakOperation.isCancelled) {
                return;
            }
            if (![pastboardContents isEqualToString:[[UIPasteboard generalPasteboard] string]]) {
                pastboardContents = [[UIPasteboard generalPasteboard] string];

                if (self.changeHandler) {
                    self.changeHandler([[UIPasteboard generalPasteboard] string]);
                }
            }

            //wait 1 second
            [NSThread sleepForTimeInterval:1];
        }

        //notify expiration
        if (self.expireHandler) {
            self.expireHandler();
        }

        [self stopBackgroundTask];
    }];
    [self.backgroundOperationQueue addOperation:operation];
}

- (void)stopBackgroundTask
{
    //end the task
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
}

- (NSInteger)expireDuration
{
    NSInteger expireDuration;
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        expireDuration = JRNPasteboardMonitorBackgroundTaskExpireDurationPriorIOS7;
    } else {
        expireDuration = JRNPasteboardMonitorBackgroundTaskExpireDurationLaterIOS7;
    }
    return expireDuration;
}

#pragma mark -
#pragma mark - Notification

- (void)didChangePasteboard:(NSNotification *)notification
{
    if (self.changeHandler) {
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
