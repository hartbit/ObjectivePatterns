//
//  OPTVisitor.m
//  Pods
//
//  Created by David Hart on 22/03/14.
//

#import "OPTVisitor.h"


@implementation OPTVisitor

#pragma mark - Internal Methods

- (void)visit:(id)object
{
	SEL selector = [[self class] visitSelectorForClass:[object class]];
	
	if (selector != NULL) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:selector withObject:object];
#pragma clang diagnostic pop
	}
}

#pragma mark - Private Methods

+ (SEL)visitSelectorForClass:(Class)objectClass
{
	if (objectClass == NULL) {
		return NULL;
	}
	
	static NSMutableDictionary* sSelectors;
	
	if (sSelectors == nil) {
		sSelectors = [NSMutableDictionary dictionary];
	}
	
	NSString* classString = NSStringFromClass(self);
	NSMutableDictionary* classSelectors = sSelectors[classString];
	
	if (classSelectors == nil) {
		classSelectors = [NSMutableDictionary dictionary];
		sSelectors[classString] = classSelectors;
	}
	
	NSString* selectorString = classSelectors[objectClass];
	SEL selector = NULL;
	
	if (selectorString == nil) {
		selectorString = [NSString stringWithFormat:@"visit%@:", NSStringFromClass(objectClass)];
		selector = NSSelectorFromString(selectorString);
		
		if (![self instancesRespondToSelector:selector]) {
			selector = [self visitSelectorForClass:[objectClass superclass]];
			selectorString = (selector != NULL) ? NSStringFromSelector(selector) : [NSString string];
		}
		
		classSelectors[(id<NSCopying>)objectClass] = selectorString;
	}
	else if ([selectorString length] != 0) {
		selector = NSSelectorFromString(selectorString);
	}
	
	return selector;
}

@end
