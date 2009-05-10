/**
 * @file OMHFadeWindowController.m
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

#import "OMHFadeWindowController.h"


@implementation OMHFadeWindowController

@synthesize animation;

#pragma mark -
#pragma mark Instance methods

- (id) initWithWindow:(NSWindow *)window; 
{
    self = [super initWithWindow:window];
    
    if ( self )
    {
        animation = [CABasicAnimation animation];
        [animation setDelegate:self];        
    }
    
    return self;
}

- (IBAction) showWindow:(id)sender
{
    [self.window setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"]];
    [self.window setDelegate:self];
    
    if (![self.window isVisible])
    {
        self.window.alphaValue = 0.0;
        [self.window.animator setAlphaValue:1.0];
    }
    [super showWindow:sender];
}

- (BOOL) windowShouldClose:(id)window
{
    [self.window.animator setAlphaValue:0.0];
    return NO;
}

#pragma mark -
#pragma mark Delegate methods

- (void) animationDidStop:(CAAnimation *)animation finished:(BOOL)flag 
{
    if ( self.window.alphaValue == 0.0 )
        [self close];
}

@end
