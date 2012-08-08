//
//  DDZippedFileInfo.h
//  DDMinizip
//
//  Created by Dominik Pich on 07.06.12.
//  Copyright (c) 2012 medicus42. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "unzip.h"

typedef enum {
	DDZippedFileInfoCompressionLevelDefault= -1,
	DDZippedFileInfoCompressionLevelNone= 0,
	DDZippedFileInfoCompressionLevelFastest= 1,
	DDZippedFileInfoCompressionLevelBest= 9
} DDZippedFileInfoCompressionLevel;	

@interface DDZippedFileInfo : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, readonly) DDZippedFileInfoCompressionLevel level;
@property (nonatomic, readonly) BOOL crypted;
@property (nonatomic, readonly) NSUInteger zippedSize;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSUInteger crc32;

- (id) initWithName:(NSString*)aName andNativeInfo:(unz_file_info)info;

/**
 * get NSDate object with timeinterval since 1980-01-01 (dos)
 * @param interval seconds since 1980
 * @return the NSDate object
 */
+(NSDate*) dateWithTimeIntervalSince1980:(NSTimeInterval)interval;

@end
