//
//  main.m
//  MountainNotifier
//
//  Created by Dominik Pich on 17.06.12.
//  Copyright (c) 2012 Dominik Pich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDEmbeddedDataReader.h"
#import "DDZipReader.h"
#import <sys/stat.h>

#pragma mark call tool

int sendNotificationViaHelper(NSString *bundlePath, NSUserNotification *note ) {
    @try {
        id path = [bundlePath stringByAppendingPathComponent:@"Contents/MacOS/MountainNotifierTemplate"];
        NSTask *t = [NSTask launchedTaskWithLaunchPath:path arguments:@[ note.title, note.subtitle, note.informativeText ]];
        [t waitUntilExit];
        return [t terminationStatus];
    }
    @catch (NSException *exception) {
        return EXIT_FAILURE;
    }
}

#pragma mark write tool

NSString *toolApplicationSupportPath(NSString *name) {
    id l = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];    
    l = [l stringByAppendingPathComponent:name];
    
    //make library
    if(![[NSFileManager defaultManager] createDirectoryAtPath:l
                                  withIntermediateDirectories:YES 
                                                   attributes:0
                                                        error:nil]) {
        l = nil;
    }
    
    return l;
}

BOOL writeIcon(NSImage *icon, NSURL *url) {
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    
    CGImageDestinationRef ref = CGImageDestinationCreateWithURL((__bridge CFURLRef)url, kUTTypeAppleICNS, 4, nil);
    NSRect r = NSMakeRect(0, 0, 32, 32);
    CGImageDestinationAddImage(ref, [icon CGImageForProposedRect:&r context:nil hints:nil], nil);
    r = NSMakeRect(0, 0, 64, 64);
    CGImageDestinationAddImage(ref, [icon CGImageForProposedRect:&r context:nil hints:nil], nil);
    r = NSMakeRect(0, 0, 256, 256);
    CGImageDestinationAddImage(ref, [icon CGImageForProposedRect:&r context:nil hints:nil], nil);
    r = NSMakeRect(0, 0, 512, 512);
    CGImageDestinationAddImage(ref, [icon CGImageForProposedRect:&r context:nil hints:nil], nil);
    CGImageDestinationFinalize(ref);
    CFRelease(ref);
    
    return [[NSFileManager defaultManager] fileExistsAtPath:url.path];
}

BOOL updateInfoPlistAndFixBundle(NSString *target, NSString *name, NSString *callerKey) {
    NSString *path = [target stringByAppendingPathComponent:@"Contents/Info.plist"];
    NSMutableDictionary *infoPlist = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [infoPlist setObject:callerKey forKey:@"DDCallerKey"];
    [infoPlist setObject:name forKey:@"CFBundleName"];
    [infoPlist setObject:[@"NOTIFIER." stringByAppendingString:callerKey] forKey:@"CFBundleIdentifier"];
    BOOL br = [infoPlist writeToFile:path atomically:NO];
    
    if(br) {
        //correct file rights because minizip doesnt handle that at all
        NSString *exeFileName = [infoPlist objectForKey:@"CFBundleExecutable"];
        path = [[target stringByAppendingPathComponent:@"Contents/MacOS"] stringByAppendingPathComponent:exeFileName];
        chmod(path.UTF8String, S_IRWXU | S_IRWXG | S_IXOTH);
    }

    return br;
}

BOOL cloneTemplate(NSString *path, NSString *path2) {
    [[NSFileManager defaultManager] removeItemAtPath:path2 error:nil];
    return [[NSFileManager defaultManager] copyItemAtPath:path toPath:path2 error:nil];
}

BOOL unzipTemplate(NSString *zip, NSString *root) {
    DDZipReader* r = [DDZipReader new];
    [r openZipFile:zip];
    NSUInteger files = [r unzipFileTo:root flattenStructure:NO];
    [r closeZipFile];
    return files>0;
}

