//
//  AppController.m
//  BBEncoder
//

#import "AppController.h"
#import "BBEncoder.h"
#import "ARCBridge.h"

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

static BBEncoderOptions GetBBEncoderDefaults()
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
	return options;
}

@implementation AppController

@synthesize inputString;
@synthesize bbcode;

+ (void)initialize
{
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  @YES, PREFS_ENCLOSE_IN_CODE_TAGS,
	  @YES, PREFS_REPLACE_TABS_WITHS_SPACES,
	  @YES, PREFS_USE_STRIKE_FULL_WORD,
	  @YES, PREFS_USE_SIZE,
	  @NO, PREFS_USE_POINT_SIZE,
	  nil]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notif
{
	[[NSApplication sharedApplication] setServicesProvider:self];
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
	self.bbcode = [self.inputString bbcodeRepresentationWithOptions:GetBBEncoderDefaults()];
}

static NSString *ConvertFromPasteboard(NSPasteboard *pboard, NSString **error)
{
	NSAttributedString *attrStr = nil;
	NSArray *types = [pboard types];
	if ([types containsObject:NSPasteboardTypeRTF]) {
		attrStr = [[NSAttributedString alloc] initWithRTF:[pboard dataForType:NSPasteboardTypeRTF] documentAttributes:NULL];
	} else if ([types containsObject:NSPasteboardTypeHTML]) {
		attrStr = [[NSAttributedString alloc] initWithHTML:[pboard dataForType:NSPasteboardTypeHTML] documentAttributes:NULL];
	} else if ([types containsObject:NSPasteboardTypeString]){
		return [pboard stringForType:NSPasteboardTypeString];
	} else {
		if (error) {
			*error = @"Incompatible pasteboard sent";
		}
		return nil;
	}
	

	return [AUTORELEASEOBJ(attrStr) bbcodeRepresentationWithOptions:GetBBEncoderDefaults()];
}

- (void)replaceSelected:(NSPasteboard*)pboard userData:(NSString *)userData error:(NSString **)error
{
	NSString *theString = ConvertFromPasteboard(pboard, error);
	if (theString) {
		[pboard clearContents];
		//[pboard declareTypes:@[NSStringPboardType] owner:nil];
		//[pboard setString:theString forType:NSStringPboardType];
		[pboard writeObjects:@[theString]];
	}
}

- (void)convertSelected:(NSPasteboard*)pboard userData:(NSString *)userData error:(NSString **)error
{
	NSString *theString = ConvertFromPasteboard(pboard, error);
	if (theString) {
		NSPasteboard *tmpPaste = [NSPasteboard generalPasteboard];
		[tmpPaste clearContents];
		[tmpPaste writeObjects:@[theString]];
		//NSBeginAlertSheet(@"BBCode in Pasteboard", nil, nil, nil, window, nil, NULL, NULL, NULL, @"The selected text has been copied to the pasteboard.");
	}
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
