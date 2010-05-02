//
//  OMHShortcutKeyTest.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 02/05/2010.
//  Copyright 2010 omh.cc. All rights reserved.
//

#import "OMHShortcutKeyTest.h"


@implementation OMHShortcutKeyTest

#pragma mark -
#pragma mark Setup/tear down

- (void) setUp
{
    [OMHShortcutKey reset];
    hotKey = [OMHShortcutKey sharedShortcutKey];
    keyIdentifier = @"TestShortCutKey";
    
    // Ctrl+Command+C
    key = 8;
    modifier = 768;    
}

- (void) tearDown
{
    [OMHShortcutKey reset];
}

#pragma mark -
#pragma mark Unit tests

- (void) testRegisterShortcut
{
    [hotKey registerShortcutKey:keyIdentifier key:key modifier:modifier];
    STAssertEquals( [hotKey.shortCutIds count], (NSUInteger) 1, @"Wrong number of shortcuts registered" );
}

- (void) testUnregisterShortcut
{
    [hotKey unRegisterShortcutKey:keyIdentifier];
    STAssertEquals( [hotKey.shortCutIds count], (NSUInteger) 0, @"Wrong number of shortcuts registered" );
}

#pragma mark -
#pragma mark Bug fixes

/**
 * Test case for issue: key shortcuts don't take effect until clyppan is restarted
 * @link http://github.com/omh/clyppan/issues/3
 *
 * This bug was caused due to how the hot key id was generated. The id was
 * generated using the dict's count, which is silly, of course, as can go up
 * and down. Since the id was the key of this dict elements in the dict
 * could be overwritten by new elements if the count had changed.
 */
- (void) testIssue3
{
    [hotKey registerShortcutKey:keyIdentifier key:key modifier:modifier];

    signed short key2 = 5;
    unsigned int modifier2 = 700;
    NSString *keyIdentifier2 = @"TestShortCutKey2";
    
    [hotKey registerShortcutKey:keyIdentifier2 key:key2 modifier:modifier2];
    [hotKey unRegisterShortcutKey:keyIdentifier];
    
        // Before fixing this issue this would overwrite keyIdentifier2
    [hotKey registerShortcutKey:keyIdentifier key:key modifier:modifier];   
    
    STAssertEquals( [hotKey.shortCutIds count], (NSUInteger) 2, @"Wrong number of shortcuts registered" );
}


@end
