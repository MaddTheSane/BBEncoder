//
//  AppController.m
//  BBEncoder
//

#import "AppController.h"
#import "BBEncoder.h"

#define PREFS_ENCLOSE_IN_CODE_TAGS		@"EncloseInCodeTags"
#define PREFS_REPLACE_TABS_WITHS_SPACES	@"ReplaceTabsWithSpaces"
#define PREFS_USE_STRIKE_FULL_WORD		@"UseStrikeFullWord"
#define PREFS_USE_SIZE					@"UseSize"
#define PREFS_USE_POINT_SIZE			@"UsePointSize"

enum {
	BBInputFormatted,
	BBInputHTML,
};
typedef NSUInteger BBInput;

@implementation AppController

@synthesize inputString, bbcode;

+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  @YES, PREFS_ENCLOSE_IN_CODE_TAGS,
							  @YES, PREFS_REPLACE_TABS_WITHS_SPACES,
							  @YES, PREFS_USE_STRIKE_FULL_WORD,
							  @YES, PREFS_USE_SIZE,
							  @NO, PREFS_USE_POINT_SIZE,
							  nil];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notif
{
	[self addObserver:self forKeyPath:@"inputString" options:0 context:NULL];
	NSUserDefaultsController *userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	[userDefaultsController addObserver:self forKeyPath:@"values."PREFS_ENCLOSE_IN_CODE_TAGS options:0 context:NULL];
	[userDefaultsController addObserver:self forKeyPath:@"values."PREFS_REPLACE_TABS_WITHS_SPACES options:0 context:NULL];
	[userDefaultsController addObserver:self forKeyPath:@"values."PREFS_USE_STRIKE_FULL_WORD options:0 context:NULL];
	[userDefaultsController addObserver:self forKeyPath:@"values."PREFS_USE_SIZE options:0 context:NULL];
	[userDefaultsController addObserver:self forKeyPath:@"values."PREFS_USE_POINT_SIZE options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	BBEncoderOptions options = 0;
	id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
	if ([[values valueForKey:PREFS_ENCLOSE_IN_CODE_TAGS] boolValue]) {
		options |= BBEncoderEncloseInCodeTags;
	}
	if ([[values valueForKey:PREFS_REPLACE_TABS_WITHS_SPACES] boolValue]) {
		options |= BBEncoderReplaceTabsWithSpaces;
	}
	if ([[values valueForKey:PREFS_USE_STRIKE_FULL_WORD] boolValue]) {
		options |= BBEncoderUseStrikeFullWord;
	}
	if ([[values valueForKey:PREFS_USE_SIZE] boolValue]) {
		options |= BBEncoderUseFontSizes;
	}
	if ([[values valueForKey:PREFS_USE_POINT_SIZE] boolValue]) {
		options |= 	BBEncoderUsePointFontSizes;
	}

	
	self.bbcode = [self.inputString bbcodeRepresentationWithOptions:options];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
