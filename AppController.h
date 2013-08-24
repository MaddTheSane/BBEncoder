//
//  AppController.h
//  BBEncoder
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject
{
	NSAttributedString *inputString;
	NSString *bbcode;
	IBOutlet NSWindow *window;
}

@property (readwrite, retain) NSAttributedString *inputString;
@property (readwrite, retain) NSString *bbcode;

@end
