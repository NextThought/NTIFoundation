//
//  NTIMathAbstractBinaryCombiningSymbol.m
//  NTIFoundation
//
//  Created by Pacifique Mahoro on 4/11/12.
//  Copyright (c) 2012 NextThought. All rights reserved.
//

#import "NTIMathAbstractBinaryCombiningSymbol.h"
#import "NTIMathGroup.h"
#import "NTIMathPlaceholderSymbol.h"
#import "NTIMathOperatorSymbol.h"

@interface NTIMathAbstractBinaryCombiningSymbol() 
-(NSUInteger)precedenceLevelForString: (NSString *)opString;
-(NTIMathSymbol *)addAsChildMathSymbol: (NTIMathSymbol *)newMathSymbol;
@end

@implementation NTIMathAbstractBinaryCombiningSymbol
@synthesize leftMathNode, rightMathNode, operatorMathNode;


-(id)initWithMathOperatorSymbol: (NSString *)operatorString
{
	self = [super init];
	if (self) {
		self->operatorMathNode = [[NTIMathOperatorSymbol alloc] initWithValue:operatorString];
		self.leftMathNode = [[NTIMathPlaceholderSymbol alloc] init];
		self.rightMathNode = [[NTIMathPlaceholderSymbol alloc] init];
		self->precedenceLevel = [self precedenceLevelForString: operatorString];
	}
	return self;
}

-(NSUInteger)precedenceLevelForString: (NSString *)opString
{
	if ([opString isEqualToString: @"*"] || 
		[opString isEqualToString: @"/"] || 
		[opString isEqualToString:@"÷"]) {
		return 50;
	}
	if ([opString isEqualToString: @"+"] || 
		[opString isEqualToString: @"-"]) {
		return 40;
	}
	return 0;
}

-(NSUInteger)precedenceLevel
{
	//Abstract binary pl
	return self->precedenceLevel; 
}

-(void)setLeftMathNode:(NTIMathSymbol *)aLeftMathNode
{
	self->leftMathNode = aLeftMathNode;
	self->leftMathNode.parentMathSymbol = self;
}

-(void)setRightMathNode:(NTIMathSymbol *)aRightMathNode
{
	self->rightMathNode = aRightMathNode;
	self->rightMathNode.parentMathSymbol = self;
}

//NOTE: NOT TO BE CONFUSED with -addSymbol, because this is only invoked in case we need to add something in between the parent node( self ) and its child( right child). We get to this case based on precedence level comparison
-(NTIMathSymbol *)addAsChildMathSymbol: (NTIMathSymbol *)newMathSymbol
{
	NTIMathSymbol* temp = self.rightMathNode;
	self.rightMathNode = newMathSymbol;
	
	//Then we take what was on the right node and move it down a level as a child of the new node.
	return [newMathSymbol addSymbol: temp];
}

#pragma mark - NTIMathExpressionSymbolProtocol Methods
-(BOOL)requiresGraphicKeyboard
{
	return [leftMathNode requiresGraphicKeyboard] && [rightMathNode requiresGraphicKeyboard];
}

-(NTIMathSymbol *)addSymbol:(NTIMathSymbol *)newSymbol
{
	//Stack it on the left
	if ([self.leftMathNode isKindOfClass: [NTIMathPlaceholderSymbol class]] && [self.rightMathNode isKindOfClass: [NTIMathPlaceholderSymbol class]] )	{
		self.leftMathNode = newSymbol;
		self.leftMathNode.parentMathSymbol = self;
		return rightMathNode;
	}
	else if (![self.leftMathNode isKindOfClass: [NTIMathPlaceholderSymbol class]] && [self.rightMathNode isKindOfClass: [NTIMathPlaceholderSymbol class]] ) {
		//Left full, right is placeholder
		self.rightMathNode = newSymbol;
		self.rightMathNode.parentMathSymbol = self;
		return rightMathNode;
	}
	
	return nil;
}

-(void)removeMathNode: (NTIMathSymbol *)newMathNode
{
	//Replace child node with a placeholder
	if (self.leftMathNode == newMathNode) {
		self.leftMathNode = [[NTIMathPlaceholderSymbol alloc] init];
	}
	if (self.rightMathNode == newMathNode) {
		self.rightMathNode = [[NTIMathPlaceholderSymbol alloc] init];
	}
}

-(NTIMathSymbol *)deleteSymbol:(NTIMathSymbol *)mathSymbol
{
	//if we only have placeholder
	if ( [self.leftMathNode isKindOfClass: [NTIMathPlaceholderSymbol class]] && [self.rightMathNode isKindOfClass: [NTIMathPlaceholderSymbol class]] ) {
		return nil;
	}
	
	//Delete something on the left math symbol
	NTIMathSymbol* tempSmyol = [self.leftMathNode deleteSymbol: mathSymbol];
	if (tempSmyol) {
		return tempSmyol;
	}
	
	tempSmyol = [self.rightMathNode deleteSymbol: mathSymbol];
	if (tempSmyol) {
		return tempSmyol;
	}
	//Unhandled issue: should we immediately add placeholders for empty left or right symbol?
	
	return nil;
}

-(NSString *)toString
{
	NSString* leftNodeString = [self.leftMathNode toString];
	NSString* rightNodeString = [self.rightMathNode toString];
	if (self.leftMathNode.precedenceLevel < self.precedenceLevel && (self.leftMathNode.precedenceLevel > 0)) {
		leftNodeString = [NSString stringWithFormat: @"(%@)", leftNodeString]; 
	}
	if (self.rightMathNode.precedenceLevel < self.precedenceLevel && (self.rightMathNode.precedenceLevel > 0)) {
		rightNodeString = [NSString stringWithFormat:@"(%@)", rightNodeString];
	}
	
	
	return [NSString stringWithFormat: @"%@%@%@", leftNodeString, [self.operatorMathNode toString], rightNodeString];
}

-(NSString *)latexValue 
{
	NSString* leftNodeString = [self.leftMathNode latexValue];
	NSString* rightNodeString = [self.rightMathNode latexValue];
	NSString* operatorString = [self.operatorMathNode latexValue];
	
	//we don't want paranthesis around literals and placeholders( their precedence level is 0)
	if (self.leftMathNode.precedenceLevel < self.precedenceLevel && (self.leftMathNode.precedenceLevel > 0)) {
		leftNodeString = [NSString stringWithFormat: @"(%@)", leftNodeString]; 
	}
	if (self.rightMathNode.precedenceLevel < self.precedenceLevel && (self.rightMathNode.precedenceLevel > 0)) {
		rightNodeString = [NSString stringWithFormat:@"(%@)", rightNodeString];
	}
	
	if ([operatorString isEqualToString:@"/"] || [operatorString isEqualToString:@"÷"]) {
		return [NSString stringWithFormat:@"\\frac{%@}{%@}", leftNodeString, rightNodeString];
	}
	
	return [NSString stringWithFormat: @"%@%@%@", operatorString,leftNodeString, rightNodeString];
}
@end
