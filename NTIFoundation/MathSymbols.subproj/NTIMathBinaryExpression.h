//
//  NTIMathBinaryExpression.h
//  NTIFoundation
//
//  Created by Pacifique Mahoro on 4/11/12.
//  Copyright (c) 2012 NextThought. All rights reserved.
//

#import "NTIMathSymbol.h"
@class NTIMathOperatorSymbol;
@interface NTIMathBinaryExpression : NTIMathSymbol {
	NSUInteger precedenceLevel;
}

@property( nonatomic, strong, readonly) NTIMathOperatorSymbol* operatorMathNode;	//Parent node
@property( nonatomic, strong) NTIMathSymbol* leftMathNode;
@property( nonatomic, strong) NTIMathSymbol* rightMathNode;
@property( nonatomic ) BOOL isOperatorImplicit;

-(id)initWithMathOperatorSymbol: (NSString *)operatorString;
-(NTIMathSymbol *)swapNode: (NTIMathSymbol *)childNode 
			   withNewNode: (NTIMathSymbol *)newNode;
-(BOOL)isBinaryOperator;
//Helpers
-(NSString *)latexValueForChildNode: (NTIMathSymbol *)childExpression;
-(NSString *)toStringValueForChildNode: (NTIMathSymbol *)childExpression;
+(NTIMathBinaryExpression *)binaryExpressionForString:(NSString *)symbolString;
-(NTIMathSymbol *)findLastLeafNodeFrom: (NTIMathSymbol *)mathSymbol;
@end

@interface NTIMathAdditionBinaryExpression : NTIMathBinaryExpression
@end

@interface NTIMathSubtractionBinaryExpression : NTIMathBinaryExpression
@end

@interface NTIMathMultiplicationBinaryExpression : NTIMathBinaryExpression
@end

@interface NTIMathDivisionBinaryExpression : NTIMathBinaryExpression
@end