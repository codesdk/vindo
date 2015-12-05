//
//  FirstTimeSetupController.m
//  Vindo
//
//  Created by Theodore Dubois on 9/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "FirstTimeSetupController.h"
#import "World.h"
#import "WinePrefix.h"
#import "WineServer.h"
#import "WorldsController.h"

@interface FirstTimeSetupController ()

@property (getter=isHappening) BOOL happening;

@end

SINGLETON_IMPL(FirstTimeSetupController)

@implementation FirstTimeSetupController

- (id)init {
    if (sharedInstance)
        return sharedInstance;
    
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(checkForFirstTimeSetup:)
                       name:NSApplicationDidFinishLaunchingNotification
                     object:nil];
    }
    return self;
}

- (void)checkForFirstTimeSetup:(NSNotification *)notification {
    WorldsController *worlds = [WorldsController sharedController];
    
    if ([worlds.arrangedObjects count] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FirstTimeSetupDidStartNotification object:self];
        
        World *defaultWorld = [[World alloc] initWithName:@"Default World"];
        
        [worlds addObject:defaultWorld];
        worlds.selectedObjects = @[defaultWorld];
        
        [defaultWorld.prefix startServer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serverDidStart:)
                                                     name:WineServerDidStartNotification
                                                   object:defaultWorld.prefix.server];
    }
}

- (void)serverDidStart:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:FirstTimeSetupDidCompleteNotification object:self];
}

@end

NSString *const FirstTimeSetupDidStartNotification = @"FirstTimeSetupDidStartNotification";
NSString *const FirstTimeSetupDidCompleteNotification = @"FirstTimeSetupDidStartNotification";