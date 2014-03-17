//
//  OPTStateMachine.h
//  ObjectivePatterns
//
//  Created by David Hart on 16/03/14.
//

@import Foundation;


@protocol OPTStateMachineDelegate;

@interface OPTStateMachine : NSObject

@property (nonatomic, copy, readonly) NSString* currentState;
@property (nonatomic, weak) id<OPTStateMachineDelegate> delegate;

- (id)initWithStartState:(NSString*)state;

- (BOOL)canTransitionToState:(NSString*)state;
- (void)transitionToState:(NSString*)state;

@end


@protocol OPTStateMachineDelegate <NSObject>
@optional

- (BOOL)stateMachine:(OPTStateMachine*)stateMachine shouldTransitionFromState:(NSString*)sourceState toState:(NSString*)destinationState;
- (void)stateMachine:(OPTStateMachine*)stateMachine willTransitionToState:(NSString*)destinationState;
- (void)stateMachine:(OPTStateMachine*)stateMachine didTransitionFromState:(NSString*)sourceState;

@end