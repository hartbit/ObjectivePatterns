//
//  OPTVisitorTests.m
//  ObjectivePatterns
//
//  Created by David Hart on 22/03/14.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import <ObjectivePatterns/OPTVisitor.h>


@interface OPTTestVisitor : OPTVisitor

- (void)visitNSValue:(NSValue*)value;
- (void)visitNSDecimalNumber:(NSDecimalNumber*)decimalNumber;

@end


@interface OPTVisitorTests : XCTestCase

@end


@implementation OPTVisitorTests

#pragma mark - visit Method

- (void)test_visit_withClassWithNoVisitMethods_doesNothing
{
	OPTTestVisitor* visitor = [OPTTestVisitor new];
	id mockVisitor = [OCMockObject partialMockForObject:visitor];
	
	[[mockVisitor reject] visitNSValue:OCMOCK_ANY];
	[[mockVisitor reject] visitNSDecimalNumber:OCMOCK_ANY];
	
	[visitor visit:[NSString string]];
	
	[mockVisitor verify];
}

- (void)test_visit_withClassWithExactVisitMethod_callsMethod
{
	OPTTestVisitor* visitor = [OPTTestVisitor new];
	id mockVisitor = [OCMockObject partialMockForObject:visitor];
	id decimalNumber = [NSDecimalNumber decimalNumberWithString:@"1.4"];
	
	[[mockVisitor reject] visitNSValue:OCMOCK_ANY];
	[[mockVisitor expect] visitNSDecimalNumber:decimalNumber];
	
	[visitor visit:decimalNumber];
	
	[mockVisitor verify];
}

- (void)test_visit_withClassWithAncestorVisitMethod_callsMethod
{
	OPTTestVisitor* visitor = [OPTTestVisitor new];
	id mockVisitor = [OCMockObject partialMockForObject:visitor];
	id number = [NSNumber numberWithBool:YES];
	
	[[mockVisitor expect] visitNSValue:number];
	[[mockVisitor reject] visitNSDecimalNumber:OCMOCK_ANY];
	
	[visitor visit:number];
	
	[mockVisitor verify];
}

@end


@implementation OPTTestVisitor

- (void)visitNSValue:(NSValue*)value {}
- (void)visitNSDecimalNumber:(NSDecimalNumber*)decimalNumber {}

@end