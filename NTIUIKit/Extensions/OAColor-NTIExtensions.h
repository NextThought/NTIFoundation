//
//  OAColor-NTIExtensions.h
//  NextThoughtApp
//
//  Created by Jason Madden on 2011/07/29.
//  Copyright 2011 NextThought. All rights reserved.
//

#import "OmniAppKit/OAColor.h"
#import "NTIUtilities.h"

@interface OAColor (NTIExtensions)
@property (readonly,nonatomic) NSString* cssString;
@property (readonly,nonatomic) CGColorRef rgbaCGColorRef;

-(CGColorRef)rgbaCGColorRef NTI_METHOD_FAMILY_NEW;

@end