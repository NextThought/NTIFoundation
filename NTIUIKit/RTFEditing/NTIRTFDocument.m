//Initially based on code copyright 2010 by the omni group. 
// Copyright 2010-2011 The Omni Group.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import "NTIRTFDocument.h"

#import "NSAttributedString-HTMLReadingExtensions.h"
#import "NSAttributedString-HTMLWritingExtensions.h"

@implementation NTIRTFDocument

@synthesize text;

+(NSString*)stringFromString: (NSString*)rtfOrPlain
{
	return [self attributedStringWithString: rtfOrPlain].string;
}

+(NSAttributedString*)attributedStringWithString: (NSString*)rtfString
{
	NSAttributedString* result = nil;
	if( [rtfString hasPrefix: @"{\\rtf1"] ) {
		//This could probably be ported to the new document type stuff. There are both rtf and rtfd document types.
		OBASSERT_NOT_REACHED("RTF no longer supported");
//		result = [OUIRTFReader parseRTFString: rtfString];
	}
	else if( [rtfString hasPrefix: @"<"] || [rtfString containsString: @"</"] ) {
		//The web app likes to send in fragments so we cannot count on the prefix
		//and we have to try to parse (should probably use some regex?)
		result = [NSAttributedString stringFromHTML: rtfString];
		if( !result ) {
			result = [[NSAttributedString alloc]
					   initWithString: rtfString];
		}
	}
	else if( rtfString ) {
		result = [[NSAttributedString alloc]
					 initWithString: rtfString];
	}
	else {
		result = [[NSAttributedString alloc] init];
	}
	return result;
}

-(id)initWithString: (NSString*)string
{
	return [self initWithAttributedString: [NTIRTFDocument attributedStringWithString: string]];
}

-(id)initWithAttributedString: (NSAttributedString*)string
{
	self = [super init];
	if( !string ) {
		// TODO: Better handling
		OBFinishPorting;
		return nil;
	}
	self->text = [string copy];
	return self;
}


-(NSString*)plainString
{
	return [self->text string];
}

-(NSString*)rtfString
{
	//This could probably be ported to the new document type stuff. There are both rtf and rtfd document types.
	OBASSERT_NOT_REACHED("RTF no longer supported");
	return nil;
    //NSData* data = [OUIRTFWriter rtfDataForAttributedString: self->text];
	//return [[NSString alloc] initWithData: data
								 //encoding: NSUTF8StringEncoding];
}

-(NSString*)htmlString
{
	NSString* html = [self->text htmlStringFromString];
	return html;
}

-(NSString*)externalString
{
	return [self htmlString];	
}

-(NSString*)htmlStringWrappedIn: (NSString*)element
{
	NSString* html = [self->text htmlStringFromStringWrappedIn: element];
	return html;
}


@end
