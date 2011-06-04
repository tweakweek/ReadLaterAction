//
//  InstapaperSession.h
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperAPI.h"

@interface RLAInstapaperSession : NSObject {
@private
    NSString *username;
    NSString *password;
}

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end

