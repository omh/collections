/**
 * @file OMHShortcutKey.m
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

#import <Carbon/Carbon.h>
#import "OMHShortcutKey.h"


@interface OMHShortcutKey()
    - (void) handleHotKey:(NSNumber *)hotKeyId;
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
    if ( [super init] == self )
    {
        shortCutIds = [[NSMutableDictionary alloc] init];      
    }
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