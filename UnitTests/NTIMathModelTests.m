//
//  NTIToStringTest.m
//  NTIFoundation
//
//  Created by Logan Testi on 5/21/12.
//  Copyright (c) 2012 NextThought. All rights reserved.
//

#import "NTIMathModelTests.h"
#import "NTIMathInputExpressionModel.h"
#import "NTIMathSymbol.h"
#import "NTIMathEquationBuilder.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@interface NTIMathInputExpressionModel(NTIMathInputExpressionTest)
-(NTIMathSymbol *)findRootOfMathNode: (NTIMathSymbol *)mathSymbol;
-(NTIMathSymbol *)removeMathExpression: (NTIMathSymbol *)mathNode;
-(NSString *)tolaTex;
@end

@implementation NTIMathModelTests

-(void)setUp
{
	self->baseModel = [[NTIMathInputExpressionModel alloc] initWithMathSymbol: nil];
	self->mathModel = [[NTIMathInputExpressionModel alloc] initWithMathSymbol: nil];
}

-(void)pushKey: (NSString*) stringValue
{
	if([stringValue isEqualToString: @"->"]){
		[self->mathModel nextKeyPressed];
	}
	
	if([stringValue isEqualToString: @"<-"]){
		[self->mathModel backPressed];
	}
	
	if([stringValue isEqualToString: @"backspace"] || [stringValue isEqualToString: @"bs"]){
		[self->mathModel deleteMathExpression: nil];
	}
	
	if(stringValue.length == 1){
		[self->mathModel addMathSymbolForString: stringValue fromSenderType:kNTIMathGraphicKeyboardInput];
	}
}

// -------------checker methods---------------

#define mathmodel_assertThatOutputIsInput(str) \
	self->mathModel = [NTIMathEquationBuilder modelFromString: str]; \
	assertThat([self->mathModel generateEquationString], is(str));

#define mathModel_assertThatIsValidLatex(userInput, expectedOutPut) \
	self->mathModel = [NTIMathEquationBuilder modelFromString: userInput]; \
	assertThat([self->mathModel tolaTex], is(expectedOutPut));

// -----------data retention test------------

// tests if the model will store data
-(void)testModelDataStorage
{
	NSString* latexToString = @"0";
	self->mathModel = [NTIMathEquationBuilder modelFromString: latexToString];
	assertThat([self->mathModel fullEquation], isNot(nil));
}

// -------------text field tests--------------

// ---------------string tests----------------

// tests if we can get a string from the model from a text field
-(void)testModelBasicToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"55")
}

// tests if the model will return symbols as string correctly from a text field
-(void)testModelSymbolToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"4+5-6*7^8");
}

// tests if the model stores parentheses as string correctly from a text field
-(void)testModelParenthesesToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"(4+5)");
}

// tests if the model will return square roots as string correctly from a text field
-(void)testModelSurdToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"4√3");
}

// tests if the model will return decimals as string correctly from a text field
-(void)testModelDecimalToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"20.5");
}

// tests if the model will return fractions as string correctly from a text field
-(void)testModelFractionToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"3/4");
}

// tests if the model will return negative numbers as string correctly from a text field
-(void)testModelNegativeToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"-1");
}

// tests if the model will return a pi value as a string correctly from a text field
-(void)testModelPiToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"π");
}

// tests if the model will return a Scientific Notation value as a string correctly from a text field
-(void)testModelScientificNotationToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"2.16 × 10^5");
}

// tests if the model will return a graph point value as a string correctly from a text field
-(void)testModelGraphPointToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"(0.5, 0.5)");
}

// tests if the model will return a string value as a string correctly from a text field
-(void)testModelStringToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"triangle");
}

// tests if the model will return a mixed number as a string correctly from a text field
-(void)testMixedNumberToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"1 1/2");
}

// tests if the model will return a colon as a string correctly from a text field
-(void)testColonToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"3:45");
}

// tests if the model will return comma separated values as a string correctly from a text field
-(void)testCommaToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"B2, E5");
}

