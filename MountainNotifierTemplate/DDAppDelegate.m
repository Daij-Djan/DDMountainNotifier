//
//  DDAppDelegate.m
//  bundledNotifier
//
//  Created by Dominik Pich on 14.06.12.
//  Copyright (c) 2012 Dominik Pich. All rights reserved.
//

#import "DDAppDelegate.h"

@implementation DDAppDelegate

-(BOOL)sendNotification:(NSUserNotification*)note {
    if([note.title isEqualToString:@"-"])
        note.title = nil;
    if([note.subtitle isEqualToString:@"-"])
        note.subtitle = nil;
    if([note.informativeText isEqualToString:@"-"])
        note.informativeText = nil;
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];
    return note.presented;
}

- (void)finishBySendingNote {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
#ifdef DEBUG
    NSLog(@"log helper args: %@", args);
#endif
    
    if(args.count>=2) {
        NSUserNotification *note = [NSUserNotification new];
        
        id tag = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DDCallerKey"];
        note.userInfo = @{ @"DDCallerKey" : tag };
        
        note.title = args[1];
        if(args.count>=3) {
            note.subtitle = args[2];
        }
        if(args.count>=4) {
            note.informativeText = args[3];
        }
        
        [self sendNotification:note];
    }
    else {
        printf("Usage: %s title [subtitle] [information]", [args[0] lastPathComponent].UTF8String);
    }
}

- (void)finishByLaunchingCaller {
    NSString* callerKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DDCallerKey"];
    NSURL *url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:callerKey];
    if(url) {
#ifdef DEBUG
        NSLog(@"Launch app at %@", url);
#endif
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:url options:0 configuration:nil error:nil];
    }
    else {
        BOOL br = NO;
        url = [NSURL URLWithString:callerKey];
        if(url) {
#ifdef DEBUG
            NSLog(@"Open URL at %@", url);
#endif
            br = [[NSWorkspace sharedWorkspace] openURL:url];
        }
        
        if(!br) {
            [[NSWorkspace sharedWorkspace] openFile:callerKey];
        }
    }
}

#pragma mark - NSUserNotificationCenter delegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
}

#pragma mark - NSApplication delegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    if(notification.userInfo[NSApplicationLaunchUserNotificationKey])
        [self finishByLaunchingCaller];
    else
        [self finishBySendingNote];
    [NSApp terminate:nil];
}

@end