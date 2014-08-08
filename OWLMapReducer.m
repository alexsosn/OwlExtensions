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
@property (nonatomic, strong) NSRecursiveLock *lock;
@end

@implementation OWLMapReducer

- (instancetype)init {
    self = [super init];
    if (self) {
        _result = [NSMutableArray array];
        _intermediate = [NSMutableDictionary dictionary];
        _lock = [NSRecursiveLock new];
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
    [_lock lock];
    if (!_intermediate[key]) {
        _intermediate[key] = [NSMutableArray arrayWithObject:value];
    } else {
        [_intermediate[key] addObject:value];
    }
    [_lock unlock];
}

- (void)emitValue:(id) value {
    [_lock lock];
    [_result addObject:value];
    [_lock unlock];
}

@end
