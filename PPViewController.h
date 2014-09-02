//
//  PPViewController.h
//  OrderAndPay
//
//  Created by Marco Denisi on 29/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@interface PPViewController : UIViewController <PayPalFuturePaymentDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) NSNumber *amount;

@end
