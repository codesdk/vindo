//
//  World.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const WorldPasteboardType;

typedef enum {
    WineServerStopped = 0,
    WineServerStarting,
    WineServerRunning,
    WineServerStopping
} WineServerState;

@interface World : NSObject <NSPasteboardReading, NSPasteboardWriting> {
    NSFileHandle *_logFileHandle;
}

#pragma mark -
#pragma mark World

- (instancetype)initWithName:(NSString *)name;

@property (readonly) NSString *name;
@property (readonly) NSURL *url;

- (void)run:(NSString *)program withArguments:(NSArray *)arguments;
- (void)run:(NSString *)program;

#pragma mark -
#pragma mark Server variables

@property NSTask *serverTask;
@property WineServerState state;

@end


@interface World (WinePrefix)

- (NSTask *)wineTaskWithProgram:(NSString *)program arguments:(NSArray *)arguments;
- (NSDictionary *)wineEnvironment;

@end

@interface World (WineServer)

@property (readonly, getter=isRunning) BOOL running;

- (void)start;
- (void)stop;

@end

extern NSString *const WorldDidStartNotification;
extern NSString *const WorldDidStopNotification;


