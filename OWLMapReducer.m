//
//  OWLMapReducer.h
//
//
//  Created by Sosnovshchenko Alexander on 8/7/14.
//
//

#import "OWLMapReducer.h"

@interface OWLMapReducer ()
@property (nonatomic, strong) NSMutableArray *result;
@property (nonatomic, strong) NSMutableDictionary *intermediate;
@property (nonatomic, strong) dispatch_semaphore_t semaphoreMap;
@property (nonatomic, strong) dispatch_semaphore_t semaphoreReduce;
@end

@implementation OWLMapReducer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _result = [NSMutableArray array];
        _intermediate = [NSMutableDictionary dictionary];
        _semaphoreMap = dispatch_semaphore_create(1);
        _semaphoreReduce = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray *)sequence:(NSArray *)input
                  map:(void (^)(id object))mapBlock
               reduce:(void (^)(id key, id value))reduceBlock {
    
    dispatch_queue_t queue = dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(input.count, queue, ^(size_t index) {
        NSDictionary *item = input[index];
        mapBlock(item);
    });
    
    dispatch_apply(_intermediate.count, queue, ^(size_t index) {
        id key = _intermediate.allKeys[index];
        id obj = _intermediate[key];
        reduceBlock(key, obj);
        
    });
    return _result;
}

- (void)emitIntermediateKey:(id) key value:(id) value {
    dispatch_semaphore_wait(_semaphoreMap, DISPATCH_TIME_FOREVER);
    if (!_intermediate[key]) {
        _intermediate[key] = [NSMutableArray arrayWithObject:value];
    } else {
        [_intermediate[key] addObject:value];
    }
    dispatch_semaphore_signal(_semaphoreMap);
}

- (void)emitValue:(id) value {
    dispatch_semaphore_wait(_semaphoreReduce, DISPATCH_TIME_FOREVER);
    [_result addObject:value];
    dispatch_semaphore_signal(_semaphoreReduce);
}

@end
