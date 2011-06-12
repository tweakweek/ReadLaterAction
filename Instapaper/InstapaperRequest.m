//
//  InstapaperRequest.m
//  newsyc
//
//  Created by Grant Paul on 4/7/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperRequest.h"
#import "InstapaperSession.h"

@implementation RLAInstapaperRequest
@synthesize session; 

- (void)dealloc {
    [session release];
    
    [super dealloc];
}

- (id)initWithSession:(RLAInstapaperSession *)session_ {
    if ((self = [super init])) {
        session = [session_ retain];
    }
    
    return self;
}

- (void)succeed {
    [[NSNotificationCenter defaultCenter] postNotificationName:kInstapaperRequestSucceededNotification object:self];
}

- (void)failWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kInstapaperRequestFailedNotification object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
}

- (void)failWithErrorText:(NSString *)text {
    NSError *error = [NSError errorWithDomain:@"instapaper" code:0 userInfo:[NSDictionary dictionaryWithObject:text forKey:NSLocalizedDescriptionKey]];
    
    [self failWithError:error];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self failWithError:error];
	[connection cancel];
	[self autorelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection cancel];
	[self autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        int status = [(NSHTTPURLResponse *) response statusCode];
        if (status == 403) [self failWithErrorText:@"Invalid username or password."];
        if (status == 500) [self failWithErrorText:@"Internal error, try again later."];
        if (status == 201) [self succeed];
    } else {
        [self failWithErrorText:@"Unknown error."];
    }
}

static inline NSString *URLEncode(NSString *string)
{
	CFStringRef result = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
	return [(NSString *)result autorelease];
}

- (void)addItemWithURL:(NSURL *)url title:(NSString *)title selection:(NSString *)selection {
    NSString *password = [session password];
    NSString *username = [session username];
    
    NSString *query = @"";
    query = [query stringByAppendingFormat:@"username=%@&", URLEncode(username)];
    if (password != nil && [password length] > 0) query = [query stringByAppendingFormat:@"password=%@&", URLEncode(password)];
    if (title != nil && [title length] > 0) query = [query stringByAppendingFormat:@"title=%@&", URLEncode(title)];
    if (selection != nil && [selection length] > 0) query = [query stringByAppendingFormat:@"&selection=%@&", URLEncode(selection)];
    query = [query stringByAppendingFormat:@"url=%@&", URLEncode([url absoluteString])];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:kInstapaperAPIAddItemURL] autorelease];
    NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%u", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    [connection autorelease];
    [self retain];
}

- (void)addItemWithURL:(NSURL *)url title:(NSString *)title {
    [self addItemWithURL:url title:title selection:nil];
}

- (void)addItemWithURL:(NSURL *)url {
    [self addItemWithURL:url title:nil selection:nil];
}

@end
