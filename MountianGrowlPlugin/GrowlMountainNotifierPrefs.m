//
//  GrowlMountainNotifierPrefs.m
//  Display Plugins
//
//  Created by Dominik Pich
//  Copyright 2005Ð2011 The Growl Project All rights reserved.
//

#import "GrowlMountainNotifierPrefs.h"

@implementation GrowlMountainNotifierPrefs

- (NSString *) mainNibName {
	return @"GrowlMountainNotifierPrefs";
}

- (void) didSelect {
	SYNCHRONIZE_GROWL_PREFS();
}

@end