// tests if the model will return approximations as a string correctly from a text field
-(void)testUnaryApproxToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"≈6.2");
}

// tests if the model will return approximations as a string value as a string correctly from a text field
-(void)testApproxToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"x ≈ 6.2");
}

// tests if the model will return equals as a string correctly from a text field
-(void)testEqualsToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"x = 6.2");
}

// tests if the model will return a garbage values as a string correctly from a text field
-(void)testHandlesJunkValueToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"x--6+/*3#-");
}

// tests if the model will return a division sign as a string correctly from a text field
-(void)testDivisionSignToStringToStringTextField
{
	mathmodel_assertThatOutputIsInput(@"3÷4");
}

// -----------------latex tests-----------------------

// tests if we can get the latex value from the model
-(void)testModelBasicLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"45", @"45");
}

// tests if the model will return symbols with the latex value correctly
-(void)testModelSymbolLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"4+5-6*7^8", @"4+5-6*7^8");
}

// tests if the model stores parentheses with the latex value correctly
-(void)testModelParenthesesLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"(4+5)", @"(4+5)");
}

// tests if the model will return square roots with the latex value correctly
-(void)testModelSurdLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"4√3", @"4\\surd3");
}

// tests if the model will return decimals with the latex value correctly
-(void)testModelDecimalLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"20.5", @"20.5");
}

// tests if the model will return fractions with the latex value correctly
-(void)testModelFractionLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"3/4", @"\\frac{3}{4}");
}

// tests if the model will return negative numbers with the latex value correctly
-(void)testModelNegativeLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"-1", @"-1");
}

// tests if the model will return a pi value with the latex value correctly
-(void)testModelPiLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"π", @"\\pi");
}

// tests if the model will return a Scientific Notation value with the latex value correctly
-(void)testModelScientificNotationLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"2.16 × 10^5", @"2.16 × 10^5"); //not the same value as if typed in
}

// tests if the model will return a graph point value with the latex value correctly
-(void)testModelGraphPointLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"(0.5, 0.5)", @"(0.5, 0.5)");
}

// tests if the model will return a string value with the latex value correctly
-(void)testModelStringLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"triangle", @"triangle");
}

// tests if the model will return a mixed number as a string correctly from a text field
-(void)testMixedNumberLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"1 1/2", @"1\\frac{1}{2}");
}

// tests if the model will return a colon as a string correctly from a text field
-(void)testColonLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"3:45", @"3:45");
}

// tests if the model will return comma separated values as a string correctly from a text field
-(void)testCommaLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"B2, E5", @"B2, E5");
}

// tests if the model will return approximations as a string correctly from a text field
-(void)testUnaryApproxLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"≈ 6.2", @"\\approx 6.2");
}

// tests if the model will return approximations as a string value as a string correctly from a text field
-(void)testApproxLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"x ≈ 6.2", @"x \\approx 6.2");
}

// tests if the model will return equals as a string correctly from a text field
-(void)testEqualsLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"x = 6.2", @"x = 6.2");
}

// tests if the model will return a division sign as a string correctly from a text field
-(void)testDivisionSignLatexValueTextField
{
	mathModel_assertThatIsValidLatex(@"3÷4", @"3÷4");
}

// ------graphical keyboard tests -------

// -----------to string tests------------

// tests if we can get a string from the model from a text field
-(void)testModelBasicToStringGraphicalKeyboard
{
	[self pushKey: @"5"];
	assertThat([self->mathModel generateEquationString], is(@"5"));
}

// tests if the model will return symbols as string correctly from a text field
-(void)testModelSymbolToStringGraphicalKeyboard
{
	[self pushKey: @"4"];
	[self pushKey: @"+"];
	[self pushKey: @"5"];
	[self pushKey: @"-"];
	[self pushKey: @"6"];
	[self pushKey: @"*"];
	[self pushKey: @"7"];
	[self pushKey: @"^"];
	[self pushKey: @"8"];
	assertThat([self->mathModel generateEquationString], is(@"4+5-6*7^8"));
}

