//
//  MUEncoderProtocol.h
//  BBEncoder
//
//  Created by C.W. Betts on 12/22/14.
//
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MUEOption) {
	MUEOptionEncloseInCodeTags		= (1 << 0),
	MUEOptionReplaceTabsWithSpaces	= (1 << 1),
	MUEOptionUseFontSizes			= (1 << 2),
};

@protocol MUEncoderProtocol <NSObject>

+ (NSString*)markupEncodedStringFromAttributedString:(NSAttributedString*)attrString;

@optional
+ (NSString*)markupEncodedStringFromAttributedString:(NSAttributedString*)attrString options:(MUEOption)options;


@end
