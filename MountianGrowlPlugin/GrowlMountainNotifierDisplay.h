//
//  GrowlMountainNotifierDisplay.h
//  Growl Display Plugins
//
//  Created by Dominik Pich
//  Copyright 2005�2011 The Growl Project All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowlDisplayPlugin.h"

@interface GrowlMountainNotifierDisplay: GrowlDisplayPlugin {
}

- (void) displayNotification:(GrowlNotification *)notification;

@end