// tests if the model stores parentheses as string correctly from a text field
-(void)testModelParenthesesToStringGraphicalKeyboard
{
	[self pushKey: @"("];
	[self pushKey: @"4"];
	assertThat([self->mathModel generateEquationString], is(@"(4)"));
}

// tests if the model stores parentheses as string correctly from a text field
-(void)testModelParenthesesWithBinaryOpporatorToStringGraphicalKeyboard
{
	[self pushKey: @"("];
	[self pushKey: @"4"];
	[self pushKey: @"+"];
	[self pushKey: @"5"];
	assertThat([self->mathModel generateEquationString], is(@"(4+5)"));
}

// tests if the model will return square roots as string correctly from a text field
-(void)testModelSurdToStringGraphicalKeyboard
{
	[self pushKey: @"4"];
	[self pushKey: @"√"];
	[self pushKey: @"3"];
	assertThat([self->mathModel generateEquationString], is(@"4√3"));
}

// tests if the model will return decimals as string correctly from a text field
-(void)testModelDecimalToStringGraphicalKeyboardd
{
	[self pushKey: @"2"];
	[self pushKey: @"0"];
	[self pushKey: @"."];
	[self pushKey: @"5"];
	assertThat([self->mathModel generateEquationString], is(@"20.5"));
}

// tests if the model will return fractions as string correctly from a text field
-(void)testModelFractionToStringGraphicalKeyboard
{
	[self pushKey: @"/"];
	[self pushKey: @"3"];
	assertThat([self->mathModel generateEquationString], is(@"3/"));
}

// tests if the model will return negative numbers as string correctly from a text field
//-(void)testModelNegativeToStringGraphicalKeyboard
//{
//	[self pushKey: @"1"];
//	[self pushKey: @"+/-"];
//	assertThat([self->mathModel generateEquationString], is(@"-1"));
//}

// tests if the model will return a pi value as a string correctly from a text field
-(void)testModelPiToStringGraphicalKeyboard
{
	[self pushKey: @"π"];
	assertThat([self->mathModel generateEquationString], is(@"π"));
}

// tests if the model will return a Scientific Notation value as a string correctly from a text field
-(void)testModelScientificNotationToStringGraphicalKeyboard
{
	[self pushKey: @"2"];
	[self pushKey: @"."];
	[self pushKey: @"1"];
	[self pushKey: @"6"];
	[self pushKey: @"*"];
	[self pushKey: @"1"];
	[self pushKey: @"0"];
	[self pushKey: @"^"];
	[self pushKey: @"5"];
	assertThat([self->mathModel generateEquationString], is(@"2.16*10^5"));
}

// tests if the model will return a graph point value as a string correctly from a text field
-(void)testModelGraphPointToStringGraphicalKeyboard
{
	[self pushKey: @"("];
	[self pushKey: @"0"];
	[self pushKey: @"."];
	[self pushKey: @"5"];
	[self pushKey: @","];
	[self pushKey: @"0"];
	[self pushKey: @"."];
	[self pushKey: @"5"];
	assertThat([self->mathModel generateEquationString], is(@"(0.5, 0.5)"));
}

// tests if the model will return a mixed number as a string correctly from a text field
-(void)testMixedNumberToStringGraphicalKeyboard
{
	[self pushKey: @"2"];
	[self pushKey: @"/"];
	[self pushKey: @"3"];
	assertThat([self->mathModel generateEquationString], is(@"2 3/"));
}

// tests if the model will return a colon as a string correctly from a text field
-(void)testColonToStringGraphicalKeyboard
{
	[self pushKey: @"3"];
	[self pushKey: @":"];
	[self pushKey: @"4"];
	[self pushKey: @"5"];
	assertThat([self->mathModel generateEquationString], is(@"3:45"));
}

