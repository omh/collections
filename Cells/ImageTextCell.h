//
//  ImageTextCell.h
//  SofaControl
//
//  Created by Martin Kahr on 10.10.06.
//  Copyright 2006 CASE Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>




@interface ImageTextCell : NSTextFieldCell
{
    float padding;
	
    NSString *iconKeyPath;
	NSString *primaryTextKeyPath;
	NSString *secondaryTextKeyPath;
    NSString *highlightCellKeyPath;
}

@property( nonatomic, assign ) float padding;
@property( nonatomic, retain ) NSString *iconKeyPath;
@property( nonatomic, retain ) NSString *primaryTextKeyPath;
@property( nonatomic, retain ) NSString *secondaryTextKeyPath;
@property( nonatomic, assign ) NSString *highlightCellKeyPath;

- (id) dataForKeyPath:(NSString *)keyPath;

- (void) drawHighlightInRect:(NSRect)cellFrame;
- (void) drawMainIconWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void) drawPrimaryTextWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void) drawSecondaryTextWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end