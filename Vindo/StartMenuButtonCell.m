//
//  NSButtonCell+MultilineButtons.m
//  Vindo
//
//  Created by Theodore Dubois on 12/17/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuButtonCell.h"
#import "StartMenuItem.h"

@implementation StartMenuButtonCell : NSButtonCell

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    self.highlightsBy = NSPushInCellMask;
    return self;
}

- (void)startDraggingSessionWithEvent:(NSEvent *)event {
    NSDraggingItem *draggingItem = [[NSDraggingItem alloc] initWithPasteboardWriter:self.representedObject];
    NSImage *dragImage = [self dragImage];
    [self.representedObject setDragImage:dragImage];
    [draggingItem setDraggingFrame:self.controlView.bounds contents:dragImage];
    NSDraggingSession *session = [self.controlView beginDraggingSessionWithItems:@[draggingItem]
                                                                           event:event
                                                                          source:self];
    session.animatesToStartingPositionsOnCancelOrFail = NO;
}

- (NSImage *)dragImage {
    BOOL highlighted = self.highlighted;
    self.highlighted = NO;
    
    NSBitmapImageRep *dragImageRep = [self.controlView bitmapImageRepForCachingDisplayInRect:self.controlView.bounds];
    [self.controlView cacheDisplayInRect:self.controlView.bounds toBitmapImageRep:dragImageRep];
    NSImage *dragImage = [[NSImage alloc] initWithSize:dragImageRep.size];
    [dragImage addRepresentation:dragImageRep];
    
    self.highlighted = highlighted;
    
    return dragImage;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationLink;
}

- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session {
    return NO;
}

- (NSMenu *)menuForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)view {
    NSMenu *menu = [NSMenu new];
    NSMenuItem *showInFinder = [[NSMenuItem alloc] initWithTitle:@"Show in Finder" action:@selector(showInFinder:) keyEquivalent:@""];
    showInFinder.target = self;
    [menu addItem:showInFinder];
    NSMenuItem *open = [[NSMenuItem alloc] initWithTitle:@"Open" action:@selector(performClick:) keyEquivalent:@""];
    open.target = self;
    [menu addItem:open];
    return menu;
}

- (void)showInFinder:(id)sender {
    StartMenuItem *item = self.representedObject;
    [[NSWorkspace sharedWorkspace] selectFile:item.bundle.bundleURL.path inFileViewerRootedAtPath:NSHomeDirectory()];
}

#pragma mark - Code copied from Stack Overflow. Thanks to Brad Allred.

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
    BOOL result = NO;
    NSPoint currentPoint = theEvent.locationInWindow;
    BOOL done = NO;
    BOOL trackContinously = [self startTrackingAt:currentPoint inView:controlView];
    
    BOOL mouseIsUp = NO;
    NSEvent *event = nil;
    while (!done) {
        NSPoint lastPoint = currentPoint;
        
        event = [NSApp nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)
                                   untilDate:[NSDate distantFuture]
                                      inMode:NSEventTrackingRunLoopMode
                                     dequeue:YES];
        
        if (event) {
            currentPoint = event.locationInWindow;
            
            // Send continueTracking.../stopTracking...
            if (trackContinously) {
                if (![self continueTracking:lastPoint
                                         at:currentPoint
                                     inView:controlView]) {
                    done = YES;
                    [self stopTracking:lastPoint
                                    at:currentPoint
                                inView:controlView
                             mouseIsUp:mouseIsUp];
                }
                if (self.isContinuous) {
                    [NSApp sendAction:self.action
                                   to:self.target
                                 from:controlView];
                }
            }
            
            mouseIsUp = (event.type == NSLeftMouseUp);
            done = done || mouseIsUp;
            
            if (untilMouseUp) {
                result = mouseIsUp;
            } else {
                // Check if the mouse left our cell rect
                result = NSPointInRect([controlView
                                        convertPoint:currentPoint
                                        fromView:nil], cellFrame);
                if (!result)
                    done = YES;
            }
            
            if (done && result && ![self isContinuous])
                [NSApp sendAction:self.action
                               to:self.target
                             from:controlView];
            else {
                done = YES;
                result = YES;
                
                [self startDraggingSessionWithEvent:event];
            }
        }
    }
    return result;
}

@end