// tests if the model will return comma separated values as a string correctly from a text field
-(void)testCommaToStringGraphicalKeyboard
{
	[self pushKey: @"b"];
	[self pushKey: @"2"];
	[self pushKey: @","];
	[self pushKey: @"c"];
	[self pushKey: @"5"];
	assertThat([self->mathModel generateEquationString], is(@"b2,c5"));
}

// tests if the model will return approximations as a string correctly from a text field
-(void)testUnaryApproxToStringGraphicalKeyboard
{
	[self pushKey: @"≈"];
	[self pushKey: @"6"];
	[self pushKey: @"."];
	[self pushKey: @"2"];
	assertThat([self->mathModel generateEquationString], is(@"≈6.2"));
}

// tests if the model will return approximations as a string value as a string correctly from a text field
-(void)testApproxToStringGraphicalKeyboard
{
	[self pushKey: @"a"];
	[self pushKey: @"≈"];
	[self pushKey: @"6"];
	[self pushKey: @"."];
	[self pushKey: @"2"];
	assertThat([self->mathModel generateEquationString], is(@"a ≈ 6.2"));
}

// tests if the model will return equals as a string correctly from a text field
-(void)testEqualsToStringGraphicalKeyboard
{
	[self pushKey: @"a"];
	[self pushKey: @"="];
	[self pushKey: @"6"];
	[self pushKey: @"."];
	[self pushKey: @"2"];
	assertThat([self->mathModel generateEquationString], is(@"a = 6.2"));
}

// tests if the model will return a garbage values as a string correctly from a text field
-(void)testHandlesJunkValueToStringGraphicalKeyboard
{
	[self pushKey: @"x"];
	[self pushKey: @"-"];
	[self pushKey: @"-"];
	[self pushKey: @"6"];
	[self pushKey: @"+"];
	[self pushKey: @"/"];
	[self pushKey: @"*"];
	[self pushKey: @"3"];
	[self pushKey: @"-"];
	assertThat([self->mathModel generateEquationString], is(@"x--6+/*3-"));
}

// tests if the model will return a division sign as a string correctly from a text field
-(void)testDivisionSignToStringToStringGraphicalKeyboard
{
	[self pushKey: @"3"];
	[self pushKey: @"÷"];
	[self pushKey: @"4"];
	assertThat([self->mathModel generateEquationString], is(@"3/4"));
}

// -------------to latex tests----------------

// tests if we can get latex from the model from a text field
-(void)testModelBasicToLatexGraphicalKeyboard
{
	[self pushKey: @"5"];
	assertThat([self->mathModel tolaTex], is(@"5"));
}

// tests if the model will return symbols as latex correctly from a text field
-(void)testModelSymbolToLatexGraphicalKeyboard
{
	[self pushKey: @"4"];
	[self pushKey: @"+"];
	[self pushKey: @"5"];
	[self pushKey: @"-"];
	[self pushKey: @"6"];
	[self pushKey: @"*"];
	[self pushKey: @"7"];
	[self pushKey: @"^"];
	[self pushKey: @"8"];
	assertThat([self->mathModel tolaTex], is(@"4+5-6*7^8"));
}

// tests if the model stores parentheses as latex correctly from a text field
-(void)testModelParenthesesToLatexGraphicalKeyboard
{
	[self pushKey: @"("];
	[self pushKey: @"4"];
	assertThat([self->mathModel tolaTex], is(@"(4)"));
}

// tests if the model stores parentheses as latex correctly from a text field
-(void)testModelParenthesesWithBinaryOpporatorToLatexGraphicalKeyboard
{
	[self pushKey: @"("];
	[self pushKey: @"4"];
	[self pushKey: @"+"];
	[self pushKey: @"5"];
	assertThat([self->mathModel tolaTex], is(@"(4+5)"));
}

// tests if the model will return square roots as latex correctly from a text field
-(void)testModelSurdToLatexGraphicalKeyboard
{
	[self pushKey: @"4"];
	[self pushKey: @"√"];
	[self pushKey: @"3"];
	assertThat([self->mathModel tolaTex], is(@"4\\surd3"));
}

