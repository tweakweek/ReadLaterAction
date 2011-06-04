//
//  InstapaperSession.m
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperSession.h"

@implementation RLAInstapaperSession
@synthesize username, password;

- (void)dealloc
{
	[username release];
	[password release];
	[super dealloc];
}

@end
