/**
 * @file ImageTextCell.m
 * @author Ole Morten Halvorsen
 *
 * @section LICENSE
 * Copyright (c) 2009, Ole Morten Halvorsen
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list 
 *   of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *   of conditions and the following disclaimer in the documentation and/or other materials 
 *   provided with the distribution.
 * - Neither the name of Clyppan nor the names of its contributors may be used to endorse or 
 *   promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ImageTextCell.h"

@interface ImageTextCell( private )

- (id) dataForKeyPath:(NSString *)keyPath;

- (void) drawHighlightInRect:(NSRect)cellFrame;
- (void) drawMainIconWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void) drawPrimaryTextWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void) drawSecondaryTextWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end



#pragma mark -
@implementation ImageTextCell( private )

- (void) drawHighlightInRect:(NSRect)cellFrame;
{
    if ( [self isHighlighted] )
    {
        return;
    }
    
    NSColor *color = [NSColor colorWithCalibratedRed:104 / 255.00 
                                               green:122 / 255.00 
                                                blue:159 / 255.00 
                                               alpha:0.8];
    color = [NSColor alternateSelectedControlColor];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[color highlightWithLevel:0.20]
                                                         endingColor:[color shadowWithLevel:0.1]];
    
    [gradient drawInRect:cellFrame angle:90];
    
    NSColor *borderColor = [NSColor colorWithCalibratedRed:87 / 255.00 
                                                     green:87 / 255.00 
                                                      blue:87 / 255.00 
                                                     alpha:1];
    [borderColor set];
    cellFrame.origin.y = cellFrame.size.height - 1;
    cellFrame.size.height = 1;
    [[NSBezierPath bezierPathWithRect:cellFrame] fill];
}

- (void) drawMainIconWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    NSImage *icon = [self dataForKeyPath:iconKeyPath];
    NSSize imageSize = [icon size];
    imageSize.height = cellFrame.size.height - self.padding;
    imageSize.width = imageSize.height;
    [icon setSize:imageSize];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    if ( [controlView isFlipped] ) 
    {
        NSAffineTransform *xform = [NSAffineTransform transform];
        [xform translateXBy:0.0 yBy: cellFrame.size.height];
        [xform scaleXBy:1.0 yBy:-1.0];
        [xform concat];		
        cellFrame.origin.y = 0 - cellFrame.origin.y;
    }
    
    if ( [controlView isFlipped] )
    {
        cellFrame.origin.y += ( cellFrame.size.height - imageSize.height ) / 2;
    }
    else
    {
        cellFrame.origin.y += ( cellFrame.size.height + imageSize.height ) / 2;
    }    
    
    NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
    [[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];    
    
    [controlView lockFocus];
    [icon drawInRect:NSMakeRect( cellFrame.origin.x + self.padding, cellFrame.origin.y,
                                imageSize.height, imageSize.height )
            fromRect:NSMakeRect( 0, 0, [icon size].width, [icon size].height )
           operation:NSCompositeSourceOver
            fraction:1];
    
    [controlView unlockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation: interpolation];
    [[NSGraphicsContext currentContext] restoreGraphicsState];	    
}

- (void) drawPrimaryTextWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    NSString *data = [self dataForKeyPath:primaryTextKeyPath];
    if ( data == nil )
    {
        NSLog( @"Not able to draw primary text, string was nil" );
        return;
    }        
    
	NSColor *primaryColor = [self isHighlighted] ? [self textColor] : [NSColor blackColor];    
      
//    if ( [[self dataForKeyPath:highlightCellKeyPath] boolValue] == YES && ! ([self isHighlighted] ) )
//    {
//        primaryColor = [NSColor whiteColor];
//    }    
    
    // Create an NSMutableParagraphStyle to set up the line break mode.
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
                                primaryColor, NSForegroundColorAttributeName,
                                [NSFont systemFontOfSize:11], NSFontAttributeName, 
                                style, NSParagraphStyleAttributeName, nil];
    
	NSAttributedString *primaryText = [[NSAttributedString alloc] initWithString:data
                                                                      attributes:attributes];
    
	[primaryText drawInRect:cellFrame];    
}

- (void) drawSecondaryTextWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    NSString *data = [[self dataForKeyPath:secondaryTextKeyPath] copy];
    if ( data == nil )
    {
        NSLog( @"Not able to draw secondary text, string was nil" );
        return;
    }
    
    NSColor *secondaryColor = [self isHighlighted] ? [self textColor]: [NSColor grayColor];
//    
//    if ( [[self dataForKeyPath:highlightCellKeyPath] boolValue] == YES && ! ([self isHighlighted] ) )
//    {
//        secondaryColor = [NSColor whiteColor];
//    }
//    
    // Create an NSMutableParagraphStyle to set up the line break mode.
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
                                secondaryColor, NSForegroundColorAttributeName,
                                [NSFont systemFontOfSize:9], NSFontAttributeName, 
                                style, NSParagraphStyleAttributeName, nil];	
	NSAttributedString *secondaryText = [[NSAttributedString alloc] initWithString:data
                                                                        attributes:attributes];
    [secondaryText drawInRect:cellFrame];    
}

- (id) dataForKeyPath:(NSString *)keyPath
{
    return [[self objectValue] valueForKeyPath:keyPath];
}

@end

#pragma mark -
@implementation ImageTextCell


@synthesize padding;
@synthesize iconKeyPath;
@synthesize primaryTextKeyPath;
@synthesize secondaryTextKeyPath;
@synthesize highlightCellKeyPath;


- (id) objectValue 
{
    return [[super objectValue] nonretainedObjectValue];
}

- (void)setObjectValue:(id)object 
{
    id oldObjectValue = [self objectValue];
    if (object != oldObjectValue) 
    {
        [object retain];
        [oldObjectValue release];
        [super setObjectValue:[NSValue valueWithNonretainedObject:object]];
    }
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView 
{
    if ( !self.padding )
        self.padding = 5.00;

	// Draw primary text
    NSRect primaryRect = cellFrame;
    primaryRect.origin.x = cellFrame.origin.x + cellFrame.size.height + self.padding;
    primaryRect.origin.y += self.padding;
    primaryRect.size.width -= 45;
    
    [self drawPrimaryTextWithFrame:primaryRect inView:controlView];

    // Draw secondary text
    primaryRect.origin.y = cellFrame.origin.y + cellFrame.size.height / 2 + 1;
    [self drawSecondaryTextWithFrame:primaryRect inView:controlView];
    
    // Draw icon
    [self drawMainIconWithFrame:cellFrame inView:controlView];    
}
@end
