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
 NSArray *array =
         [OWLMapReducer sequence:input
          map:^NSDictionary *(id object) {
                  NSInteger dateValue = 0;
                  NSDate *date = [object valueForKey:@"date"];;
                  switch (_periodType) {
		  case BBPeriodTypeOneMonth: {
			  dateValue = [date mk_week];
			  break;
		  }
		  case BBPeriodTypeSixMonth: {
			  NSInteger week = [date mk_week];
			  dateValue = week - (week % 2);
			  break;
		  }
		  case BBPeriodTypeYear: {
			  dateValue = [date mk_year]*12 + [date mk_month];
			  break;
		  }
		  default:
			  break;
		  }

                  return @{@"key" : @{@"date":@(dateValue),
                                      @"type":[object valueForKey:@"type"]},
                           @"value" : [object valueForKey:@"value"]};
	  }
          reduce:^id (id key, id value) {
                  NSArray *array = value;
                  CGFloat acc = 0.;
                  CGFloat len = 0.;
                  for (NSString *value in array) {
                          acc += value.floatValue;
                          len += @(value.floatValue != 0.).floatValue;
		  }
                  CGFloat mean = 0.;
                  if (len != 0.) {
                          mean = acc/len;
		  }
                  return @{@"date":key[@"date"],
                           @"type":key[@"type"],
                           @"value":@(mean)};
	  }];
*/

+ (NSArray *)sequence:(NSArray *)input
                  map:(NSDictionary * (^)(id object))mapBlock
               reduce:(id (^)(id key, id value))reduceBlock;

@end
