//
//  OWLMapReducer.h
//
//
//  Created by Sosnovshchenko Alexander on 8/7/14.
//
//

#import <Foundation/Foundation.h>

@interface OWLMapReducer : NSObject

/* Usage example

 input is array of NSStrings :
 
 NSArray *input = @[@"cat dog cow cat dog cow cat cat mat dog cow",
                    @"cat dog cow cat dog cow cat dog cow cat dog cow",
                    @"cat dog dog cow cat dog cattt cow cat dog cow cat"];

 For example you want to count frequencies of words in input array.
 
 OWLMapReducer *mr = [OWLMapReducer new];

 NSArray *tokensFrequencies =
         [mr sequence:input
          map:^(id object) {
                  NSString *string = object;
                  NSArray *tokensInString = [string componentsSeparatedByString:@" "];
                  for (NSString *token in tokensInString) {
                          [mr emitIntermediateKey:token value:@1];
		  }
	  }
          reduce:^(id key, id value) {
                  NSInteger acc = 0;
                  for (NSNumber *num in value) {
                          acc += num.integerValue;
		  }
                  [mr emitValue:@{key:@(acc)}];
	  }];

Result:
tokensFrequencies == @[
        @{@"cat"  : @12},
        @{@"mat"  : @1},
        @{@"cattt": @1},
        @{@"cow"  : @10},
        @{@"dog"  : @11}
    ]
 */

- (NSArray *)sequence:(NSArray *)input
                  map:(void (^)(id object))mapBlock
               reduce:(void (^)(id key, id value))reduceBlock;

- (void)emitIntermediateKey:(id) key value:(id) value;

- (void)emitValue:(id) value;

@end
