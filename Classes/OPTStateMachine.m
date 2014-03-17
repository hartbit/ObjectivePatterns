//
//  OPTStateMachine.m
//  ObjectivePatterns
//
//  Created by David Hart on 16/03/14.
//

#import "OPTStateMachine.h"


@interface OPTStateMachine ()

@property (nonatomic) NSString* currentState;

@end


@implementation OPTStateMachine

#pragma mark - Initialization

- (id)initWithStartState:(NSString*)state
{
	if ([state length] == 0) {
		[NSException raise:NSInvalidArgumentException format:@"Invalid state"];
	}
	
	if (self = [super init]) {
		self.currentState = state;
	}
	
	return self;
}

#pragma mark - Public Methods

- (BOOL)canTransitionToState:(NSString*)state
{
	if ([state length] == 0) {
		[NSException raise:NSInvalidArgumentException format:@"Invalid state"];
	}
	
	if ([self.delegate respondsToSelector:@selector(stateMachine:shouldTransitionFromState:toState:)]) {
		return [self.delegate stateMachine:self shouldTransitionFromState:self.currentState toState:state];
	} else {
		return YES;
	}
}

- (void)transitionToState:(NSString*)state
{
	if (![self canTransitionToState:state]) {
		[NSException raise:NSInternalInconsistencyException format:@"Can not transition to state '%@'", state];
	}
	
	if ([self.delegate respondsToSelector:@selector(stateMachine:willTransitionToState:)]) {
		[self.delegate stateMachine:self willTransitionToState:state];
	}
	
	NSString* sourceState = self.currentState;
	self.currentState = state;
	
	if ([self.delegate respondsToSelector:@selector(stateMachine:didTransitionFromState:)]) {
		[self.delegate stateMachine:self didTransitionFromState:sourceState];
	}
}

@end
