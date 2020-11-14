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

NS_ASSUME_NONNULL_BEGIN

@protocol MUEncoderProtocol <NSObject>

+ (nullable NSString*)markupEncodedStringFromAttributedString:(NSAttributedString*)attrString;

@optional
+ (nullable NSString*)markupEncodedStringFromAttributedString:(NSAttributedString*)attrString options:(MUEOption)options;


@end

NS_ASSUME_NONNULL_END
