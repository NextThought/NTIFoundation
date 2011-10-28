//
//  NSAttributedString-NTIExtensions.m
//  NTIFoundation
//
//  Created by Christopher Utz on 10/25/11.
//  Copyright (c) 2011 NextThought. All rights reserved.
//

#import "NSAttributedString-NTIExtensions.h"
#import <OmniAppKit/OATextAttachment.h>
#import <OmniAppKit/OATextStorage.h>

@implementation NSAttributedString(NTIExtensions)

+(NSAttributedString*)attributedStringFromAttributedStrings: (NSArray*)attrStrings
{
	NSAttributedString* attrString = [[NSAttributedString alloc] init];
	
	return [attrString attributedStringByAppendingChunks: attrStrings];
}

static void appendChunkSeparator(NSMutableAttributedString* mAttrString)
{
	unichar attachmentCharacter = OAAttachmentCharacter;
	[mAttrString appendString: [NSString stringWithCharacters: &attachmentCharacter
												  length: 1] 
			  attributes: [NSDictionary dictionaryWithObject:  [[NSObject alloc] init]
													  forKey: kNTIChunkSeparatorAttributeName]];
}

-(NSAttributedString*)attributedStringByAppendingChunks: (NSArray*)chunks
{
	NSMutableAttributedString* mutableAttrString = [[NSMutableAttributedString alloc] 
													initWithAttributedString: self];
	
	//Do we need to start a new chunk?
	if( self.length > 0 && ![self attribute: kNTIChunkSeparatorAttributeName 
									atIndex: self.length - 1 
							 effectiveRange: NULL] ){
		appendChunkSeparator(mutableAttrString);
	}
	
	for(NSUInteger i = 0 ; i < [chunks count]; i++){
		NSAttributedString* attrString = [chunks objectAtIndex: i];
		
		[mutableAttrString appendAttributedString: attrString];
		appendChunkSeparator(mutableAttrString);
	}
	
	return [[NSAttributedString alloc] initWithAttributedString: mutableAttrString];
}

-(NSAttributedString*)attributedStringByAppendingChunk:(NSAttributedString *)chunk
{
	NSMutableAttributedString* mutableAttrString = [[NSMutableAttributedString alloc] 
													initWithAttributedString: self];
	
	//Do we need to start a new chunk?
	if( self.length > 0 && ![self attribute: kNTIChunkSeparatorAttributeName 
									atIndex: self.length - 1 
							 effectiveRange: NULL] ){
		appendChunkSeparator(mutableAttrString);
	}
	
	[mutableAttrString appendAttributedString: chunk];
	
	appendChunkSeparator(mutableAttrString);
	
	return [[NSAttributedString alloc] initWithAttributedString: mutableAttrString];
}

