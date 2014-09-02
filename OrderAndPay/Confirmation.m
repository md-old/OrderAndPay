//
//  Confirmation.m
//  OrderAndPay
//
//  Created by Marco Denisi on 02/09/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import "Confirmation.h"
#import <AdSupport/AdSupport.h>

@implementation Confirmation

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.orderId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        self.paymentId = [[NSString alloc] init];
    }
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.orderId = [aDecoder decodeObjectForKey:@"orderId"];
    self.paymentId = [aDecoder decodeObjectForKey:@"paymentId"];
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.orderId forKey:@"orderId"];
    [aCoder encodeObject:self.paymentId forKey:@"paymentId"];
}

@end
