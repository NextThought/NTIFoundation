//
//  NTIInspectorSliceObjectPair.h
//  NTIFoundation
//
//  Created by Pacifique Mahoro on 2/14/12.
//  Copyright (c) 2012 NextThought. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTIInspectorSliceObjectPair : NSObject {
	id inspectableObject;
	NSMutableArray* inspectorSlices;
}

-(id)initWithInspectableObject: (id)object andSlices: (NSArray *)slices;
-(id)inspectableObject; /* return the object being inspected*/
-(NSArray *)slices;	/* slices that the object responds to*/
-(void)addSlices: (NSArray *)slices;
-(BOOL)containsInspectableObject: (id)object; 

@end
