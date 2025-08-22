//
//  SARUnArchiveANY.h
//  Player
//
//  Copyright © 2024 wang. All rights reserved.
//


#import <Foundation/Foundation.h>
//#import "SSZipArchive.h"
#import <SSZipArchive/SSZipArchive.h>
#define UNIQUE_KEY( x ) NSString * const x = @#x

enum{
    SARFileTypeZIP,
    SARFileTypeRAR
};

static UNIQUE_KEY( rar );
static UNIQUE_KEY( zip );

typedef void(^Completion)(NSArray *filePaths);
typedef void(^Failure)(void);

@interface SARUnArchiveANY : NSObject <SSZipArchiveDelegate>{
    SSZipArchive *_zipArchive;
    NSString *_fileType;
}

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *destinationPath;
@property (nonatomic, copy) Completion completionBlock;
@property (nonatomic, copy) Failure failureBlock;

- (id)initWithPath:(NSString *)path;
- (void)decompress;

@end
