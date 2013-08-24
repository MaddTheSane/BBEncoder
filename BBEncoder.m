//
//  BBEncoder.m
//
//  Created by Kevin Wojniak on 1/29/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//
//  See included LICENSE.txt.

#import "BBEncoder.h"
#import "ARCBridge.h"

@interface NSColor (BBEncoder)
- (NSString *)bbcodeRepresentation;
@end

@interface NSFont (BBEncoder)
- (int)bbcodeSize;
@end

@implementation NSColor (BBEncoder)

- (NSString *)bbcodeRepresentation
{
	CGFloat r = 0.0, g = 0.0, b = 0.0;
	NSColor *rgbColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[rgbColor getRed:&r green:&g blue:&b alpha:NULL];
	return [NSString stringWithFormat:@"#%02x%02x%02x", (uint8_t)(r * 255), (uint8_t)(g * 255), (uint8_t)(b * 255)];
}

@end

@implementation NSFont (BBEncoder)

#define BBSIZE_DEFAULT	2

- (int)bbcodeSize
{
	// Find the closest BBCode SIZE that corresponds to the NSFont's pointSize value.
	// Most forums only support SIZE = 1 - 7, where 2 is the default value. The values
	// in sizeTable are the point sizes that Safari 5 uses for SIZE = 1 - 7.
	static const int sizeTable[] = {10, 13, 16, 18, 24, 32, 48};
	const int pointSize = (int)[self pointSize];
	static const int numSizes =  sizeof(sizeTable) / sizeof(sizeTable[0]);
	for (int i=0; i<numSizes; i++) {
		int isLast = (i == numSizes - 1);
		if (pointSize <= sizeTable[i]) {
			return i + 1;
		} else if (!isLast && sizeTable[i] < pointSize && sizeTable[i+1] > pointSize) {
			if ((pointSize - sizeTable[i]) < (pointSize - sizeTable[i+1])) {
				return i + 1;
			} else {
				return i + 2;
			}
		} else if (isLast) {
			return i + 1;
		}
	}
	return BBSIZE_DEFAULT;
}

@end

@implementation NSAttributedString (BBEncoder)

#define BBTAG_BOLD			@"b"
#define BBTAG_UNDERLINE		@"u"
#define BBTAG_ITALICS		@"i"
#define BBTAG_COLOR			@"color"
#define BBTAG_URL			@"url"
#define BBTAG_LEFT			@"left"
#define BBTAG_RIGHT			@"right"
#define BBTAG_CENTER		@"center"
#define BBTAG_SIZE			@"size"
#define BBTAG_STRIKE		@"s"
#define BBTAG_STRIKE_FULL	@"strike"

- (NSString *)bbcodeRepresentation
{
	//return [self bbcodeRepresentationWithOptions:(BBEncoderEncloseInCodeTags | BBEncoderReplaceTabsWithSpaces |BBEncoderUseStrikeFullWord |  BBEncoderUseFontSizes)];
	return [self bbcodeRepresentationWithOptions:15];
}

- (NSString *)bbcodeRepresentationWithOptions:(BBEncoderOptions)options
{
	NSMutableString *output = [[NSMutableString alloc] initWithCapacity:self.string.length];
	@autoreleasepool {
		NSRange maxRange = NSMakeRange(0, [self length]);
		NSRange range = NSMakeRange(0, 0);
		NSDictionary *attrs = nil;
		
		if (maxRange.length == 0 || maxRange.location == NSNotFound) {
			return nil;
		}
		
		do {
			attrs = [self attributesAtIndex:NSMaxRange(range) longestEffectiveRange:&range inRange:maxRange];
			NSMutableArray *tags = [[NSMutableArray alloc] initWithCapacity:[attrs count]];
			for (NSString *attributeName in attrs) {
				id value = [attrs objectForKey:attributeName];
				if ([attributeName isEqualToString:NSFontAttributeName]) {
					NSFont *font = (NSFont *)value;
					NSFontTraitMask traits = [[NSFontManager sharedFontManager] traitsOfFont:font];
					if (traits & NSBoldFontMask) {
						[output appendFormat:@"[%@]", BBTAG_BOLD];
						[tags addObject:BBTAG_BOLD];
					}
					if (traits & NSItalicFontMask) {
						[output appendFormat:@"[%@]", BBTAG_ITALICS];
						[tags addObject:BBTAG_ITALICS];
					}
					int bbcodeSize = [font bbcodeSize];
					if ((bbcodeSize != BBSIZE_DEFAULT) && (options & BBEncoderUseFontSizes)) {
						[output appendFormat:@"[%@=%d]", BBTAG_SIZE, (options & BBEncoderUsePointFontSizes) ? (int)[font pointSize] : bbcodeSize];
						[tags addObject:BBTAG_SIZE];
					}
				} else if ([attributeName isEqualToString:NSUnderlineStyleAttributeName]) {
					[output appendFormat:@"[%@]", BBTAG_UNDERLINE];
					[tags addObject:BBTAG_UNDERLINE];
				} else if ([attributeName isEqualToString:NSForegroundColorAttributeName]) {
					[output appendFormat:@"[%@=%@]", BBTAG_COLOR, [(NSColor *)value bbcodeRepresentation]];
					[tags addObject:BBTAG_COLOR];
				} else if ([attributeName isEqualToString:NSLinkAttributeName]) {
					[output appendFormat:@"[%@=%@]", BBTAG_URL, [(NSURL *)value absoluteString]];
					[tags addObject:BBTAG_URL];
				} else if ([attributeName isEqualToString:NSParagraphStyleAttributeName]) {
					NSParagraphStyle *paragraphStyle = (NSParagraphStyle *)value;
					switch ([paragraphStyle alignment]) {
						case NSLeftTextAlignment:
							//TODO: check the language for RTL languages and code accordingly.
							//[output appendFormat:@"[%@]", BBTAG_LEFT];
							//[tags addObject:BBTAG_LEFT];
							break;
						case NSRightTextAlignment:
							[output appendFormat:@"[%@]", BBTAG_RIGHT];
							[tags addObject:BBTAG_RIGHT];
							break;
						case NSCenterTextAlignment:
							[output appendFormat:@"[%@]", BBTAG_CENTER];
							[tags addObject:BBTAG_CENTER];
							break;
					}
				} else if ([attributeName isEqualToString:NSStrikethroughStyleAttributeName]) {
					NSNumber *strikeNum = (NSNumber *)value;
					if ([strikeNum intValue] > 0) {
						NSString *strikeTag = options & BBEncoderUseStrikeFullWord ? BBTAG_STRIKE_FULL : BBTAG_STRIKE;
						[output appendFormat:@"[%@]", strikeTag];
						[tags addObject:strikeTag];
					}
				}
			}
			
			[output appendString:[[self string] substringWithRange:range]];
			
			for (NSString *tag in [tags reverseObjectEnumerator]) {
				[output appendFormat:@"[/%@]", tag];
			}
			RELEASEOBJ(tags);
		} while (NSMaxRange(range) < maxRange.location + maxRange.length);
		
		if (options & BBEncoderReplaceTabsWithSpaces) {
			[output replaceOccurrencesOfString:@"\t" withString:@"    " options:0 range:NSMakeRange(0, [output length])];
		}
		
		if (options & BBEncoderEncloseInCodeTags) {
			[output insertString:@"[code]" atIndex:0];
			[output insertString:@"[/code]" atIndex:[output length]];
		}
	}
	return AUTORELEASEOBJ(output);
}

@end