// tests if the model will return decimals as latex correctly from a text field
-(void)testModelDecimalToLatexGraphicalKeyboardd
{
	[self pushKey: @"2"];
	[self pushKey: @"0"];
	[self pushKey: @"."];
	[self pushKey: @"5"];
	assertThat([self->mathModel tolaTex], is(@"20.5"));
}

// tests if the model will return fractions as latex correctly from a text field
-(void)testModelFractionToLatexGraphicalKeyboard
{
	[self pushKey: @"/"];
	[self pushKey: @"3"];
	assertThat([self->mathModel tolaTex], is(@"\\frac{3}{}"));
}

// tests if the model will return negative numbers as latex correctly from a text field
//-(void)testModelNegativeToStringGraphicalKeyboard
//{
//	[self pushKey: @"1"];
//	[self pushKey: @"+/-"];
//	assertThat([self->mathModel generateEquationString], is(@"-1"));
//}

// tests if the model will return a pi value as latex correctly from a text field
-(void)testModelPiToLatexGraphicalKeyboard
{
	[self pushKey: @"π"];
	assertThat([self->mathModel tolaTex], is(@"\\pi"));
}

// tests if the model will return a Scientific Notation value as latex correctly from a text field
-(void)testModelScientificNotationToLatexGraphicalKeyboard
{
	[self pushKey: @"2"];
	[self pushKey: @"."];
	[self pushKey: @"1"];
	[self pushKey: @"6"];
	[self pushKey: @"*"];
	[self pushKey: @"1"];
	[self pushKey: @"0"];
	[self pushKey: @"^"];
	[self pushKey: @"5"];
	assertThat([self->mathModel tolaTex], is(@"2.16*10^5"));
}

// tests if the model will return a graph point value as latex correctly from a text field
-(void)testModelGraphPointToLatexGraphicalKeyboard
{
	[self pushKey: @"("];
	[self pushKey: @"0"];
	[self pushKey: @"."];
	[self pushKey: @"5"];
	[self pushKey: @","];
	[self pushKey: @"0"];
	[self pushKey: @"."];
	[self pushKey: @"5"];
	assertThat([self->mathModel tolaTex], is(@"(0.5, 0.5)"));
}

// tests if the model will return a mixed number as latex correctly from a text field
-(void)testMixedNumberToLatexGraphicalKeyboard
{
	[self pushKey: @"2"];
	[self pushKey: @"/"];
	[self pushKey: @"3"];
	assertThat([self->mathModel tolaTex], is(@"2\\frac{3}{}"));
}

// tests if the model will return a colon as latex correctly from a text field
-(void)testColonToLatexGraphicalKeyboard
{
	[self pushKey: @"3"];
	[self pushKey: @":"];
	[self pushKey: @"4"];
	[self pushKey: @"5"];
	assertThat([self->mathModel tolaTex], is(@"3:45"));
}

// tests if the model will return comma separated values as latex correctly from a text field
-(void)testCommaToLatexGraphicalKeyboard
{
	[self pushKey: @"b"];
	[self pushKey: @"2"];
	[self pushKey: @","];
	[self pushKey: @"c"];
	[self pushKey: @"5"];
	assertThat([self->mathModel tolaTex], is(@"b2,c5"));
}

// tests if the model will return approximations as latex correctly from a text field
-(void)testUnaryApproxToLatexGraphicalKeyboard
{
	[self pushKey: @"≈"];
	[self pushKey: @"6"];
	[self pushKey: @"."];
	[self pushKey: @"2"];
	assertThat([self->mathModel tolaTex], is(@"≈6.2"));
}

// tests if the model will return approximations as latex value as a string correctly from a text field
-(void)testApproxToLatexGraphicalKeyboard
{
	[self pushKey: @"a"];
	[self pushKey: @"≈"];
	[self pushKey: @"6"];
	[self pushKey: @"."];
	[self pushKey: @"2"];
	assertThat([self->mathModel tolaTex], is(@"a ≈ 6.2"));
}

