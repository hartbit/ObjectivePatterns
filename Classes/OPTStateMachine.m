//
//  OPTStateMachine.m
//  ObjectivePatterns
//
//  Created by David Hart on 16/03/14.
//

#import "OPTStateMachine.h"


NSString* OPTErrorDomain = @"OPTErrorDomain";


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

- (BOOL)acceptsInput:(NSString*)input userInfo:(NSDictionary*)userInfo
{
	if (!self.delegate) {
		[NSException raise:NSInternalInconsistencyException format:@"You must provide a valid delegate"];
	}
	
	return [[self.delegate stateMachine:self destinationStateFromState:self.currentState withInput:input userInfo:userInfo] length] > 0;
}

- (void)feedInput:(NSString*)input userInfo:(NSDictionary*)userInfo error:(NSError*__autoreleasing*)error
{
	if (!self.delegate) {
		[NSException raise:NSInternalInconsistencyException format:@"You must provide a valid delegate"];
	}
	
	NSString* destinationState = [self.delegate stateMachine:self destinationStateFromState:self.currentState withInput:input userInfo:userInfo];
	
	if ([destinationState length] == 0) {
		if (error) {
			NSDictionary* userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid destination state: %@", destinationState]};
			*error = [NSError errorWithDomain:OPTErrorDomain code:-1 userInfo:userInfo];
		}
		
		return;
	}
	
	if ([self.delegate respondsToSelector:@selector(stateMachine:willTransitionToState:withInput:userInfo:)]) {
		[self.delegate stateMachine:self willTransitionToState:destinationState withInput:input userInfo:userInfo];
	}
	
	NSString* sourceState = self.currentState;
	self.currentState = destinationState;
	
	if ([self.delegate respondsToSelector:@selector(stateMachine:didTransitionFromState:withInput:userInfo:)]) {
		[self.delegate stateMachine:self didTransitionFromState:sourceState withInput:input userInfo:userInfo];
	}
}

@end
