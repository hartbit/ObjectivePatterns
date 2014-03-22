//
//  OPTStateMachineTests.m
//  ObjectivePatterns
//
//  Created by David Hart on 16/03/14.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import "OPTStateMachine.h"


static NSString* const kStartState = @"Start";
static NSString* const kDestinationState = @"Destination";


@interface OPTStateMachineTests : XCTestCase

@end


@implementation OPTStateMachineTests

#pragma mark - initWithStartState Method

- (void)test_initWithStartStateDelegate_nilOrEmptyState_throws
{
	XCTAssertThrowsSpecificNamed([[OPTStateMachine alloc] initWithStartState:nil], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([[OPTStateMachine alloc] initWithStartState:@""], NSException, NSInvalidArgumentException);
}

- (void)test_initWithStartStateDelegate_setsDefaultValues
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	
	XCTAssertEqualObjects(machine.currentState, kStartState);
}

#pragma mark - delegate Property

- (void)test_setDelegate_setsDelegate
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	id<OPTStateMachineDelegate> mockDelegate = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	
	XCTAssertEqual(machine.delegate, mockDelegate);
}

#pragma mark - acceptsInput:userInfo: Method

- (void)test_acceptsInput_withoutDelegate_throws
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	
	XCTAssertThrowsSpecificNamed([machine acceptsInput:@"input" userInfo:nil], NSException, NSInternalInconsistencyException);
}

- (void)test_acceptsInput_callsDelegateDestinationStateFromStateWithInput_delegateReturnsValidString_returnsYES
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	id mockDelegate = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	
	NSDictionary* userInfo = @{@"OPTKey": @"value"};
	[[[mockDelegate expect] andReturn:@"Destination"] stateMachine:machine destinationStateFromState:kStartState withInput:@"input" userInfo:userInfo];
	
	XCTAssertTrue([machine acceptsInput:@"input" userInfo:userInfo]);
	
	[mockDelegate verify];
}

- (void)test_acceptsInput_callsDelegateDestinationStateFromStateWithInput_delegateReturnsNil_returnsNO
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	id mockDelegate = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	
	NSDictionary* userInfo = @{@"OPTKey": @"value"};
	[[[mockDelegate expect] andReturn:nil] stateMachine:machine destinationStateFromState:kStartState withInput:@"input2" userInfo:userInfo];
	
	XCTAssertFalse([machine acceptsInput:@"input2" userInfo:userInfo]);
	
	[mockDelegate verify];
}

- (void)test_acceptsInput_callsDelegateDestinationStateFromStateWithInput_delegateReturnsEmptyString_returnsNO
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	id mockDelegate = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	
	NSDictionary* userInfo = @{@"OPTKey": @"value"};
	[[[mockDelegate expect] andReturn:@""] stateMachine:machine destinationStateFromState:kStartState withInput:@"input3" userInfo:userInfo];
	
	XCTAssertFalse([machine acceptsInput:@"input3" userInfo:userInfo]);
	
	[mockDelegate verify];
}

#pragma mark - feedInput:userInfo:error: Method

- (void)test_feedInput_withoutDelegate_throws
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	
	XCTAssertThrowsSpecificNamed([machine feedInput:@"input" userInfo:nil error:NULL], NSException, NSInternalInconsistencyException);
}

- (void)test_feedInput_callsDelegateDestinationStateFromStateWithInput_delegateReturnsInvalidString_doesNotChangeState_returnError
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	
	NSDictionary* userInfo = @{@"OPTKey": @"value"};
	[[[mockDelegate expect] andReturn:nil] stateMachine:machine destinationStateFromState:kStartState withInput:@"input" userInfo:userInfo];
	
	NSError* error = nil;
	[machine feedInput:@"input" userInfo:userInfo error:&error];

	[mockDelegate verify];
	XCTAssertEqualObjects(machine.currentState, kStartState);
	XCTAssertNotNil(error);
}

- (void)test_feedInput_callsDelegateDestinationStateFromStateWithInput_delegateReturnsValidString_changesState_callsDelegateMethods_withoutError
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:kStartState];
	id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	
	NSDictionary* userInfo = @{@"OPTKey": @"value"};
	[mockDelegate setExpectationOrderMatters:YES];
	[[[mockDelegate expect] andReturn:kDestinationState] stateMachine:machine destinationStateFromState:kStartState withInput:@"input2" userInfo:userInfo];
	[[[mockDelegate expect] andDo:^(NSInvocation* invocation) {
		XCTAssertEqualObjects(machine.currentState, kStartState);
	}] stateMachine:machine willTransitionToState:kDestinationState withInput:@"input2" userInfo:userInfo];
	[[[mockDelegate expect] andDo:^(NSInvocation* invocation) {
		XCTAssertEqualObjects(machine.currentState, kDestinationState);
	}] stateMachine:machine didTransitionFromState:kStartState withInput:@"input2" userInfo:userInfo];
	
	NSError* error = nil;
	[machine feedInput:@"input2" userInfo:userInfo error:&error];
	
	[mockDelegate verify];
	XCTAssertEqualObjects(machine.currentState, kDestinationState);
	XCTAssertNil(error);
}

@end