// tests if the model will return equals as latex correctly from a text field
-(void)testEqualsToLatexGraphicalKeyboard
{
	[self pushKey: @"a"];
	[self pushKey: @"="];
	[self pushKey: @"6"];
	[self pushKey: @"."];
	[self pushKey: @"2"];
	assertThat([self->mathModel tolaTex], is(@"a = 6.2"));
}

// tests if the model will return a garbage values as latex correctly from a text field
-(void)testHandlesJunkValueToLatexGraphicalKeyboard
{
	[self pushKey: @"x"];
	[self pushKey: @"-"];
	[self pushKey: @"-"];
	[self pushKey: @"6"];
	[self pushKey: @"+"];
	[self pushKey: @"/"];
	[self pushKey: @"*"];
	[self pushKey: @"3"];
	[self pushKey: @"-"];
	assertThat([self->mathModel tolaTex], is(@"x--6+\\frac*3-"));
}

// tests if the model will return a division sign as latex correctly from a text field
-(void)testDivisionSignToLatexToStringGraphicalKeyboard
{
	[self pushKey: @"3"];
	[self pushKey: @"÷"];
	[self pushKey: @"4"];
	assertThat([self->mathModel tolaTex], is(@"\\frac{3}{4}"));
}

// -------------find root tests--------------------

// tests finding the root of a nil expression
-(void)testFindRootOfMathNodeNil
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: nil];
	NTIMathSymbol* parent = [self->mathModel rootMathSymbol];
	assertThat([self->mathModel findRootOfMathNode: parent], is(parent));
}

// test finding the root of the root expression
-(void)testFindRootOfMathNodeRoot
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"4+5"];
	NTIMathSymbol* parent = [self->mathModel rootMathSymbol];
	assertThat([self->mathModel findRootOfMathNode: parent], is(parent));
}

// test finding the root of the child expression
-(void)testFindFootOfMathNodeChild
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"4+5*6"];
	NTIMathSymbol* parent = [self->mathModel rootMathSymbol];
	for(NTIMathSymbol* child in parent.children){
		assertThat([self->mathModel findRootOfMathNode: child], is(parent));
	}
}

-(void)testFindFootOfMathNodeGrandchildPlus
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"4+5*6^7"];
	NTIMathSymbol* parent = [self->mathModel rootMathSymbol];
	for(NTIMathSymbol* child in parent.children){
		if(child.children != nil){
			for(NTIMathSymbol* grandChild in child.children){
				assertThat([self->mathModel findRootOfMathNode: grandChild], is(parent));
			}
		}
	}
}

// --------------navigation tests-----------------

-(void)testCurrentMathSymbolNil
{
	assertThat([[self->mathModel currentMathSymbol] toString], is(@""));
}

-(void)testCurrentMathSymbolBasic
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"4+5"];
	assertThat([[self->mathModel currentMathSymbol] toString], is(@"5"));
}

-(void)testCurrentMathSymbolNilDiv
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"*"];
	NTIMathSymbol* parent = [self->mathModel rootMathSymbol];
	NTIMathSymbol* leftChild = [parent.children objectAtIndex:0];
	NTIMathSymbol* rightChild = [parent.children objectAtIndex:1];
	assertThat([self->mathModel currentMathSymbol], is(equalTo(leftChild)));
	[self->mathModel setCurrentSymbolTo: rightChild];
	assertThat([self->mathModel currentMathSymbol], is(equalTo(rightChild)));
	[self->mathModel addMathSymbolForString: @"7" fromSenderType: kNTIMathTextfieldInput];
	assertThat([self->mathModel generateEquationString], is(@"*7"));
}

-(void)testSetMathSymbolNil
{
	self->baseModel = [NTIMathEquationBuilder modelFromString: nil];
	[self->mathModel setCurrentSymbolTo: [self->baseModel rootMathSymbol]];
	assertThat([[self->mathModel currentMathSymbol] toString], is(@""));
}

