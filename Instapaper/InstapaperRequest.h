//
//  InstapaperRequest.h
//  newsyc
//
//  Created by Grant Paul on 4/7/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperAPI.h"

@class RLAInstapaperSession;
@interface RLAInstapaperRequest : NSObject {
    RLAInstapaperSession *session;
}

@property (nonatomic, readonly) RLAInstapaperSession *session;

- (void)addItemWithURL:(NSURL *)url title:(NSString *)title selection:(NSString *)selection;
- (void)addItemWithURL:(NSURL *)url title:(NSString *)title;
- (void)addItemWithURL:(NSURL *)url;

- (id)initWithSession:(RLAInstapaperSession *)session_;

@end

#define kInstapaperRequestSucceededNotification @"rla-instapaper-request-completed"
#define kInstapaperRequestFailedNotification @"rla-instapaper-request-failed"

