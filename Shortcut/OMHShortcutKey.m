//
//  OMHHotKey.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 3/24/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "OMHShortcutKey.h"


@interface OMHShortcutKey()
    NSMutableDictionary *shortCutIds;   
@end


OSStatus handleGlobalHotKey( EventHandlerCallRef nextHandler, EventRef theEvent, void *userData )
{ 
    EventHotKeyID hotKeyID;
    GetEventParameter( theEvent, kEventParamDirectObject, typeEventHotKeyID, 
                      NULL, sizeof( hotKeyID ), NULL, &hotKeyID );
    NSNumber *hotKeyId = [NSNumber numberWithInt:hotKeyID.id];
    
    [[OMHShortcutKey sharedShortcutKey] handleHotKey:hotKeyId];
    
    return noErr;
}


@implementation OMHShortcutKey
@synthesize delegate;


#pragma mark -
#pragma mark Class methods

+ (OMHShortcutKey *) sharedShortcutKey
{
    static OMHShortcutKey *sharedHotKey;
    
    if ( !sharedHotKey )
        sharedHotKey = [[OMHShortcutKey alloc] init];
    
    return sharedHotKey;
}


#pragma mark -
#pragma mark Initialization and Setup

- (id) init;
{
    shortCutIds = [[NSMutableDictionary alloc] init];        
    return self;
}


#pragma mark -
#pragma mark Methods

- (void) registerShortcutKey:(NSString *)identifier key:(signed short)key modifier:(unsigned int)modifier;
{
    NSNumber *NSHotId = [NSNumber numberWithInt:[shortCutIds count] + 1];
    
    EventHotKeyRef hotKeyRef;
    EventHotKeyID hotKeyID;
    EventTypeSpec eventType;

    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;

    hotKeyID.signature = 'htk1';
    hotKeyID.id = [NSHotId intValue];
    
    InstallApplicationEventHandler( &handleGlobalHotKey, 1, &eventType, NULL, NULL );
    RegisterEventHotKey( key, modifier, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef );    
    
    NSData *hotKeyRefData = [NSData dataWithBytes:&hotKeyRef length:sizeof( hotKeyRef )];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:identifier, @"identifier", 
                                                                    hotKeyRefData, @"eventHotKeyRef", nil];
    [shortCutIds setObject:dict forKey:NSHotId];
}

- (void) unRegisterShortcutKey:(NSString *)identifier;
{
    for ( id item in shortCutIds )
    {   
        NSDictionary *dict = [shortCutIds objectForKey:item];
        if ( [[dict objectForKey:@"identifier"] isEqualToString:identifier] )
        {
            NSData *hotKeyRefData = [dict objectForKey:@"eventHotKeyRef"];
            EventHotKeyRef hotKeyRef;
            [hotKeyRefData getBytes:&hotKeyRef length:sizeof( EventHotKeyRef )];
            
            UnregisterEventHotKey( hotKeyRef );
            break;
        }
    }
}

- (void) handleHotKey:(NSNumber *)hotKeyId;
{
    NSString *identifier = [[shortCutIds objectForKey:hotKeyId] objectForKey:@"identifier"];

    if ( [delegate respondsToSelector:@selector( handleHotKey: )] )
    {
        [delegate performSelector:@selector( handleHotKey: ) withObject:identifier];
    }
}

@end