//-(void)testSetMathSymbolBasic
//{
//	[self buildEquationFromString: @"4": self->baseModel];
//	NTIMathSymbol* changeSymbol = [self->mathModel rootMathSymbol];
//	[self buildEquationFromString: @"4+5": self->mathModel];
//	[self->mathModel setCurrentSymbolTo: changeSymbol];
//	assertThat([[self->mathModel currentMathSymbol] toString], is(@"4"));
//}
//
//-(void)testSetMathSymbolOutside
//{
//	[self buildEquationFromString: @"4": self->baseModel];
//	[self buildEquationFromString: @"4+5": self->mathModel];
//	[self->mathModel setCurrentSymbolTo: [self->baseModel rootMathSymbol]];
//	assertThat([[self->mathModel currentMathSymbol] toString], isNot(@"4"));
//}
//
//-(void)testRemoveMathExpressionNil
//{
//	[self buildEquationFromString: @"" : self->baseModel];
//	[self->mathModel removeMathExpression: [self->baseModel rootMathSymbol]];
//	assertThat([[self->mathModel fullEquation] toString], is(@""));
//}
//
//-(void)testRemoveMathExpressionBasic
//{
//	[self buildEquationFromString: @"4" : self->baseModel];
//	NTIMathSymbol* changeSymbol = [self->mathModel rootMathSymbol];
//	[self buildEquationFromString: @"+5" : self->mathModel];
//	[self->mathModel removeMathExpression: changeSymbol];
//	assertThat([self->mathModel generateEquationString], is(@"+5"));
//}
//
-(void)testDeleteMathExpressionNil
{
	[self->mathModel deleteMathExpression: nil];
	assertThat([[self->mathModel rootMathSymbol] toString], is(@""));
}

-(void)testDeleteMathExpressionBasic
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"4+5"];
	[self->mathModel deleteMathExpression: nil];
	assertThat([[self->mathModel rootMathSymbol] toString], is(@"4+"));
}

-(void)testRemoveMathSymbolOutside
{
	self->baseModel = [NTIMathEquationBuilder modelFromString: @"4"];
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"4+5"];
	[self->mathModel removeMathExpression: [self->baseModel rootMathSymbol]];
	assertThat([[self->mathModel currentMathSymbol] toString], isNot(@"4"));
}

// double arrow bug- needs to be fixed
-(void)testNextKeyPressed
{
	[self pushKey: @"2"];
	[self pushKey: @"/"];
	[self pushKey: @"3"];
	[self pushKey: @"->"];
	[self pushKey: @"->"];
	assertThat([[self->mathModel currentMathSymbol] toString], is(@""));
}

// double arrow bug- needs to be fixed
-(void)testBackKeyPressed
{
	[self pushKey: @"2"];
	[self pushKey: @"/"];
	[self pushKey: @"3"];
	[self pushKey: @"<-"];
	[self pushKey: @"<-"];
	assertThat([[self->mathModel currentMathSymbol] toString], is(@"2"));
}

// ---------------find leaf node tests-----------------

-(void)testfindFirstLeafNodFromNil
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @""];
	NTIMathSymbol* eq = [self->mathModel fullEquation];
	assertThat([[self->mathModel findFirstLeafNodeFrom: eq] toString], is(@""));
}

-(void)testfindFirstLeafNodFromBasic
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"4^5*6+7"];
	NTIMathSymbol* eq = [self->mathModel fullEquation];
	assertThat([[self->mathModel findFirstLeafNodeFrom: eq] toString], is(@"4"));
}

-(void)testfindLastLeafNodFromNil
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @""];
	NTIMathSymbol* eq = [self->mathModel fullEquation];
	assertThat([[self->mathModel findLastLeafNodeFrom: eq] toString], is(@""));
}

-(void)testfindLastLeafNodFromBasic
{
	self->mathModel = [NTIMathEquationBuilder modelFromString: @"4^5*6+7"];
	NTIMathSymbol* eq = [self->mathModel fullEquation];
	assertThat([[self->mathModel findLastLeafNodeFrom: eq] toString], is(@"7"));
}

@end
