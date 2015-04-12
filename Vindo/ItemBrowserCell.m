//
//  ItemBrowserCell.m
//  Vindo
//
//  This is mostly Apple sample code (FileSystemBrowserCell, ComplexBrowser).
//  I wrote setObjectValue.
//

#import "ItemBrowserCell.h"
#import "Item.h"

#define ICON_SIZE           16.0	// Our Icons are ICON_SIZE x ICON_SIZE
#define ICON_INSET_HORIZ	6.0     // Distance to inset the icon from the left edge.
#define ICON_TEXT_SPACING	4.0     // Distance between the end of the icon and the text part
#define ICON_INSET_VERT     3.0     // Distance from top/bottom of icon

@implementation ItemBrowserCell
@synthesize image = _image;

- (id)init {
    if (self = [super init]) {
        [self setLineBreakMode:NSLineBreakByTruncatingMiddle];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ItemBrowserCell *result = [super copyWithZone:zone];
    result.image = self.image;
    return result;
}

- (NSRect)imageRectForBounds:(NSRect)bounds {
    bounds.origin.x += ICON_INSET_HORIZ;
    bounds.size.width = ICON_SIZE;
    bounds.origin.y += trunc((bounds.size.height - ICON_SIZE) / 2.0);
    bounds.size.height = ICON_SIZE;
    return bounds;
}

- (NSRect)titleRectForBounds:(NSRect)bounds {
    // Inset the title for the image
    CGFloat inset = (ICON_INSET_HORIZ + ICON_SIZE + ICON_TEXT_SPACING);
    bounds.origin.x += inset;
    bounds.size.width -= inset;
    return [super titleRectForBounds:bounds];
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
    // Make our cells a bit higher than normal to give some additional space for the icon to fit.
    NSSize theSize = [super cellSizeForBounds:aRect];
    theSize.width += (ICON_INSET_HORIZ + ICON_SIZE + ICON_TEXT_SPACING);
    theSize.height = ICON_INSET_VERT + ICON_SIZE + ICON_INSET_VERT;
    return theSize;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect imageRect = [self imageRectForBounds:cellFrame];
    [self.image drawInRect:imageRect
                  fromRect:NSZeroRect
                 operation:NSCompositeSourceOver
                  fraction:1.0
            respectFlipped:YES
                     hints:nil];
    CGFloat inset = (ICON_INSET_HORIZ + ICON_SIZE + ICON_TEXT_SPACING);
    cellFrame.origin.x += inset;
    cellFrame.size.width -= inset;
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view {
    // We want to exclude the icon from the expansion frame when you hover over the cell
    [super drawInteriorWithFrame:cellFrame inView:view];
}

@end
