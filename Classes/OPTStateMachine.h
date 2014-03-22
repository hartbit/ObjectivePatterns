//
//  OPTStateMachine.h
//  ObjectivePatterns
//
//  Created by David Hart on 16/03/14.
//

@import Foundation;


extern NSString* OPTErrorDomain;


@protocol OPTStateMachineDelegate;

@interface OPTStateMachine : NSObject

@property (nonatomic, copy, readonly) NSString* currentState;
@property (nonatomic, weak) id<OPTStateMachineDelegate> delegate;

- (id)initWithStartState:(NSString*)state;

- (BOOL)acceptsInput:(NSString*)input userInfo:(NSDictionary*)userInfo;
- (void)feedInput:(NSString*)input userInfo:(NSDictionary*)userInfo error:(NSError*__autoreleasing*)error;

@end


@protocol OPTStateMachineDelegate <NSObject>

@required
- (NSString*)stateMachine:(OPTStateMachine*)stateMachine destinationStateFromState:(NSString*)sourceState withInput:(NSString*)input userInfo:(NSDictionary*)userInfo;

@optional
- (void)stateMachine:(OPTStateMachine*)stateMachine willTransitionToState:(NSString*)destinationState withInput:(NSString*)input userInfo:(NSDictionary*)userInfo;
- (void)stateMachine:(OPTStateMachine*)stateMachine didTransitionFromState:(NSString*)sourceState withInput:(NSString*)input userInfo:(NSDictionary*)userInfo;

@end