NSString *writeHelperIfNeeded(NSString *cwd, NSString *root, NSString *name, NSString *callerKey, NSImage *icon ) {
    NSString *target = [[root stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"app"];

    if(![[NSFileManager defaultManager] fileExistsAtPath:target]) {
        NSString *template = [root stringByAppendingPathComponent:@"MountainNotifierTemplate.app"];

        //unzip if needed
        if(![[NSFileManager defaultManager] fileExistsAtPath:template]) {
            NSData *data = [DDEmbeddedDataReader embeddedDataFromSegment:@"__ZIP" inSection:@"__data" error:nil];

            NSString *zip = [root stringByAppendingPathComponent:@"MountainNotifierTemplate.zip"];
            
            //write, extract, delete
            [data writeToFile:zip atomically:NO];
            BOOL bUnzip = unzipTemplate(zip, root);
            [[NSFileManager defaultManager] removeItemAtPath:zip error:nil];

            if(!bUnzip) {
                return nil;
            }
            
        }
            
        //clone it
        if(!cloneTemplate(template, target)) {
            target = nil;
        }
    }

    //update by rewriting icon & plist
    if(target) {
        NSBundle *bundle = [NSBundle bundleWithPath:target];
        NSURL *url = [bundle URLForResource:@"Icon" withExtension:@"icns"];
        if(icon && !writeIcon(icon, url)) {
            target = nil;
        }
        if(!updateInfoPlistAndFixBundle(target, name, callerKey)) {
            target = nil;
        }
    }
    
    return target;
}

NSImage *readIcon(NSString *callerKey, NSString *n) {
    //use api
    NSImage *icon = [NSImage imageNamed:n];
    if(!icon) {
        //read file
        icon = [[NSImage alloc] initWithContentsOfFile:n];
        if(!icon) {
            //use workspace if n IS a file/folder
            if([[NSFileManager defaultManager] fileExistsAtPath:n]) {
                icon = [[NSWorkspace sharedWorkspace] iconForFile:n];
            }
            if(!icon) {
                ///fallback to url mode
                NSURL *url = [NSURL URLWithString:n];
                if(url) {
                    icon = [[NSImage alloc] initWithContentsOfURL:url];
                    if(!icon) {
                        //use callerkey -- which could be a bundle
                        url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:callerKey];
                        if(url)
                            icon = [[NSWorkspace sharedWorkspace] iconForFile:url.path];                    
                    }
                }
            }
        }
    }
    
    return icon;
}
#pragma mark entry

int main(int argc, const char * argv[])
{
    //get all args
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:argc];
    for(int i=0; i<argc; i++) [args addObject:@(argv[i])];
    
    //tool path
    NSString *tool = args[0];
    
    if(args.count>=3) {
        //callerKey and name
        NSString* callerKey = args[1];
        NSString* name = nil;
        NSURL *url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:callerKey];
        if(url) {
            name = [[NSFileManager defaultManager] displayNameAtPath:url.path];
        }
        else {
            url = [NSURL URLWithString:callerKey];
            if(url)
                name = [[NSFileManager defaultManager] displayNameAtPath:url.path];

            if(!name)
                name = [[NSFileManager defaultManager] displayNameAtPath:callerKey];
        }

        //note
        NSUserNotification *note = [NSUserNotification new];
        note.title = args[2];
        if(args.count>=4) {
            note.subtitle = args[3];
        }
        if(args.count>=5) {
            note.informativeText = args[4];
        }
        
        //get icon
        NSImage *icon = nil;
        if(args.count>=6) {
            icon = readIcon(callerKey, args[5]);
        }
        
#ifdef DEBUG
        //log
        printf("%s will proxy:\n \
               callerkey: %s\n \
               name: %s\n \
               title: %s\n \
               subtitle: %s\n \
               information: %s\n \
               icon: %s\n", tool.lastPathComponent.UTF8String, callerKey.UTF8String, name.UTF8String, note.title.UTF8String, note.subtitle.UTF8String, note.informativeText.UTF8String, (argc>=6?argv[5] : (icon?"from caller bundle":"none")));
#endif
        
        //write & call
        id root = toolApplicationSupportPath(tool.lastPathComponent);
        if(root) {
            id cwd = [tool stringByDeletingLastPathComponent];
            NSString* path = writeHelperIfNeeded(cwd, root, name, callerKey, icon);
            if(path) {
#ifdef DEBUG
                printf("tool will call newly created helper app at %s\n", path.UTF8String);
#endif
                return sendNotificationViaHelper(path, note);
            }
        }
    }
    else {
        //log
        printf("Usage: %s caller(id|path|url) title [subtitle] [information] [icon(name|path|url)]\n", tool.lastPathComponent.UTF8String);
    }
    
    return EXIT_FAILURE;
}