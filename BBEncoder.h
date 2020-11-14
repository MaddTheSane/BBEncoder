//
//  BBEncoder.h
//
//  Created by Kevin Wojniak on 1/29/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef NS_OPTIONS(NSUInteger, BBEncoderOptions) {
	BBEncoderEncloseInCodeTags		= (1 << 0),
	BBEncoderReplaceTabsWithSpaces	= (1 << 1),
	BBEncoderUseStrikeFullWord		= (1 << 2),
	BBEncoderUseFontSizes			= (1 << 3),
	BBEncoderUsePointFontSizes		= (1 << 4),
};

@interface NSAttributedString (BBEncoder)

/// This uses enclosed code tags, replace tabs with spaces, use full-word strike, and font sizes
@property (readonly, copy) NSString *bbcodeRepresentation;
- (NSString *)bbcodeRepresentationWithOptions:(BBEncoderOptions)options;

@end