//In the perfect case parts are separated by an attachment charater that
//has our special chunking attribute.  However, it is possible that this character
//ends up deleted leaving two different types of objects in what appears to be 
//the same part.  We identify this change in object type be checking if the
//attachment cell responds to exportHTMLToDataBuffer.  If it does it can be lumped
//in with the text part..
-(NSArray*)attributedStringsFromParts;
{
	NSMutableArray* result = [NSMutableArray arrayWithCapacity: 5];
	unichar attachmentCharacter = OAAttachmentCharacter;
	NSString* potentialSeparatorString = [NSString stringWithCharacters: &attachmentCharacter
																 length: 1];
	
	//Starting at the beginning of the attrString find the first potential part split (OAAttachmentCharacter)
	NSRange searchResult;
	NSUInteger partStartLocation = 0;
	NSRange searchRange = NSMakeRange(partStartLocation, self.length);
	do{	
		searchResult = [self.string rangeOfString: potentialSeparatorString options: 0 range:searchRange];
		
		//The easy case is that there is no potential separator left.  When this happens
		//We collect from the partStart to the end of the string
		if(searchResult.location == NSNotFound){
			NSRange partRange = NSMakeRange(partStartLocation, self.length - partStartLocation);
			NSAttributedString* part = [self attributedSubstringFromRange: partRange];
			if(part && part.length > 0){
				[result addObject: part];
			}
			partStartLocation = NSMaxRange(partRange) + 1;
			NSUInteger searchLength = partStartLocation < self.length ? self.length - partStartLocation : 0;
			searchRange = NSMakeRange(partStartLocation, searchLength);
		}
		//We found a potential split
		else{
			//There are three posibilities here
			//1. potential split is a split triggered by a separator
			//2. potential split is a split triggered by an attachment that can't be
			//	 written as html
			//3. not a split
			//TODO Need test cases for 2 and 3
			
			OATextAttachment* textAttachment = [self attribute: OAAttachmentAttributeName 
													   atIndex: searchResult.location 
												effectiveRange: NULL];
			
			//Case 1.  we are a split b/c of a separator
			if( [self attribute: kNTIChunkSeparatorAttributeName 
						atIndex: searchResult.location 
				 effectiveRange: NULL] ){
				//The part is everything from the partStart to the separator exclusive
				NSRange partRange = NSMakeRange(partStartLocation, searchResult.location - partStartLocation);
				NSAttributedString* part = [self attributedSubstringFromRange: partRange];
				if(part && part.length > 0){
					[result addObject: part];
				}
				
				//Now we need to look for the next part
				//starting at the character past the separator
				partStartLocation = NSMaxRange(partRange) + 1;
				NSUInteger searchLength = partStartLocation <= self.length ? self.length - partStartLocation : 0;
				searchRange = NSMakeRange(partStartLocation, searchLength);
			}
			//Case 2. we are a split b/c of an attachment cell that cant be written as html
			else if(    textAttachment
					&& ![(id)[textAttachment attachmentCell] respondsToSelector: @selector(htmlWriter:exportHTMLToDataBuffer:withSize:)]){
				//The part is everything from the partStart to the separator exclusive
				NSRange partRange = NSMakeRange(partStartLocation,searchResult.location - partStartLocation);
				NSAttributedString* part = [self attributedSubstringFromRange: partRange];
				if(part && part.length > 0){
					[result addObject: part];
				}
				//Next partStart is the character that was our separator
				partStartLocation = searchResult.location;
				NSUInteger searchLength = partStartLocation + 1 <= self.length ? self.length - (partStartLocation + 1) : 0;
				searchRange = NSMakeRange(partStartLocation + 1, searchLength);
				
			}
			//Case 3 we aren't a split
			else{
				//We need to continue our search after the potential split
				//character we just checked
				
				//Do we have anymore characters to check
				if(searchResult.location < self.length - 1 ){
					NSUInteger nextSearchStart = NSMaxRange(searchResult);
					NSUInteger searchLength = nextSearchStart <= self.length ? self.length - nextSearchStart : 0;
					searchRange = NSMakeRange(nextSearchStart, searchLength);
				}
				//No more searching to do... we are in the last part
				//gather it up and finish
				else{
					NSRange partRange = NSMakeRange(partStartLocation, self.length - partStartLocation);
					NSAttributedString* part = [self attributedSubstringFromRange: partRange];
					if(part && part.length > 0){
						[result addObject: part];
					}
					partStartLocation = NSMaxRange(partRange) + 1;
					NSUInteger searchLength = partStartLocation <= self.length ? self.length - partStartLocation : 0;
					searchRange = NSMakeRange(partStartLocation, searchLength);
				}
			}
			
		}
		
	}while (   searchResult.location != NSNotFound 
			&& NSMaxRange(searchRange) <= self.length );	

	
	
//	NSMutableArray* result = [NSMutableArray arrayWithCapacity: 5];
//	
//	unichar attachmentCharacter = OAAttachmentCharacter;
//	NSString* separatorString = [NSString stringWithCharacters: &attachmentCharacter
//													    length: 1];
//	NSRange searchResult;
//	NSUInteger partStartLocation = 0;
//	NSRange searchRange = NSMakeRange(partStartLocation, self.length);
//	do{
//		searchResult = [self.string rangeOfString: separatorString options: 0 range:searchRange];
//		
//		//If its not found our part is from the search start to search end (end of string)
//		NSRange partRange = NSMakeRange(NSNotFound, 0);
//		if(searchResult.location == NSNotFound){
//			partRange = NSMakeRange(partStartLocation, self.length - partStartLocation);
//		}
//		//We found a result.  Part range is from the search start to the searchresult location
//		else{
//			//There are two cases here.  We found our part separator or we found some other special
//			//attachment marker.  The former case means we snag this part and stuff it in the array
//			//In the latter case we have to keep looking
//			if( [self attribute: kNTIChunkSeparatorAttributeName 
//							  atIndex: searchResult.location 
//					   effectiveRange: NULL] ){
//				
//				//Remember the result of rangeOfString is w.r.t the whole string not the range you search
//				partRange = NSMakeRange(partStartLocation, searchResult.location - partStartLocation);
//			}
//			
//			//Update search range so next go around we look further on in the string
//			searchRange = NSMakeRange(NSMaxRange(searchResult), 
//									  MAX(0UL, self.length - (searchResult.location+1)));
//		}
//		
//		if(partRange.location != NSNotFound){
//			NSAttributedString* part = [self attributedSubstringFromRange: partRange];
//			partStartLocation += partRange.length + 1;
//			if(part && part.length > 0){
//				[result addObject: part];
//			}
//		}
//		
//	}while (   searchResult.location != NSNotFound 
//			&& NSMaxRange( searchRange ) <= self.length);	
	
	return [NSArray arrayWithArray: result];
}

@end
