//
//  OMHShortcutKeyTest.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 02/05/2010.
//  Copyright 2010 omh.cc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "OMHShortcutKey.h"

@interface OMHShortcutKeyTest : SenTestCase 
{
    OMHShortcutKey *hotKey;
    NSString *keyIdentifier;
    
    signed short key;
    unsigned int modifier;
}

@end
