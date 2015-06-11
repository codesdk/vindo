//
//  FileItem.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/2/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "FileItem.h"
#import "DirectoryItem.h"

@implementation FileItem

- (instancetype)initWithURL:(NSURL *)url {
    if ([fileItemCache objectForKey:url] != nil)
        return [fileItemCache objectForKey:url];
    
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDir])
        if (isDir && ![self isKindOfClass:[DirectoryItem class]])
            return [[DirectoryItem alloc] initWithURL:url];
    
    if (self = [super init]) {
        _url = url;
        [self refresh];
        [fileItemCache setObject:self forKey:url];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)refresh {
    _name = [self.url lastPathComponent];
    _image = [[NSWorkspace sharedWorkspace] iconForFile:self.url.path];
}

- (BOOL)isLeaf {
    return YES;
}

static NSMapTable *fileItemCache;

+ (void)initialize {
    fileItemCache = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
}

@end