#import <UIKit/UIKit2.h>
#import <WebKit/WebKit.h>
#import <WebCore/WebCore.h>
#import <Preferences/Preferences.h>
#import "ActionMenu.h"
#import "Instapaper/InstapaperSession.h"
#import "Instapaper/InstapaperRequest.h"

// Additional Private APIs

@interface UIWebBrowserView (WebPrivate)
- (WebFrame *)_focusedOrMainFrame;
@end

@interface WebFrame (WebPrivate)
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)string forceUserGesture:(BOOL)forceUserGesture;
@end

@implementation UIWebBrowserView (ReadLaterAction)

static inline void Alert(NSString *message)
{
	// Helper function
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Read Later" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[av show];
	[av release];
}

- (BOOL)canDoReadLaterAction:(id)sender
{
	WebThreadLock();
	WebFrame *webFrame = [self _focusedOrMainFrame];
	// Check to see if web view contains a URL we can Read Later
	NSString *URL = [webFrame stringByEvaluatingJavaScriptFromString:@"location.href" forceUserGesture:NO];
	WebThreadUnlock();
	return [URL hasPrefix:@"http://"] || [URL hasPrefix:@"https://"];
}

- (void)performReadLaterAction:(id)sender
{
	// Load Settings
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpetrich.readlater.plist"];
	NSString *username = [settings objectForKey:@"RLLogin"];
	if ([username length] == 0) {
		// Username is empty
		Alert(@"Instapaper login not yet set.\nEnter your Instapaper email and password in ActionMenu settings.");
	} else {
		// Create a session
		RLAInstapaperSession *session = [[RLAInstapaperSession alloc] init];
		session.username = username;
		session.password = [settings objectForKey:@"RLPassword"];
		// Create a request
		RLAInstapaperRequest *request = [[RLAInstapaperRequest alloc] initWithSession:session];
		[session release];
		// Add the item with specified URL
		WebThreadLock();
		WebFrame *webFrame = [self _focusedOrMainFrame];
		// Use selection for summary text
		NSString *selection = [self selectedTextualRepresentation];
		// If selection equals all then set to nil (probably nothing was selected)
		if ([selection isEqualToString:[self textualRepresentation]]) selection = nil;
		// Truncate length of summary (Instapaper shows upto 200 chars in main list)
		#define LEN 500
		selection = [selection length] <= LEN ? selection :
					[[selection substringToIndex:LEN] stringByAppendingString:@".."];
		[request addItemWithURL:[NSURL URLWithString:[webFrame stringByEvaluatingJavaScriptFromString:@"location.href" forceUserGesture:NO]]
						  title:[webFrame stringByEvaluatingJavaScriptFromString:@"document.title" forceUserGesture:NO]
						  selection:selection];
		WebThreadUnlock();
		[request release];
	}
}

+ (void)readLaterActionSucceeded:(NSNotification *)notification
{
	Alert(@"Link submitted to Instapaper.");
}

+ (void)readLaterActionFailed:(NSNotification *)notification
{
	Alert([[notification.userInfo objectForKey:@"error"] localizedDescription]);
}

+ (void)load
{
	id<AMMenuItem> menuItem = [[UIMenuController sharedMenuController] registerAction:@selector(performReadLaterAction:) title:@"Read Later" canPerform:@selector(canDoReadLaterAction:) forPlugin:@"ReadLater"];
	menuItem.priority = 1000;
	menuItem.image = [UIImage imageWithContentsOfFile:([UIScreen mainScreen].scale == 2.0f) ? @"/Library/ActionMenu/Plugins/Instapaper@2x.png" : @"/Library/ActionMenu/Plugins/Instapaper.png"];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(readLaterActionSucceeded:) name:kInstapaperRequestSucceededNotification object:nil];
	[nc addObserver:self selector:@selector(readLaterActionFailed:) name:kInstapaperRequestFailedNotification object:nil];
}

@end

// Settings bundle controller

@interface ReadLaterSettingsController : PSListController
@end

@implementation ReadLaterSettingsController

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target
{
	return [super loadSpecifiersFromPlistName:@"ReadLater" target:self];
}

@end
