//
//  GrowlMountainNotifierDisplay.m
//  Growl Display Plugins
//
//  Created by Dominik Pich
//  Copyright 2005–2011 The Growl Project All rights reserved.
//
#import "GrowlMountainNotifierDisplay.h"
#import "GrowlMountainNotifierPrefs.h"
#import "NSStringAdditions.h"
#import "GrowlDefinesInternal.h"
#import "GrowlNotification.h"
#include <Security/SecKeychain.h>
#include <Security/SecKeychainItem.h>


@implementation GrowlMountainNotifierDisplay

- (void) dealloc {
	[preferencePane release];
	[super dealloc];
}

- (NSPreferencePane *) preferencePane {
	if (!preferencePane)
		preferencePane = [[GrowlMountainNotifierPrefs alloc] initWithBundle:[NSBundle bundleWithIdentifier:@"com.Growl.MountainNotifier"]];
	return preferencePane;
}

- (void) displayNotification:(GrowlNotification *)notification {
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.Growl.MountainNotifier"] pathForResource:@"MountainNotifier" ofType:nil];

    //name
    NSString *name = notification.applicationName;
    if(!name) {
        if (notification.name) {
            NSLog(@"Fallback to using note name as name");
            name = notification.name;
        }
        else if(notification.identifier) {
            NSLog(@"Fallback to using identifier as name");
            name = notification.identifier;
        }
        else {
            NSLog(@"Fallback to using constant as name");
            name = @"com.Growl.MountainNotifier";
        }
    }
    
    //title
    NSString *title = notification.title;
    if(!title.length)
        title = @"-";
    
    //no subtitle
    NSString *subtitle = @"-";
    
    if(title.length>20) {
        subtitle = title;
        title = @"-";
    }
    
    //msg
    NSString *message = notification.messageText;
    if(!message.length)
        message = @"-";
    
    //always revert to appicon!
    notification.icon = nil;
    id data=[notification.auxiliaryDictionary objectForKey:GROWL_NOTIFICATION_APP_ICON_DATA];
    if(!data)
        data=[notification.auxiliaryDictionary objectForKey:GROWL_APP_ICON_DATA];
    
    if(data) {
        notification.icon = [[[NSImage alloc] initWithData:data] autorelease];
    }
    
    //icon
    NSString *iconpath = nil;
    if(notification.icon) {
        iconpath = [NSTemporaryDirectory() stringByAppendingPathComponent: [[NSProcessInfo processInfo] globallyUniqueString]];
        [[notification.icon TIFFRepresentation] writeToFile:iconpath atomically:NO];
    }
    else {
        iconpath = [[NSBundle mainBundle] pathForResource:@"Growl" ofType:@"icns"];
    }
         
    //launch tool
    NSTask *tool = [NSTask launchedTaskWithLaunchPath:path arguments:[NSArray arrayWithObjects:name, title, subtitle, message, iconpath, nil]];
    [tool waitUntilExit];

    //if we wrote an icon, clean up
    if(notification.icon)
        [[NSFileManager defaultManager] removeItemAtPath:iconpath error:nil];
}

- (BOOL) requiresPositioning {
	return NO;
}

@end
