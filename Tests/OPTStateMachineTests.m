//
//  OPTStateMachineTests.m
//  ObjectivePatterns
//
//  Created by David Hart on 16/03/14.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import "OPTStateMachine.h"


@interface OPTStateMachineTests : XCTestCase

@end


@implementation OPTStateMachineTests

#pragma mark - initWithStartState Method

- (void)test_initWithStartState_nilOrEmptyState_throws
{
	XCTAssertThrowsSpecificNamed([[OPTStateMachine alloc] initWithStartState:nil], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([[OPTStateMachine alloc] initWithStartState:@""], NSException, NSInvalidArgumentException);
}

- (void)test_initWithStartState_setsDefaultValues
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];
	
	XCTAssertEqualObjects(machine.currentState, @"start");
	XCTAssertNil(machine.delegate);
}

#pragma mark - delegate Property

- (void)test_delegate_setterSetsDelegate
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];
	id<OPTStateMachineDelegate> mockDelegate = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	
	XCTAssertEqual(machine.delegate, mockDelegate);
}

#pragma mark - canTransitionToState: Method

- (void)test_canTransitionToState_nilOrEmptyState_throws
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];
	
	XCTAssertThrowsSpecificNamed([machine canTransitionToState:nil], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([machine canTransitionToState:@""], NSException, NSInvalidArgumentException);
}

- (void)test_canTransitionToState_withoutDelegate_returnsTrue
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];

	XCTAssertTrue([machine canTransitionToState:@"next"]);
}

- (void)test_canTransitionToState_withDelegate_callsDelegateShouldTransitionFromStateToState
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];
	
	id mockDelegate1 = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate1;
	[[[mockDelegate1 expect] andReturnValue:OCMOCK_VALUE(YES)] stateMachine:machine shouldTransitionFromState:@"start" toState:@"next"];
	
	XCTAssertTrue([machine canTransitionToState:@"next"]);
	
	[mockDelegate1 verify];
	
	id mockDelegate2 = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate2;
	[[[mockDelegate2 expect] andReturnValue:OCMOCK_VALUE(NO)] stateMachine:machine shouldTransitionFromState:@"start" toState:@"next"];
	
	XCTAssertFalse([machine canTransitionToState:@"next"]);
	
	[mockDelegate2 verify];
}

#pragma mark - transitionToState: Method

- (void)test_transitionToState_nilOrEmptyState_throws
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];
	
	XCTAssertThrowsSpecificNamed([machine transitionToState:nil], NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed([machine transitionToState:@""], NSException, NSInvalidArgumentException);
}

- (void)test_transitionToState_changesCurrentState
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];
	
	[machine transitionToState:@"next"];
	
	XCTAssertEqualObjects(machine.currentState, @"next");
}

- (void)test_transitionToState_whenDelegateDoesNotAllowTransition_throws
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];
	id mockDelegate = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	[[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(NO)] stateMachine:machine shouldTransitionFromState:@"start" toState:@"next"];
	
	XCTAssertThrowsSpecificNamed([machine transitionToState:@"next"], NSException, NSInternalInconsistencyException);
}

- (void)test_transitionToState_callsDelegateWillTransitionToStateAndDidTransitionFromState
{
	OPTStateMachine* machine = [[OPTStateMachine alloc] initWithStartState:@"start"];
	id mockDelegate = [OCMockObject mockForProtocol:@protocol(OPTStateMachineDelegate)];
	machine.delegate = mockDelegate;
	[[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(YES)] stateMachine:machine shouldTransitionFromState:@"start" toState:@"next"];
	
	[mockDelegate setExpectationOrderMatters:YES];
	[[[mockDelegate expect] andDo:^(NSInvocation* invocation) {
		XCTAssertEqualObjects(machine.currentState, @"start");
	}] stateMachine:machine willTransitionToState:@"next"];
	[[[mockDelegate expect] andDo:^(NSInvocation* invocation) {
		XCTAssertEqualObjects(machine.currentState, @"next");
	}] stateMachine:machine didTransitionFromState:@"start"];
	
	[machine transitionToState:@"next"];
	
	[mockDelegate verify];
}

@end
