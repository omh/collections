//
//  OMHHotKey.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 3/24/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OMHShortcutKey: NSObject 
{
    id delegate;   
}

// Properties
@property( nonatomic, assign ) id delegate;

// Class methods
+ (OMHShortcutKey *) sharedShortcutKey;

// Instance methods
- (void) registerShortcutKey:(NSString *)identifier key:(signed short)key modifier:(unsigned int)modifier;
- (void) unRegisterShortcutKey:(NSString *)identifier;

// Delegation methods
- (void) handleHotKey:(NSNumber *)hotKeyId;

@end