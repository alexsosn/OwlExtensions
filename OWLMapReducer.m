//
//  OWLMapReducer.m
//  
//
//  Created by Sosnovshchenko Alexander on 8/7/14.
//
//

#import "OWLMapReducer.h"

@implementation MapReducer

+ (NSArray *)sequence:(NSArray *)input
                  map:(NSDictionary * (^)(id object))mapBlock
               reduce:(id (^)(id key, id value))reduceBlock {
    __block NSMutableDictionary *mapAggregationResults = [NSMutableDictionary dictionary];
    
    dispatch_queue_t queue = dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphoreMap = dispatch_semaphore_create(1);
    dispatch_apply(input.count, queue, ^(size_t index) {
        NSDictionary *item = input[index];
        NSDictionary *mapEmitted = mapBlock(item);
        id key = mapEmitted[@"key"];
        id value = mapEmitted[@"value"];
        dispatch_semaphore_wait(semaphoreMap, DISPATCH_TIME_FOREVER);
        if (mapAggregationResults[key]) {
            [mapAggregationResults[key] addObject:value];
        } else {
            [mapAggregationResults setObject:[NSMutableArray arrayWithObject:value] forKey:key];
        }
        dispatch_semaphore_signal(semaphoreMap);
    });
    
    __block NSMutableArray *reduceEmitted = [NSMutableArray array];
    dispatch_semaphore_t semaphoreReduce = dispatch_semaphore_create(1);
    dispatch_apply(mapAggregationResults.count, queue, ^(size_t index) {
        id key = mapAggregationResults.allKeys[index];
        id obj = mapAggregationResults[key];
        dispatch_semaphore_wait(semaphoreReduce, DISPATCH_TIME_FOREVER);
        [reduceEmitted addObject:reduceBlock(key, obj)];
        dispatch_semaphore_signal(semaphoreReduce);
        
    });
    return reduceEmitted;
}

@end
