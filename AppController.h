//
//  AppController.h
//  BBEncoder
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject
@property (weak) IBOutlet NSWindow *window;
@property (readwrite, retain) NSAttributedString *inputString;
@property (readwrite, retain) NSString *bbcode;

@end
