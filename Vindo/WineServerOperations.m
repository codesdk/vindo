//
//  WineServerOperations.m
//  Vindo
//
//  Created by Theodore Dubois on 3/21/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WineServerOperations.h"

// secret info about WinePrefix
@interface WinePrefix ()

- (NSTask *)taskWithWindowsProgram:(NSString *)program arguments:(NSArray *)arguments;
- (NSTask *)taskWithProgram:(NSString *)program arguments:(NSArray *)arguments;

@property StartWineServerOperation *startOp;
@property StopWineServerOperation *stopOp;

@end

@implementation StartWineServerOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init])
        _prefix = prefix;
    return self;
}

- (void)main {
    @try {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:WineServerWillStartNotification object:self.prefix];
        
        if (self.isCancelled)
            return;
        
        NSTask *killExistingServer = [_prefix taskWithProgram:@"wineserver" arguments:@[@"-k"]]; // kill any existing wineserver
        [killExistingServer launch];
        [killExistingServer waitUntilExit];
        
        if (self.isCancelled)
            return;
        
        self.server = [_prefix taskWithProgram:@"wineserver" arguments:@[@"--foreground", @"--persistent"]];
        
        if (self.isCancelled)
            return;
        
        [center addObserver:self
                   selector:@selector(serverTaskStopped:)
                       name:NSTaskDidTerminateNotification
                     object:self.server];
        [self.server launch];
        
        if (self.isCancelled) {
            [self.server terminate];
            [self.server waitUntilExit];
            return;
        }
        
        // now that the server is launched, run wineboot to initialize the wine prefix (and kick the wineserver into action)
        NSTask *wineboot = [_prefix taskWithWindowsProgram:@"wineboot" arguments:@[@"--init"]];
        [wineboot launch];
        [wineboot waitUntilExit];

        [center postNotificationName:WineServerDidStartNotification object:self.prefix];
    }
    @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

- (void)serverTaskStopped:(NSNotification *)notification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    if (self.server.terminationStatus != 0)
        [center postNotificationName:WineServerDidCrashNotification
                              object:self.prefix];
}

@end

@implementation StopWineServerOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix {
    if (self = [super init]) {
        _prefix = prefix;
    }
    return self;
}

- (void)main {
    @try {
        // first end the session with wineboot
        NSTask *endSession = [_prefix taskWithWindowsProgram:@"wineboot" arguments:@[@"--end-session"]];
        [endSession launch];
        [endSession waitUntilExit];
        
        NSTask *server = _prefix.startOp.server;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center postNotificationName:WineServerWillStopNotification object:self.prefix];
        [server interrupt];
        [server waitUntilExit];
        
        [center postNotificationName:WineServerDidStopNotification
                              object:self.prefix];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end


@implementation RunOperation

- (instancetype)initWithPrefix:(WinePrefix *)prefix program:(NSString *)program arguments:(NSArray *)arguments {
    if (self = [super init]) {
        _prefix = prefix;
        _program = program;
        _arguments = arguments;
    }
    return self;
}

- (void)main {
    @try {
        NSTask *program = [_prefix taskWithWindowsProgram:_program arguments:_arguments];
        [program launch];
    } @catch (NSException *exception) {
        // Don't throw it, because it will go nowhere.
    }
}

@end