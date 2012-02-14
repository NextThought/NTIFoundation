//
//  NTIInspectorSliceObjectPair.m
//  NTIFoundation
//
//  Created by Pacifique Mahoro on 2/14/12.
//  Copyright (c) 2012 NextThought. All rights reserved.
//

#import "NTIInspectorSliceObjectPair.h"

@implementation NTIInspectorSliceObjectPair

-(id)initWithInspectableObject: (id)object andSlices: (NSArray *)slices
{
	self = [super init];
	if (self) {
		self->inspectableObject = object;
		self->inspectorSlices = slices;
	}
	return self;
}

-(void)addSlice: (id)slice
{
	self->inspectorSlices = [self->inspectorSlices arrayByAddingObject: slice];
}

-(NSArray *)slices
{
	return self->inspectorSlices;
}

-(id)inspectableObject
{
	return inspectableObject;
}

@end
