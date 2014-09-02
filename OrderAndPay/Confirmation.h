//
//  Confirmation.h
//  OrderAndPay
//
//  Created by Marco Denisi on 02/09/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Confirmation : NSObject <NSCoding>

@property (strong, nonatomic) NSString *paymentId;
@property (strong, nonatomic) NSString *orderId;

@end
