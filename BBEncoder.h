//
//  BBEncoder.h
//
//  Created by Kevin Wojniak on 1/29/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


enum {
	BBEncoderEncloseInCodeTags		= (1 << 0),
	BBEncoderReplaceTabsWithSpaces	= (1 << 1),
	BBEncoderUseStrikeFullWord		= (1 << 2),
	BBEncoderUseFontSizes			= (1 << 3),
	BBEncoderUsePointFontSizes		= (1 << 4),
};
typedef NSUInteger BBEncoderOptions;

@interface NSAttributedString (BBEncoder)

- (NSString *)bbcodeRepresentationWithOptions:(BBEncoderOptions)options;

@end
